local classes = require 'shared.class'
local ESX = exports.es_extended:getSharedObject()

---ESX
---@class ESXFramework : FrameworkClient
local ESXFramework = lib.class('ESXFramework', classes.FrameworkClient)

function ESXFramework:contructor()
    self:super()
end

function ESXFramework:notify(msg, msgType, duration)
    ESX.ShowNotification(msg, msgType == 'primary' and 'info' or msgType, duration)
end

function ESXFramework:playerLoaded()
    return ESX.IsPlayerLoaded()
end

function ESXFramework:isPlayerJob(job)
    local PlayerData = ESX.GetPlayerData()
    return PlayerData?.job?.name == job
end

function ESXFramework:hasMoney(account, amount)
    account = (account == 'cash') and 'money' or account
    local accData = ESX.GetAccount(account)
    if not accData then return false end
    return accData.money >= amount
end

---ESX Dispatch
---@class ESXDispatch : DispatchClient
local ESXDispatch = lib.class('ESXDispatch', classes.DispatchClient)

function ESXDispatch:constructor()
    self:super()
    self.typeMap = {}
end

function ESXDispatch:policeAlert(alertType, alertData)
    TriggerServerEvent('esx_service:notifyAllInService', alertData.title or alertData.msg, 'police')
end

function ESXDispatch:emsAlert(alertType, alertData)
    TriggerServerEvent('esx_service:notifyAllInService', alertData.title or alertData.msg, 'ambulance')
end

function ESXDispatch:customAlert(jobs, alertData)
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
