local Generic = require 'shared.class'
local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('QBCore:Client:UpdateObject', function()
    QBCore = exports['qb-core']:GetCoreObject()
end)

---QBCore
---@class QBFramework : OxClass
local QBFramework = lib.class('QBFramework', Generic)

function QBFramework:contructor()
    self:super()
end

function QBFramework:notify(msg, msgType, duration)
    QBCore.Functions.Notify(msg, msgType, duration)
end

function QBFramework:playerLoaded()
    return LocalPlayer.state.isLoggedIn
end

---QBCore Dispatch
---@class QBDispatch : OxClass
local QBDispatch = lib.class('QBDispatch', Generic)

function QBDispatch:constructor()
    self:super()
    self.typeMap = {}
end

---Sends an alert to police
---@param self Dispatch
---@param alertType string?
---@param alertData any
function QBDispatch:policeAlert(alertType, alertData)
    TriggerServerEvent('police:server:policeAlert', alertData.title or alertData.msg)
end

---Sends an alert to EMS
---@param self Dispatch
---@param alertType string?
---@param alertData any
function QBDispatch:emsAlert(alertType, alertData)
    TriggerServerEvent('hospital:server:ambulanceAlert', alertData.title or alertData.msg)
end

---Sends a custom alert
---@param jobs table
---@param alertData table
function QBDispatch:CustomAlert(jobs, alertData)
    for i = 1, #jobs do
        if jobs[i] == 'police' then
            self:policeAlert(nil, alertData)
        elseif jobs[i] == 'ems' then
            self:emsAlert(nil, alertData)
        end
    end
end

QBFramework.dispatch = QBDispatch

return QBFramework
