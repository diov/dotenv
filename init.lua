require("modules/magnet")
require("modules/switch")


-------------------------------------------------------------------
-- Sleep
-------------------------------------------------------------------

hs.hotkey.bind(mash, "delete", hs.caffeinate.systemSleep)
