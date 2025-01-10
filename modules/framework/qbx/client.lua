local classes = lib.load('shared.class')
lib.load('@qbx_core.modules.lib')
lib.load('@qbx_core.modules.playerdata')

---QBCore
---@class QBXFramework : FrameworkClient
local QBXFramework = lib.class('QBXFramework', classes.FrameworkClient)
QBXFramework.jobs = {
    police = {
        names = json.decode(GetConvar('citRa:framework:policejobs', "['police']")),
        type = 'leo',
    },
}

function QBXFramework:contructor()
    self:super()
    self.resource = 'qbx_core'
end

function QBXFramework:notify(...)
    self:notifyOx(...)
end

function QBXFramework:playerLoaded()
    return LocalPlayer.state.isLoggedIn
end

function QBXFramework:getVehModelInfo(modelName)
    local vehs = (type(modelName) == 'string') and exports.qbx_core:GetVehiclesByName() or exports.qbx_core:GetVehiclesByHash()
    local vehData = vehs and vehs[modelName]
    return {
        make = vehData?.brand or 'Unknown Make',
        model = vehData?.name or 'Unknown Model'
    }
end

function QBXFramework:isPlayerJob(job)
    local plyJob = self:getPlayerJob()
    return plyJob.name == job or plyJob.type == job
end

function QBXFramework:getPlayerJob()
    local plyJob = QBX.PlayerData.job
    return {
        name = plyJob?.name,
        label = plyJob?.label,
        type = plyJob?.type,
        grade = plyJob?.grade?.level or 0,
        boss = plyJob?.isboss or false,
    }
end

function QBXFramework:getPlayerInfo()
    local plyData = QBX.PlayerData
    return {
        name = {
            first = plyData?.charinfo?.firstname,
            last = plyData?.charinfo?.lastname,
        },
        job = self:getPlayerJob(),
        gang = {
            name = plyData?.gang?.name,
            grade = plyData?.gang?.grade?.level
        },
        id = plyData?.citizenid,
    }
end

function QBXFramework:hasMoney(account, amount)
    local PlayerData = QBX.PlayerData
    return (PlayerData.money?[account] or 0) > amount
end

function QBXFramework:weatherSync(toggle)
    if GetResourceState('Renewed-WeatherSync') ~= 'missing' then
        LocalPlayer.state:set('syncWeather', toggle)
        return
    end
    TriggerEvent('qb-weathersync:client:' .. (toggle and 'Enable' or 'Disable') .. 'Sync')
end

function QBXFramework:getJobInfo(name)
    return exports.qbx_core:GetJob(name)
end

function QBXFramework:toggleDuty()
    TriggerServerEvent('QBCore:ToggleDuty')
end

function QBXFramework:wearingGloves()
    return qbx.isWearingGloves()
end

function QBXFramework:isBleeding()
    if GetResourceState('qbx_medical') == 'started' then
        return LocalPlayer.state['qbx_medical:bleedLevel'] > 0
    elseif GetResourceState('ars_ambulancejob') == 'started' then
        local injuries = LocalPlayer.state.injuries
        return injuries and next(injuries)
    end
    return false
end

---QBCore Dispatch
---@class QBXDispatch : DispatchClient
local QBXDispatch = lib.class('QBXDispatch', classes.DispatchClient)

function QBXDispatch:constructor()
    self:super()
    self.typeMap = {}
end

function QBXDispatch:policeAlert(alertType, alertData)
    TriggerServerEvent('police:server:policeAlert', alertData.title or alertData.msg)
end

function QBXDispatch:emsAlert(alertType, alertData)
    TriggerServerEvent('hospital:server:ambulanceAlert', alertData.title or alertData.msg)
end

function QBXDispatch:customAlert(jobs, alertData)
    for i = 1, #jobs do
        if jobs[i] == 'police' then
            self:policeAlert(nil, alertData)
        elseif jobs[i] == 'ems' then
            self:emsAlert(nil, alertData)
        end
    end
end

QBXFramework.dispatch = QBXDispatch

return QBXFramework
