if GetCurrentResourceName() == 'citra_bridge' then
    if lib.context == 'server' then lib.versionCheck('citRaTTV/citra_bridge') end
    return
end

local utils = require 'shared.utils'

local function setupBridge()
    local framework = utils:getFramework()
    local dispatch = utils:getDispatch()

    return {
        framework = framework and framework:new(),
        dispatch = dispatch and dispatch:new(),
        util = utils:getUtil(),
    }
end

local bridge = setupBridge()

_ENV.bridge = bridge
