-- Look and feel configuration

hl.config({
    general = {
        gaps_in = 3,
        gaps_out = 3,
        border_size = 2,
        extend_border_grab_area = 10,
        resize_on_border = true,
        col = {
            active_border = {
                colors = { GRUVBOX_LYELLOW, GRUVBOX_YELLOW },
                angle = 45,
            },
            inactive_border = GRUVBOX_BG1,
        },
    },
    group = {
        col = {
            border_active = GRUVBOX_LBLUE,
            border_inactive = GRUVBOX_BG1,
            border_locked_active = GRUVBOX_LORANGE,
            border_locked_inactive = GRUVBOX_BG1,
        },
        groupbar = {
            col = {
                active = GRUVBOX_LBLUE,
                inactive = GRUVBOX_BG1,
                locked_active = GRUVBOX_LORANGE,
                locked_inactive = GRUVBOX_BG1,
            },
        },
    },
    decoration = {
        dim_special = 0.3,
        rounding = 3,
        active_opacity = 0.95,
        inactive_opacity = 0.85,
        fullscreen_opacity = 1,
        blur = {
            size = 5,
            passes = 4,
            special = true,
        },
    },
})
