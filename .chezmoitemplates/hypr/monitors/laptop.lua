-- Laptop: built-in panel, anything else at its preferred mode.

MONITOR1 = "eDP-1"
PRIMARY_MONITOR = MONITOR1

hl.monitor({
  output = MONITOR1,
  mode = "1920x1200@59.95",
  position = "auto",
  scale = "1",
})

hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "1",
})
