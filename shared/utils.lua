local util = {
    --- Scans for started resource and returns a matching path
    --- @return string?
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

    --- Automatically detects the loaded framework
    --- @return string?
    getFramework = function(self)
        local supported = {
            esx = 'es_extended',
            qbcore = 'qb-core',
            qbox = 'qbx_core',
        }
        local found, _ = self:scanResources(supported)

        if found then
            local framework = require('modules.framework.' .. found .. '.' .. lib.context)
            return framework
        end

        if lib.context == 'server' then lib.print.error('No supported framework found') end
    end,

    --- Automatically detects dispatch system
    --- @return string?
    getDispatch = function(self)
        local supported = {
            cd = 'cd_dispatch',
            ps = 'ps_dispatch',
        }
        local found = self:scanResources(supported)

        if found then
            return require('modules.dispatch.' .. found .. '.' .. lib.context)
        else
            local framework = self:getFramework()
            if framework?.dispatch then
                lib.print.warn('No supported dispatch found. Falling back to framework dispatch. This will have limited functionality')
                return framework.dispatch
            end

            if lib.context == 'server' then lib.print.error('No supported dispatch found') end
        end
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