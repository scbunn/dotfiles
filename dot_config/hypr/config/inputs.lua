-- Input configuration

hl.config({
  input = {
    kb_options = "ctrl:nocaps",
    accel_profile = "flat",
    repeat_rate = 35,
    repeat_delay = 200,
	  touchpad = {
	    disable_while_typing = true,
  	  clickfinger_behavior = true,
  	  natural_scroll = true,
  	}
  },
})

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
