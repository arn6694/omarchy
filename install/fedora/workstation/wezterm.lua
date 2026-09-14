local wezterm = require("wezterm")
local act = wezterm.action

local config = wezterm.config_builder()

-- ============================================================
-- Appearance
-- ============================================================

config.font_size = 18.0
config.color_scheme = "Catppuccin Mocha"

config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.use_fancy_tab_bar = true
config.show_tab_index_in_tab_bar = false

config.scrollback_lines = 10000
config.status_update_interval = 1000

config.window_padding = {
  left = 8,
  right = 8,
  top = 6,
  bottom = 6,
}

config.default_workspace = "General"

-- ============================================================
-- SSH hosts from ~/.ssh/config
--
-- These are plain SSH domains. WezTerm is not required on the
-- remote server, and the sessions are not persistent after the
-- connection or local WezTerm process ends.
-- ============================================================

local ssh_domains = {}
local ssh_hostnames = {}
local ssh_domain_hostnames = {}

for alias, ssh_config in pairs(wezterm.enumerate_ssh_hosts()) do
  local domain_name = "SSH:" .. alias
  local configured_hostname = ssh_config.hostname or alias

  table.insert(ssh_domains, {
    name = domain_name,
    remote_address = alias,
    multiplexing = "None",
    assume_shell = "Posix",
  })

  ssh_hostnames[alias:lower()] = configured_hostname
  ssh_domain_hostnames[domain_name] = configured_hostname
end

table.sort(ssh_domains, function(a, b)
  return a.name:lower() < b.name:lower()
end)

config.ssh_domains = ssh_domains

-- ============================================================
-- Mouse: copy on selection and right-click paste
-- ============================================================

config.mouse_bindings = {
  {
    event = {
      Up = {
        streak = 1,
        button = "Left",
      },
    },
    mods = "NONE",
    action = act.CompleteSelectionOrOpenLinkAtMouseCursor("Clipboard"),
  },
  {
    event = {
      Down = {
        streak = 1,
        button = "Right",
      },
    },
    mods = "NONE",
    action = act.PasteFrom("Clipboard"),
  },
}

-- ============================================================
-- Dynamic tab titles
-- ============================================================

local local_hostname = wezterm.hostname():lower():gsub("%.$", "")
local local_shortname = local_hostname:match("^[^%.]+") or local_hostname

local function basename(path)
  if not path or path == "" then
    return ""
  end

  return path:gsub("(.*[/\\])", "")
end

local function clean_hostname(host)
  if not host or host == "" then
    return nil
  end

  host = host:gsub("^%s+", ""):gsub("%s+$", "")
  host = host:gsub("^.-@", "")
  host = host:gsub("^%[", ""):gsub("%]$", "")
  host = host:gsub("%.$", "")

  -- Remove a port from host:port, but leave unbracketed IPv6 alone.
  if not host:find(":.*:") then
    host = host:gsub(":%d+$", "")
  end

  if host == "" then
    return nil
  end

  return host
end

local function canonical_ssh_hostname(host)
  host = clean_hostname(host)
  if not host then
    return nil
  end

  return ssh_hostnames[host:lower()] or host
end

local function is_local_hostname(host)
  host = clean_hostname(host)
  if not host then
    return false
  end

  local lowered = host:lower()
  local short = lowered:match("^[^%.]+") or lowered

  return lowered == local_hostname
    or short == local_shortname
    or lowered == "localhost"
    or lowered == "127.0.0.1"
    or lowered == "::1"
end

local function hostname_from_cwd(cwd)
  if not cwd then
    return nil
  end

  if type(cwd) == "userdata" then
    return clean_hostname(cwd.host)
  end

  if type(cwd) == "string" then
    local authority = cwd:match("^[%a][%w+.-]*://([^/]+)")
    return clean_hostname(authority)
  end

  return nil
end

local ssh_options_with_argument = {
  ["-B"] = true,
  ["-b"] = true,
  ["-c"] = true,
  ["-D"] = true,
  ["-E"] = true,
  ["-e"] = true,
  ["-F"] = true,
  ["-I"] = true,
  ["-i"] = true,
  ["-J"] = true,
  ["-L"] = true,
  ["-l"] = true,
  ["-m"] = true,
  ["-O"] = true,
  ["-o"] = true,
  ["-P"] = true,
  ["-p"] = true,
  ["-Q"] = true,
  ["-R"] = true,
  ["-S"] = true,
  ["-W"] = true,
  ["-w"] = true,
}

local function hostname_from_ssh_command(command)
  if not command or command == "" then
    return nil
  end

  local words = {}
  for word in command:gmatch("%S+") do
    local cleaned_word = word:gsub("^[\"']", ""):gsub("[\"']$", "")
    table.insert(words, cleaned_word)
  end

  local ssh_index = nil
  for index, word in ipairs(words) do
    if basename(word):lower() == "ssh" then
      ssh_index = index
      break
    end
  end

  if not ssh_index then
    return nil
  end

  local skip_next = false
  for index = ssh_index + 1, #words do
    local word = words[index]

    if skip_next then
      skip_next = false
    elseif word == "--" then
      return canonical_ssh_hostname(words[index + 1])
    elseif ssh_options_with_argument[word] then
      skip_next = true
    elseif word:sub(1, 1) ~= "-" then
      return canonical_ssh_hostname(word)
    end
  end

  return nil
end

