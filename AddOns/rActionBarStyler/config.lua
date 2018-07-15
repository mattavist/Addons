
  -- // rActionBarStyler
  -- // zork - 2012

  -----------------------------
  -- INIT
  -----------------------------

  --get the addon namespace
  local cfg = CreateFrame("Frame")
  local addon, ns = ...
  ns.cfg = cfg

  -----------------------------
  -- CONFIG
  -----------------------------

  --use "/rabs" to see the command list

  cfg.bars = {
    --BAR 1
    bar1 = {
      enable          = true, --enable module
      uselayout2x6    = true,
      scale           = 1,
      padding         = 2, --frame padding
      buttons         = {
        size            = 40,
        margin          = 5,
      },
      pos             = { a1 = "BOTTOM", a2 = "BOTTOM", af = "UIParent", x = 156, y = 4 },
      userplaced      = {
        enable          = false,
      },
      mouseover       = {
        enable          = false,
        fadeIn          = {time = 0.01, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
      combat          = { --fade the bar in/out in combat/out of combat
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
    },
    --OVERRIDE BAR (vehicle ui)
    overridebar = { --the new vehicle and override bar
      enable          = true, --enable module
      scale           = 1,
      padding         = 2, --frame padding
      buttons         = {
        size            = 40,
        margin          = 5,
      },
      pos             = { a1 = "BOTTOM", a2 = "BOTTOM", af = "UIParent", x = 0, y = 50 },
      userplaced      = {
        enable          = false,
      },
      mouseover       = {
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
      combat          = { --fade the bar in/out in combat/out of combat
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
    },
    --BAR 2
    bar2 = {
      enable          = true, --enable module
      uselayout2x6    = false,
      scale           = 1,
      padding         = 2, --frame padding
      buttons         = {
        size            = 40,
        margin          = 5,
      },
      pos             = { a1 = "BOTTOM", a2 = "BOTTOM", af = "UIParent", x = 0, y = 94 },
      userplaced      = {
        enable          = false,
      },
      mouseover       = {
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
      combat          = { --fade the bar in/out in combat/out of combat
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
    },
    --BAR 3
    bar3 = {
      enable          = true, --enable module
      scale           = 1,
      padding         = 2, --frame padding
      buttons         = {
        size            = 40,
        margin          = 5,
      },
      pos             = { a1 = "TOP", a2 = "TOP", af = "UIParent", x = 0, y = -25 },
      userplaced      = {
        enable          = false,
      },
      mouseover       = {
        enable          = true,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0},
      },
      combat          = { --fade the bar in/out in combat/out of combat
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
    },
    --BAR 4
    bar4 = {
      enable          = true, --enable module
      combineBar4AndBar5  = true, --by choosing true both bar 4 and 5 will react to the same hover effect, thus true/false at the same time, settings for bar5 will be ignored
      scale           = 1,
      padding         = 10, --frame padding
      buttons         = {
        size            = 40,
        margin          = 5,
      },
      pos             = { a1 = "RIGHT", a2 = "RIGHT", af = "UIParent", x = -0, y = 0 },
      userplaced      = {
        enable          = false,
      },
      mouseover       = {
        enable          = true,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0},
      },
      combat          = { --fade the bar in/out in combat/out of combat
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
    },
    --BAR 5
    bar5 = {
      enable          = true, --enable module
      scale           = 1,
      padding         = 10, --frame padding
      buttons         = {
        size            = 26,
        margin          = 5,
      },
      pos             = { a1 = "RIGHT", a2 = "RIGHT", af = "UIParent", x = -36, y = 0 },
      userplaced      = {
        enable          = true,
      },
      mouseover       = {
        enable          = true,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
      combat          = { --fade the bar in/out in combat/out of combat
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
    },
    --PETBAR
    petbar = {
      enable          = true, --enable module
      show            = true, --true/false
      scale           = 0.82,
      padding         = 2, --frame padding
      buttons         = {
        size            = 26,
        margin          = 5,
      },
      pos             = { a1 = "BOTTOM", a2 = "BOTTOM", af = "UIParent", x = 0, y = 300 },
      userplaced      = {
        enable          = true,
      },
      mouseover       = {
        enable          = true,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.4},
      },
      combat          = { --fade the bar in/out in combat/out of combat
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
    },
    --STANCE- + POSSESSBAR
    stancebar = {
      enable          = false, --enable module
      show            = true, --true/false
      scale           = 0.82,
      padding         = 2, --frame padding
      buttons         = {
        size            = 26,
        margin          = 5,
      },
      pos             = { a1 = "BOTTOM", a2 = "BOTTOM", af = "UIParent", x = 0, y = 600 },
      userplaced      = {
        enable          = false,
      },
      mouseover       = {
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.4},
      },
      combat          = { --fade the bar in/out in combat/out of combat
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
    },
    --EXTRABAR
    extrabar = {
      enable          = true, --enable module
      scale           = 1,
      padding         = 5, --frame padding
      buttons         = {
        size            = 50,
        margin          = 5,
      },
      pos             = { a1 = "BOTTOM", a2 = "BOTTOM", af = "UIParent", x = -178, y = 20 },
      userplaced      = {
        enable          = false,
      },
      mouseover       = {
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
    },
    --VEHICLE EXIT (no vehicleui)
    leave_vehicle = {
      enable          = true, --enable module
      scale           = 0.82,
      padding         = 10, --frame padding
      buttons         = {
        size            = 26,
        margin          = 5,
      },
      pos             = { a1 = "BOTTOM", a2 = "BOTTOM", af = "UIParent", x = 210, y = 135 },
      userplaced      = {
        enable          = true,
      },
      mouseover       = {
        enable          = false,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0.2},
      },
    },
    --MICROMENU
    micromenu = {
      enable          = true, --enable module
      show            = true, --true/false
      scale           = 1,
      padding         = 10, --frame padding
      pos             = { a1 = "BOTTOM", a2 = "BOTTOM", af = "UIParent", x = 400, y = -10 },
      userplaced      = {
        enable          = false,
      },
      mouseover       = {
        enable          = true,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0},
      },
    },
    --BAGS
    bags = {
      enable          = true, --enable module
      show            = false, --true/false
      scale           = 1,
      padding         = 15, --frame padding
      pos             = { a1 = "BOTTOM", a2 = "BOTTOM", af = "UIParent", x = 0, y = 22 },
      userplaced      = {
        enable          = false,
      },
      mouseover       = {
        enable          = true,
        fadeIn          = {time = 0.4, alpha = 1},
        fadeOut         = {time = 0.3, alpha = 0},
      },
    },
  }
