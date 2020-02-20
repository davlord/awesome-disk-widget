local gtable = require("gears").table
local lgi = require("lgi")
local GTop = lgi.GTop

local disk = { mt = {} }

function disk:get_state()
    GTop.glibtop_get_fsusage(self.fs, self.mountpoint)

    return {
        mountpoint = self.mountpoint,
        free = self.fs.bavail * self.fs.block_size
    }
end

local function new(args)

    local d = {
        mountpoint = args.mountpoint,
        fs = GTop.glibtop_fsusage()
    }

    gtable.crush(d, disk, true)

    return d
end

function disk.mt:__call(...)
    return new(...)
end

return setmetatable(disk, disk.mt)