local classes = require 'shared.class'
local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('QBCore:Client:UpdateObject', function()
    QBCore = exports['qb-core']:GetCoreObject()
end)

---QBCore
---@class QBFramework : FrameworkClient
local QBFramework = lib.class('QBFramework', classes.FrameworkClient)

function QBFramework:contructor()
    self:super()
end

function QBFramework:notify(msg, msgType, duration)
    QBCore.Functions.Notify(msg, msgType, duration)
end

function QBFramework:playerLoaded()
    return LocalPlayer.state.isLoggedIn
end

---Check if player has job
---@param job string
---@return boolean
function QBFramework:isPlayerJob(job)
    local PlayerData = QBCore.Functions.GetPlayerData()
    return (PlayerData.job?.name == job or PlayerData.job?.type == job)
end

---Check if player has money
---@param account 'cash'|'bank'
---@param amount number
---@return boolean
function QBFramework:hasMoney(account, amount)
    local PlayerData = QBCore.Functions.GetPlayerData()
    return (PlayerData.money?[account] or 0) > amount
end

---QBCore Dispatch
---@class QBDispatch : DispatchClient
local QBDispatch = lib.class('QBDispatch', classes.DispatchClient)

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
function QBDispatch:customAlert(jobs, alertData)
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
