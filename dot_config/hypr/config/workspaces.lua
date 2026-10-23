-- Workspace rules wiki https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/
-- Add your workspace rules here. Increment the workspace number as you go. Do not have duplicate workspaces.
hl.workspace_rule({ workspace = "name:gaming", monitor = PRIMARY_MONITOR, default = true })
-- 1: daily driving (browser), 2: development (editor, terminals), 3: music and chat.
-- default_name is what the Noctalia workspaces widget shows as the label (label_source = "name").
-- Use single-codepoint emoji (no U+FE0F variation selector) so they fit max_label_chars.
hl.workspace_rule({ workspace = "1", monitor = MONITOR1, default = true, persistent = true, default_name = "🌐" }) -- web
hl.workspace_rule({ workspace = "2", monitor = MONITOR1, default = true, persistent = true, default_name = "💻" }) -- dev
hl.workspace_rule({ workspace = "3", monitor = MONITOR1, default = true, persistent = true, default_name = "🎵" }) -- music
-- hl.workspace_rule({ workspace = "4", monitor = MONITOR2, default = true, persistent = true })
-- hl.workspace_rule({ workspace = "5", monitor = MONITOR2, default = true, persistent = true })
-- hl.workspace_rule({ workspace = "6", monitor = MONITOR2, default = true, persistent = true })

-- For other layouts such as scrolling, see example below
-- hl.workspace_rule({ workspace = "1", monitor = MONITOR1, default = true, persistent = true, layout = "scrolling" })
