local setmetatable = setmetatable
local math = math
local table = table
local lgi = require "lgi"
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local GTop = lgi.GTop
local diskwidget = require("awesome-disk-widget.diskwidget")

local disk_widget = { mt = {} }

function disk_widget:update_widgets()
    for _, w in ipairs(self._private.disk_widgets) do
        w:update()
    end
end

function disk_widget:update_tooltip()
end

function disk_widget:update()
    self:update_widgets()
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
        }
    }

    GTop.glibtop_init()

    w._private.disk_widgets = {}
    for _, mp in ipairs(args.mountpoints) do
        local dw = diskwidget({
            mountpoint=mp
        })
        table.insert(w._private.disk_widgets, dw)
        w:add(dw)
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