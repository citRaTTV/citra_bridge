local classes = lib.load('shared.class')
local util = lib.load('modules.util.server')
local qbx = exports.qbx_core

---@class QBXFrameworkServer : FrameworkServer
local QBXFrameworkServer = lib.class('QBXFrameworkServer', classes.FrameworkServer)

function QBXFrameworkServer:contructor()
    self:super()
    self.resource = 'qbx_core'
end

function QBXFrameworkServer:getPlayer(source)
    local QPlayer = tonumber(source) and qbx:GetPlayer(tonumber(source)) or (qbx:GetPlayerByCitizenId(source) or qbx:GetOfflinePlayer(source))
    if not QPlayer then lib.print.warn(('Unable to get player %s (%s)'):format(source, type(source))) end
    return QPlayer
end

function QBXFrameworkServer:getPlayerInfo(source)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return {} end
    return {
        name = {
            first = QPlayer.PlayerData?.charinfo?.firstname,
            last = QPlayer.PlayerData?.charinfo?.lastname,
        },
        job = self:getPlayerJob(source),
        gang = {
            name = QPlayer.PlayerData?.gang?.name,
            grade = QPlayer.PlayerData?.gang?.grade?.level
        },
        id = QPlayer.PlayerData?.citizenid,
    }
end

function QBXFrameworkServer:getPlayerJob(source)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return {} end
    local job = QPlayer.PlayerData?.job?.name
    local jobInfo = qbx:GetJob(job)
    return {
        name = job,
        label = jobInfo?.label,
        type = QPlayer.PlayerData?.job?.type,
        grade = QPlayer.PlayerData?.job?.grade?.level or 0,
        boss = QPlayer.PlayerData?.job?.isboss or false,
    }
end

function QBXFrameworkServer:getJobInfo(name)
    return qbx:GetJob(name)
end

function QBXFrameworkServer:revive(source)
    if GetResourceState('qbx_medical') ~= 'started' then return end
    exports.qbx_medical:Revive(source)
end

function QBXFrameworkServer:notify(...)
    self:notifyOx(...)
end

function QBXFrameworkServer:isPlayerJob(source, job)
    local QPlayer = self:getPlayer(source)
    return (QPlayer and (QPlayer.PlayerData?.job?.name == job or QPlayer.PlayerData?.job?.type == job))
end

function QBXFrameworkServer:isPlayerOnDuty(source)
    local QPlayer = self:getPlayer(source)
    return (QPlayer and QPlayer.PlayerData?.job?.onduty)
end

function QBXFrameworkServer:setPlayerDuty(source, duty)
    local QPlayer = self:getPlayer(source)
    duty = duty or (not self:isPlayerOnDuty(source))
    QPlayer.Functions.SetJobDuty(duty)
    return duty
end

function QBXFrameworkServer:getPlayerMeta(source, key)
    local QPlayer = self:getPlayer(source)
    return QPlayer?.Functions.GetMetaData(key)
end

function QBXFrameworkServer:setPlayerMeta(source, key, value)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return end
    QPlayer.Functions.SetMetaData(key, value)
end

function QBXFrameworkServer:addMoney(source, account, amount, note)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return false end
    return QPlayer.Functions.AddMoney(account, amount, note)
end

function QBXFrameworkServer:removeMoney(source, account, amount, note)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return false end
    return QPlayer.Functions.RemoveMoney(account, amount, note)
end

function QBXFrameworkServer:playerLoaded(source)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return false end
    return not QPlayer.Offline and Player(QPlayer.PlayerData.source).state.isLoggedIn
end

function QBXFrameworkServer:getVehModelInfo(modelName)
    local vehs = (type(modelName) == 'string') and qbx:GetVehiclesByName() or qbx:GetVehiclesByHash()
    local vehData = vehs and vehs[modelName]
    return {
        make = vehData?.brand or 'Unknown Make',
        model = vehData?.name or 'Unknown Model'
    }
end

function QBXFrameworkServer:getPlayerVehs(source, colFilter)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return {} end
    return util.db.select('player_vehicles', colFilter, {{ key = 'citizenid', value = QPlayer.PlayerData.citizenid }})
end

function QBXFrameworkServer:getOwnedVehs(colFilter, modelFilter)
    local mFilter = {}
    if modelFilter and #modelFilter > 0 then
        for i = 1, #modelFilter do
            mFilter[#mFilter+1] = {
                key = 'vehicle',
                value = modelFilter[i],
            }
        end
    end
    return util.db.select('player_vehicles', colFilter, mFilter)
end

function QBXFrameworkServer:getOwnedVeh(plate, colFilter)
    local vehs = util.db.select('player_vehicles', colFilter, { key = 'plate', value = plate })
    return vehs and vehs[1]
end

function QBXFrameworkServer:getOnDuty(job)
    return qbx:GetDutyCountJob(job)
end

function QBXFrameworkServer:getGangs()
    return qbx:GetGangs()
end

function QBXFrameworkServer:getJobs()
    return qbx:GetJobs()
end

return QBXFrameworkServer
