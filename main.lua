if GetCurrentResourceName() == 'citra_bridge' then
    if lib.context == 'server' then lib.versionCheck('citRaTTV/citra_bridge') end
    return
end

local utils = require 'shared.utils'

local function setupBridge()
    local framework = utils:getFramework()
    local dispatch = utils:getDispatch()
    local target = utils:getTarget()

    return {
        framework = framework and framework:new(),
        dispatch = (dispatch and dispatch:new()) or (framework?.dispatch and framework.dispatch:new()),
        target = target and target:new(),
        util = utils:getUtil(),
    }
end

local bridge = setupBridge()

_ENV.bridge = bridge
