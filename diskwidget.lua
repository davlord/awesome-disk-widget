local gears = require("gears")
local gtable = gears.table
local wibox = require("wibox")
local disk = require("awesome-disk-widget.disk")

local diskwidget = { mt = {}}

local function round(value)
    return math.floor(value + 0.5)
end

local function format_size(b)
    local bytes = b
    if bytes == 0 then return "0 B" end
    local i, units = 1, { "B", "KB", "MB", "GB", "TB", "PB", "EB", "YB" }
    while bytes >= 1024 do
        bytes = bytes / 1024
        i = i + 1
    end
    local unit = units[ i ] or "?"
    return string.format("%s %s", round(bytes), unit)
end

function diskwidget:update()
    local disk_state = self._private.disk:get_state()
    local text = string.format("%s %s", disk_state.mountpoint, format_size(disk_state.free))
    self:set_text(text)
end

local function new(args)
    local w = wibox.widget.textbox()

    w._private.mountpoint = args.mountpoint
    w._private.disk = disk({ mountpoint=args.mountpoint})
    
    gtable.crush(w, diskwidget, true)

    return w
end

function diskwidget.mt:__call(...)
    return new(...)
end

return setmetatable(diskwidget, diskwidget.mt)