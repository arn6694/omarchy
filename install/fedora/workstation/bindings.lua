-- Installed desktop applications.
o.rebind("SUPER + SHIFT + A", "ChatGPT desktop", { launch = "chatgpt", focus = "^chatgpt$" })
o.rebind("SUPER + SHIFT + C", "Claude desktop", { launch = "claude-desktop", focus = "^com.anthropic.Claude$" })
o.rebind("SUPER + SHIFT + G", "Grok Bot desktop", { launch = "grok-bot", focus = "^grok-bot$" })
o.rebind("SUPER + SHIFT + H", "Hermes desktop", { launch = "hermes-desktop", focus = "^Hermes$" })
o.rebind("SUPER + SHIFT + O", "Obsidian", { launch = "obsidian", focus = "^md.obsidian.Obsidian$" })
-- Persist layout selection so saved workspace rules cannot restore scrolling.
local function omadora_select_layout(layout)
  local ws = hl.get_active_workspace()
  if not ws then return end
  local paths = require("default.hypr.paths")
  local path = paths.state_home .. "/omarchy/workspace-layouts/" .. tostring(ws.id) .. ".lua"
  local file = assert(io.open(path, "w"))
  file:write(string.format("hl.workspace_rule({ workspace = %q, layout = %q })\n", tostring(ws.id), layout))
  file:close()
  hl.workspace_rule({ workspace = tostring(ws.id), layout = layout })
end

o.rebind("SUPER + L", "Equal-size tiles", function() omadora_select_layout("lua:omadora-equal") end)
o.rebind("SUPER + CTRL + G", "Equal-size tiles", function() omadora_select_layout("lua:omadora-equal") end)
o.rebind("SUPER + CTRL + SHIFT + L", "Resizable dwindle tiles", function() omadora_select_layout("dwindle") end)

-- Remove shortcuts for absent optional utilities.
hl.unbind("SUPER + CTRL + Q")
hl.unbind("XF86Calculator")
hl.unbind("SUPER + CTRL + K")

-- WezTerm uses this app ID on Fedora; enable terminal copy/paste handling.
o.window("org\\.wezfurlong\\.wezterm", { tag = "+terminal" })

-- Launch Steam or bring its library forward.
o.rebind("SUPER + SHIFT + S", "Steam", { launch = "/usr/bin/steam steam://open/games" })
