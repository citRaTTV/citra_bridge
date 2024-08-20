local util = require 'shared.utils'

--- Generic super class
--- @class Generic : OxClass
local Generic = lib.class('Generic')

function Generic:constructor()
    self.util = util
    self.resource = ''
end

function Generic:export(func, ...)
    util:runExport(self.resource, func, ...)
end

---Generic framework class (client)
---@class FrameworkClient : Generic
local FrameworkClient = lib.class('FrameworkClient', Generic)

function FrameworkClient:constructor()
    self:super()
    self.notifyMap = {
        warn = 'warning',
    }
end

---Notify using ox_lib
---@param msg string|{ title:string, description:string, position?:string, icon?:string } #Message to send
---@param msgType 'inform'|'success'|'warn'|'error'
---@param duration integer
function FrameworkClient:notifyOx(msg, msgType, duration)
    if type(msg) ~= 'table' then msg = { title = msg } end
    lib.notify({
        title = msg.title,
        description = msg.description,
        duration = duration,
        position = msg.position or 'center-right',
        type = self.notifyMap[msgType] or msgType,
        icon = msg.icon,
    })
end

---Notify player
---@param msg string|{ title:string, description:string, position?:string, icon?:string } #Message to send
---@param msgType 'inform'|'success'|'warn'|'error'
---@param duration integer #Duration in ms
function FrameworkClient:notify(msg, msgType, duration)
    self:notifyOx(msg, msgType, duration)
end

---Checks if player is loaded
---@return boolean isLoaded
function FrameworkClient:playerLoaded()
    return false
end

---Checks if player has specified job
---@param job string
---@return boolean hasJob
function FrameworkClient:isPlayerJob(job)
    return false
end

---Checks if player has enough money
---@param account 'cash'|'bank'
---@param amount number
---@return boolean hasMoney
function FrameworkClient:hasMoney(account, amount)
    return false
end

---Generic framework class (server)
---@class FrameworkServer : Generic
local FrameworkServer = lib.class('FrameworkServer', Generic)

function FrameworkServer:constructor()
    self:super()
    self.notifyMap = {
        warn = 'warning',
    }
end

---Get Player object
---@param source string | integer #Player source or identifier
---@return table
function FrameworkServer:getPlayer(source)
    return {}
end

---Check if player is loaded
---@param source string | integer #Player source or identifier
---@return boolean isLoaded
function FrameworkServer:playerLoaded(source)
    return false
end

---Get player job
---@param source string|integer
---@return { name:string?, type:string?, grade:integer? }
function FrameworkServer:getPlayerJob(source)
    return {
        name = nil,
        type = nil,
        grade = nil,
    }
end

---Notify using ox_lib
---@param msg string|{ title:string, description:string, position?:string, icon?:string } #Message to send
---@param msgType 'inform'|'success'|'warn'|'error'
---@param duration integer
function FrameworkServer:notifyOx(source, msg, msgType, duration)
    if type(msg) ~= 'table' then msg = { title = msg } end
    if type(source) ~= 'table' then source = { source } end
    for i = 1, #source do
        TriggerClientEvent('ox_lib:notify', source[i], {
            title = msg.title,
            description = msg.description,
            duration = duration,
            position = msg.position or 'center-right',
            type = self.notifyMap[msgType] or msgType,
            icon = msg.icon,
        })
    end
end

---Notify one or more clients
---@param source table | string | integer
---@param msg string|{ title:string, description:string, position?:string, icon?:string } #Message to send
---@param msgType 'inform'|'success'|'warn'|'error'
---@param duration integer #Duration in ms
function FrameworkServer:notify(source, msg, msgType, duration)
    self:notifyOx(source, msg, msgType, duration)
end

---Checks if player has a job
---@param source string | number
---@param job string #Job name or type
---@return boolean hasJob
function FrameworkServer:isPlayerJob(source, job)
    return false
end

---Add money to a player
---@param source string | integer #Player source or identifier
---@param account? string
---@param amount integer
---@param note? string
---@return boolean
function FrameworkServer:addMoney(source, account, amount, note)
    return false
end

---Remove money from a player
---@param source string | integer #Player source or identifier
---@param account? string
---@param amount integer
---@param note? string
---@return boolean success
function FrameworkServer:removeMoney(source, account, amount, note)
    return false
end

---Get vehicle model info
---@param modelName string #Vehicle model name (ie 'casco')
---@return { make:string, model:string }
function FrameworkServer:getVehModelInfo(modelName)
    return {
        make = 'Unknown Make',
        model = 'Unknown Model',
    }
end

---Get player vehicles
---@param source string|number #Player source or identifier
---@param colFilter string[]? #Filter columns
---@return table vehicles
function FrameworkServer:getPlayerVehs(source, colFilter)
    return {}
end

---Get owned vehicles
---@param colFilter string[]? #Filter columns
---@param modelFilter string[]? #Filter models
---@return table vehicles
function FrameworkServer:getOwnedVehs(colFilter, modelFilter)
    return {}
end

---Get vehicle by plate
---@param plate string
---@param colFilter string[]? #Filter columns
---@return table? vehicle
function FrameworkServer:getOwnedVeh(plate, colFilter)
    return {}
end

---Generic Dispatch class (client)
---@class DispatchClient : Generic
local DispatchClient = lib.class('DispatchClient', Generic)

function DispatchClient:constructor()
    self:super()
end

---Sends a custom alert
---@param jobs table
---@param alertData table
function DispatchClient:customAlert(jobs, alertData)
end

---Sends an alert to police
---@param alertType string?
---@param alertData table?
function DispatchClient:policeAlert(alertType, alertData)
end

---Sends an alert to EMS
---@param alertType string?
---@param alertData table?
function DispatchClient:emsAlert(alertType, alertData)
end

---Generic target class (client)
---@class TargetClient : Generic
local TargetClient = lib.class('TargetClient', Generic)

function TargetClient:constructor()
    self:super()
end

---Add an entity target
---@param entity integer
---@param options table
---@param distance number?
function TargetClient:addEntity(entity, options, distance)
end

---Remove an entity target
---@param entity integer
---@param options table? #If not specified, will remove all options
function TargetClient:removeEntity(entity, options)
end

---Add model targets
---@param models table|string|integer
---@param options table
---@param distance number?
function TargetClient:addModels(models, options, distance)
end

---Remove model targets
---@param models table|string|integer
---@param options table? #If not specified, will remove all options
function TargetClient:removeModels(models, options)
end

---Add vehicle targets
---@param options table
---@param distance number?
function TargetClient:addVehicles(options, distance)
end

---Remove vehicle targets
---@param options table? #If not specified, will remove all options
function TargetClient:removeVehicles(options)
end

---Add a zone target
---@param zoneData { name:string, type:'poly'|'box'|'sphere', coords:vector4, radius?:number, size?:vector3, points?:vector3[], height?:number }
---@param options any
---@param distance any
function TargetClient:addZone(zoneData, options, distance)
end

---Remove a zone target
---@param zoneName string
function TargetClient:removeZone(zoneName)
end

return {
    Generic = Generic,
    FrameworkClient = FrameworkClient,
    FrameworkServer = FrameworkServer,
    DispatchClient = DispatchClient,
    TargetClient = TargetClient,
}
