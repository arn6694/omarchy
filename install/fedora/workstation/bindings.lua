-- Installed desktop applications.
o.rebind("SUPER + SHIFT + A", "ChatGPT desktop", { launch = "chatgpt", focus = "^chatgpt$" })
o.rebind("SUPER + SHIFT + C", "Claude desktop", { launch = "claude-desktop", focus = "^com.anthropic.Claude$" })
o.rebind("SUPER + SHIFT + G", "Grok Bot desktop", { launch = "grok-bot", focus = "^grok-bot$" })
o.rebind("SUPER + SHIFT + H", "Hermes desktop", { launch = "hermes-desktop", focus = "^Hermes$" })
o.rebind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "^md.obsidian.Obsidian$" })
o.rebind("SUPER + CTRL + G", "Equal-size tiles", function()
  local ws = hl.get_active_workspace()
  if ws then hl.workspace_rule({ workspace = tostring(ws.id), layout = "lua:omadora-equal" }) end
end)
o.rebind("SUPER + CTRL + SHIFT + L", "Resizable dwindle tiles", function()
  local ws = hl.get_active_workspace()
  if ws then hl.workspace_rule({ workspace = tostring(ws.id), layout = "dwindle" }) end
end)

-- Remove shortcuts for absent optional utilities.
hl.unbind("SUPER + CTRL + Q")
hl.unbind("XF86Calculator")
hl.unbind("SUPER + CTRL + K")

-- WezTerm uses this app ID on Fedora; enable terminal copy/paste handling.
o.window("org\\.wezfurlong\\.wezterm", { tag = "+terminal" })

-- Launch Steam or bring its library forward.
o.rebind("SUPER + SHIFT + S", "Steam", { launch = "/usr/bin/steam steam://open/games" })
