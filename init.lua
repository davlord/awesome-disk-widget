local setmetatable = setmetatable
local math = math
local table = table
local lgi = require "lgi"
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local GTop = lgi.GTop
local disk = require("awesome-disk-widget.disk")

local disk_widget = { mt = {} }

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

function disk_widget:update_text()

    local text_parts = {}

    for _, d in ipairs(self._private.disks) do
        local disk_state = d:get_state()
        local text = string.format("%s %s", disk_state.mountpoint, format_size(disk_state.free))
        table.insert(text_parts, text)
	end

    self.textbox:set_text(table.concat(text_parts, "  "))
end

function disk_widget:update_tooltip()
end

function disk_widget:update()
    self:update_text()
    self:update_tooltip()
end

local function new(args)

    local w = wibox.widget {
        layout = wibox.layout.fixed.horizontal,
        spacing = 4,
        {
            id = "iconbox",
            widget = wibox.widget.textbox,
            font = "FontAwesome 12",
            text = ""
        },
        {
            id = "textbox",
            widget = wibox.widget.textbox,
        }  
    }

    GTop.glibtop_init()

    w._private.disks = {}
    for _, mp in ipairs(args.mountpoints) do
        local d = disk({
            mountpoint=mp
        })
        table.insert(w._private.disks, d)
	end

    w.tooltip = awful.tooltip({ objects = { w },})

    gears.table.crush(w, disk_widget, true)

    local update_timer = gears.timer {
        timeout   = 15,
        callback = function() w:update() end
    }
    update_timer:start()

    w:update()

    return w
end

function disk_widget.mt:__call(...)
    return new(...)
end

return setmetatable(disk_widget, disk_widget.mt)