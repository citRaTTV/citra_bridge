local Generic = require 'shared.class'
local ESX = exports.es_extended:getSharedObject()

---ESX
---@class ESXFramework : OxClass
local ESXFramework = lib.class('ESXFramework', Generic)

function ESXFramework:contructor()
    self:super()
end

function ESXFramework:notify(msg, msgType, duration)
    ESX.ShowNotification(msg, msgType == 'primary' and 'info' or msgType, duration)
end

function ESXFramework:playerLoaded()
    return ESX.IsPlayerLoaded()
end

---ESX Dispatch
---@class ESXDispatch : OxClass
local ESXDispatch = lib.class('ESXDispatch', Generic)

function ESXDispatch:constructor()
    self:super()
    self.typeMap = {}
end

---Sends an alert to police
---@param self Dispatch
---@param alertType string?
---@param alertData any
function ESXDispatch:policeAlert(alertType, alertData)
    TriggerServerEvent('esx_service:notifyAllInService', alertData.title or alertData.msg, 'police')
end

---Sends an alert to EMS
---@param self Dispatch
---@param alertType string?
---@param alertData any
function ESXDispatch:emsAlert(alertType, alertData)
    TriggerServerEvent('esx_service:notifyAllInService', alertData.title or alertData.msg, 'ambulance')
end

---Sends a custom alert
---@param jobs table
---@param alertData table
function ESXDispatch:CustomAlert(jobs, alertData)
    for i = 1, #jobs do
        if jobs[i] == 'police' then
            self:policeAlert(nil, alertData)
        elseif jobs[i] == 'ems' then
            self:emsAlert(nil, alertData)
        end
    end
end

ESXFramework.dispatch = ESXDispatch

return ESXFramework
