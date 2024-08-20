local util = {
    --- Scans for started resource and returns a matching path
    --- @return Generic?
    --- @private
    scanResources = function(self, tbl)
        for path, resource in pairs(tbl) do
            if GetResourceState(resource) ~= 'missing' then return path end
        end

        return nil
    end,

    --- Runs an export
    --- @param resource string
    --- @param func string
    --- @return any
    runExport = function(self, resource, func, ...)
        return exports[resource][func](nil, ...)
    end,

    ---Get module by type
    ---@param self table
    ---@param name string
    ---@param supported table
    ---@return Generic?
    ---@private
    getModule = function(self, name, supported)
        local found, _ = self:scanResources(supported)
        local parentPath = found and ("modules.%s.%s"):format(name, found)

        if parentPath then
            local forContext = pcall(lib.load, (("%s.%s"):format(parentPath, lib.context)))
            return forContext and require(("%s.%s"):format(parentPath, lib.context)) or nil
        end

        if lib.context == 'server' then lib.print.error('No supported ' .. name .. ' found') end
    end,

    --- Automatically detects the loaded framework
    --- @return string?
    getFramework = function(self)
        return self:getModule('framework', {
            esx = 'es_extended',
            qbcore = 'qb-core',
            qbox = 'qbx_core',
        })
    end,

    --- Automatically detects dispatch system
    --- @return string?
    getDispatch = function(self)
        return self:getModule('dispatch', {
            cd = 'cd_dispatch',
            ps = 'ps-dispatch',
        })
    end,

    end,

    --- Get util functions
    --- @return table
    getUtil = function(self)
        return require('modules.util.' .. lib.context)
    end,
}

setmetatable(util, {
    __index = util,
})

return util
