local classes = lib.load('shared.class')
local config = lib.load('shared.config')
local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('QBCore:Client:UpdateObject', function()
    QBCore = exports['qb-core']:GetCoreObject()
end)

---QBCore
---@class QBFramework : FrameworkClient
local QBFramework = lib.class('QBFramework', classes.FrameworkClient)
QBFramework.jobs = {
    police = {
        names = json.decode(GetConvar('citRa:framework:policejobs', "['police']")),
        type = 'leo',
    },
}

function QBFramework:contructor()
    self:super()
    if config.notify == 'framework' then
        self.notifyMap = {
            warn = 'error',
            inform = 'primary',
        }
    end
end

function QBFramework:notify(msg, msgType, duration)
    if config.notify == 'ox' then
        self:notifyOx(msg, msgType, duration)
        return
    end
    msg = (type(msg) == 'table' and (msg.title or msg.description) or msg)
    QBCore.Functions.Notify(msg, (self.notifyMap[msgType] or msgType), duration)
end

function QBFramework:playerLoaded()
    return LocalPlayer.state.isLoggedIn
end

function QBFramework:getVehModelInfo(modelName)
    local vehData = QBCore.Shared.Vehicles[modelName]
    if type(modelName) == 'number' then
        for _, data in pairs(QBCore.Shared.Vehicles) do
            if data.hash == modelName then
                vehData = data
                break
            end
        end
    end
    return {
        make = vehData?.brand or 'Unknown Make',
        model = vehData?.name or 'Unknown Model'
    }
end

function QBFramework:isPlayerJob(job)
    local PlayerData = QBCore.Functions.GetPlayerData()
    return (PlayerData.job?.name == job or PlayerData.job?.type == job)
end

function QBFramework:getPlayerJob()
    local PlayerData = QBCore.Functions.GetPlayerData()
    return {
        name = PlayerData.job?.name,
        label = PlayerData.job?.label,
        type = PlayerData.job?.type,
        grade = tonumber(PlayerData.job?.grade.level) or 0,
        boss = PlayerData.job?.isboss or false,
    }
end

function QBFramework:hasMoney(account, amount)
    local PlayerData = QBCore.Functions.GetPlayerData()
    return (PlayerData.money?[account] or 0) > amount
end

function QBFramework:weatherSync(toggle)
    TriggerEvent('qb-weathersync:client:' .. (toggle and 'Enable' or 'Disable') .. 'Sync')
end

function QBFramework:getJobInfo(name)
    return QBCore.Shared.Jobs[name]
end

function QBFramework:toggleDuty()
    TriggerServerEvent('QBCore:ToggleDuty')
end

function QBFramework:wearingGloves()
    return QBCore.Functions.IsWearingGloves()
end

function QBFramework:isBleeding()
    local p = promise:new()
    local bleeding = false
    QBCore.Functions.TriggerCallback('hospital:GetPlayerBleeding', function(isBleeding)
        bleeding = isBleeding
        p:resolve()
    end)
    Citizen.Await(p)
    return bleeding
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
