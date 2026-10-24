-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Add your workspace rules here. Increment the workspace number as you go. Do not have duplicate workspaces.
-- Games are sent here by windowrules.lua. Not default: the monitor would start on it instead of 1.
-- The name is the bar label (label_source = "name"), so this one shows as G.
hl.workspace_rule({ workspace = "name:G", monitor = PRIMARY_MONITOR })
-- 1: daily driving (browser), 2: development (editor, terminals), 3: music and chat.
-- No default_name: the name stays the number, which is what the bar shows.
hl.workspace_rule({ workspace = "1", monitor = MONITOR1, default = true, persistent = true }) -- web
hl.workspace_rule({ workspace = "2", monitor = MONITOR1, default = true, persistent = true }) -- dev
hl.workspace_rule({ workspace = "3", monitor = MONITOR1, default = true, persistent = true }) -- music
-- hl.workspace_rule({ workspace = "4", monitor = MONITOR2, default = true, persistent = true })
-- hl.workspace_rule({ workspace = "5", monitor = MONITOR2, default = true, persistent = true })
-- hl.workspace_rule({ workspace = "6", monitor = MONITOR2, default = true, persistent = true })

-- For other layouts such as scrolling, see example below
-- hl.workspace_rule({ workspace = "1", monitor = MONITOR1, default = true, persistent = true, layout = "scrolling" })
