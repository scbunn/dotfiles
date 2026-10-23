-- Alienware Aurora R15 (RTX 4090) + Alienware AW3423DW (QD-OLED, 3440x1440, 175 Hz) over DP 1.4.
-- Matched by description so it keeps working if the cable moves to another port.
--
-- DP 1.4 without DSC can't carry 10-bit at 175 Hz, so pick one:
--   HDR: 144 Hz, 10-bit, desktop mapped into BT.2100 (default below)
--   SDR: 175 Hz, 8-bit, clamped to sRGB so the wide-gamut panel doesn't oversaturate
-- VRR comes from misc.vrr in misc.lua (3 = fullscreen games/video only, avoids OLED flicker on the desktop).
-- If SDR windows look washed out or dim in HDR, tune sdrbrightness/sdrsaturation (1.0-1.3).

MONITOR1 = "desc:Dell Inc. Dell AW3423DW #tBszGDAYBAkR"
PRIMARY_MONITOR = MONITOR1

hl.monitor({
  output = MONITOR1,
  mode = "3440x1440@143.97",
  position = "0x0",
  scale = "1",
  bitdepth = 10,
  cm = "hdr",
  sdrbrightness = 1.2,
  sdrsaturation = 1.0,
})

-- SDR alternative:
-- hl.monitor({
--   output = MONITOR1,
--   mode = "3440x1440@174.96",
--   position = "0x0",
--   scale = "1",
--   cm = "srgb",
-- })

-- Anything else plugged in
hl.monitor({
  output = "",
  mode = "preferred",
  position = "auto",
  scale = "1",
})
