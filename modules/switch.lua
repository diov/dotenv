-------------------------------------------------------------------
-- One Switch
-------------------------------------------------------------------

local menuData = {}
local switchBar = hs.menubar.new()
local homePath = hs.fs.pathToAbsolute("~")
local desktopPath = homePath.."/Desktop"
switchBar:setTitle("😋️")
local refresh

-------------------------------------------------------------------
-- Toggle Dark Mode
-------------------------------------------------------------------

local modeScript = "Application('System Events').appearancePreferences.darkMode"

local function isDarkMode()
    local ok, result, description = hs.osascript.javascript(string.gsub([[(function() {
        return ${script}()
    })()]], "${script}", modeScript))
    if ok then
        return result
    else
        return false
    end
end

local function toggleDarkMode()
    local ok, result, description = hs.osascript.javascript(string.gsub([[(function() {
        ${script} = !${script}()
    })()]], "${script}", modeScript))
    if ok then
        refresh()
    else
        local log = hs.logger.new('toggleDarkMode', 'debug')
        log.i(description)
    end
end

-------------------------------------------------------------------
-- Toggle Desktop Icon
-------------------------------------------------------------------

local function isDesktopHidden()
    local comments = hs.fs.getFinderComments(desktopPath)
    return comments == "hidden"
end

local function toggleDesktopHidden()
    local isHidden = isDesktopHidden()
    if isHidden then
        for file in hs.fs.dir(desktopPath) do
            if string.sub(file, 1) ~= "." then
                os.execute(string.format("chflags %s %s/%s", "nohidden", desktopPath, file))
            end
        end
        hs.fs.setFinderComments(desktopPath, "hidden")
    else
        for file in hs.fs.dir(desktopPath) do
            if string.sub(file, 1) ~= "." then
                os.execute(string.format("chflags %s %s/%s", "hidden", desktopPath, file))
            end
        end
        hs.fs.setFinderComments(desktopPath, "")
    end
    refresh()
end

-------------------------------------------------------------------
-- Toggle Keep Awake
-------------------------------------------------------------------

local function isAmphetamineActived()
    return hs.caffeinate.get("displayIdle")
end

local function toggleAmphetamine()
    hs.caffeinate.toggle("displayIdle")
    refresh()
end

-------------------------------------------------------------------
-- Toggle Do Not Disturb
-------------------------------------------------------------------

local doNotDisturbProp = homePath.."/Library/Preferences/ByHost/com.apple.notificationcenterui"

local function isDoNotDisturb()
    local result, ok = hs.execute(string.gsub([[defaults -currentHost read ${prop} doNotDisturb -boolean]], "${prop}", doNotDisturbProp))
    if ok then
        return result:gsub("%s+", "") == "1"
    else
        return false
    end
end

local function toggleDoNotDisturb()
    local isNotDisturb = isDoNotDisturb()
    local task
    if isNotDisturb then
        os.execute(string.gsub([[
            defaults -currentHost write ${prop} doNotDisturb -boolean false
            killall NotificationCenter
        ]], "${prop}", doNotDisturbProp))
    else
        os.execute(string.gsub([[
            defaults -currentHost write $prop doNotDisturb -boolean true
            defaults -currentHost write $prop doNotDisturbDate -date "$date"
            killall NotificationCenter
        ]], "%$(%w+)", {prop = doNotDisturbProp, date = os.date("!%Y-%m-%d %X +0000", os.time())}))
    end
    refresh()
end

-------------------------------------------------------------------
-- MenuBar function
-------------------------------------------------------------------

refresh = function()
    menuData[1] = { title = "Switch Dark Mode", fn = toggleDarkMode, checked = isDarkMode() }
    menuData[2] = {title = '-'}
    menuData[3] = { title = "Hide Desktop Icon", fn = toggleDesktopHidden, checked = isDesktopHidden() }
    menuData[4] = {title = '-'}
    menuData[5] = { title = "Keep Awake", fn = toggleAmphetamine, checked = isAmphetamineActived() }
    menuData[6] = {title = '-'}
    menuData[7] = { title = "Do Not Disturb", fn = toggleDoNotDisturb, checked = isDoNotDisturb() }
    switchBar:setMenu(menuData)
end

refresh()