local function hostname_from_terminal_title(title)
  if not title or title == "" then
    return nil
  end

  -- Common remote titles include user@host:/path and user@host.
  local host = title:match("[%w._-]+@([^:%s/]+)")
  if host then
    return canonical_ssh_hostname(host)
  end

  return nil
end

local function dynamic_tab_title(tab)
  if tab.tab_title and tab.tab_title ~= "" then
    return tab.tab_title
  end

  local pane = tab.active_pane
  local process = basename(pane.foreground_process_name):gsub("%.exe$", "")
  local process_lower = process:lower()

  -- Integrated plain SSH domain created by the launcher.
  local domain_host = ssh_domain_hostnames[pane.domain_name]
  if domain_host then
    return domain_host
  end

  -- Remote WezTerm shell integration reports the real host directly.
  local user_vars = pane.user_vars or {}
  local reported_host = clean_hostname(user_vars.WEZTERM_HOST)
  if reported_host and not is_local_hostname(reported_host) then
    return reported_host
  end

  -- OSC 7 shell integration embeds the host in the working-directory URI.
  local cwd_host = hostname_from_cwd(pane.current_working_dir)
  if cwd_host and not is_local_hostname(cwd_host) then
    return canonical_ssh_hostname(cwd_host)
  end

  if process_lower == "ssh" then
    -- Many remote shells set a title such as user@server:/current/path.
    local title_host = hostname_from_terminal_title(pane.title)
    if title_host and not is_local_hostname(title_host) then
      return title_host
    end

    -- Local WezTerm shell integration records commands such as `ssh db01`.
    -- Resolve db01 through ~/.ssh/config so the configured host is displayed.
    local command_host = hostname_from_ssh_command(user_vars.WEZTERM_PROG)
    if command_host then
      return command_host
    end
  end

  if process ~= "" then
    return process
  end

  return "local shell"
end

wezterm.on("format-tab-title", function(tab, _, _, _, _, max_width)
  local title = dynamic_tab_title(tab)

  if tab.active_pane.has_unseen_output then
    title = "* " .. title
  end

  local available_width = math.max(1, (max_width or 32) - 2)
  return " " .. wezterm.truncate_right(title, available_width) .. " "
end)

-- ============================================================
-- Status bar
--
-- Deliberately does not inspect the pane or call
-- pane:get_domain_name(); this avoids the stale-pane mux race.
-- ============================================================

wezterm.on("update-status", function(window)
  local workspace = window:active_workspace()
  local time = wezterm.strftime("%a %b %-d  %I:%M %p")

  window:set_left_status(wezterm.format({
    { Attribute = { Intensity = "Bold" } },
    { Text = "  " .. workspace .. "  " },
  }))

  window:set_right_status(wezterm.format({
    { Text = " " .. wezterm.hostname() .. "  |  " .. time .. "  " },
  }))
end)

-- ============================================================
-- Keyboard shortcuts
-- ============================================================

config.keys = {
  -- Tabs
  {
    key = "t",
    mods = "CTRL|SHIFT",
    action = act.SpawnTab("CurrentPaneDomain"),
  },
  {
    key = "w",
    mods = "CTRL|SHIFT",
    action = act.CloseCurrentTab({ confirm = true }),
  },

  -- Side-by-side and top/bottom pane splits
  {
    key = "\\",
    mods = "CTRL|SHIFT",
    action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }),
  },
  {
    key = "-",
    mods = "CTRL|SHIFT",
    action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
  },

  -- Pane navigation
  {
    key = "LeftArrow",
    mods = "CTRL|ALT",
    action = act.ActivatePaneDirection("Left"),
  },
  {
    key = "RightArrow",
    mods = "CTRL|ALT",
    action = act.ActivatePaneDirection("Right"),
  },
  {
    key = "UpArrow",
    mods = "CTRL|ALT",
    action = act.ActivatePaneDirection("Up"),
  },
  {
    key = "DownArrow",
    mods = "CTRL|ALT",
    action = act.ActivatePaneDirection("Down"),
  },
  {
    key = "x",
    mods = "CTRL|SHIFT",
    action = act.CloseCurrentPane({ confirm = true }),
  },

  -- Named workspaces
  {
    key = "1",
    mods = "ALT",
    action = act.SwitchToWorkspace({ name = "General" }),
  },
  {
    key = "2",
    mods = "ALT",
    action = act.SwitchToWorkspace({ name = "Ansible" }),
  },
  {
    key = "3",
    mods = "ALT",
    action = act.SwitchToWorkspace({ name = "Homelab" }),
  },
  {
    key = "w",
    mods = "ALT",
    action = act.ShowLauncherArgs({
      flags = "FUZZY|WORKSPACES",
      title = "Choose Workspace",
    }),
  },

  -- SSH hosts from ~/.ssh/config
  {
    key = "s",
    mods = "ALT",
    action = act.ShowLauncherArgs({
      flags = "FUZZY|DOMAINS",
      title = "SSH Hosts",
    }),
  },

  -- Combined launcher
  {
    key = "p",
    mods = "CTRL|SHIFT",
    action = act.ShowLauncherArgs({
      flags = "FUZZY|TABS|WORKSPACES|DOMAINS|COMMANDS|KEY_ASSIGNMENTS",
      title = "WezTerm Launcher",
    }),
  },

  -- Search scrollback
  {
    key = "f",
    mods = "CTRL|SHIFT",
    action = act.Search({ CaseInSensitiveString = "" }),
  },
}

return config
