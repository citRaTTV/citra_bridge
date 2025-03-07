local classes = lib.load('shared.class')
local util = lib.load('modules.util.server')
local config = lib.load('shared.config')
local QBCore = exports['qb-core']:GetCoreObject()

---@class QBFrameworkServer : FrameworkServer
local QBFrameworkServer = lib.class('QBFrameworkServer', classes.FrameworkServer)

function QBFrameworkServer:contructor()
    self:super()
    if config.notify == 'framework' then
        self.notifyMap = {
            warn = 'error',
            inform = 'primary',
        }
    end
end

function QBFrameworkServer:getPlayer(source)
    local QPlayer = (tonumber(source) and QBCore.Functions.GetPlayer(tonumber(source))) or QBCore.Functions.GetPlayerByCitizenId(source) or
        QBCore.Functions.GetOfflinePlayerByCitizenId(source)
    if not QPlayer then lib.print.warn(('Unable to get player %s'):format(source)) end
    return QPlayer
end

function QBFrameworkServer:getPlayerInfo(source)
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
            grade = tonumber(QPlayer.PlayerData?.gang?.grade?.level or 0)
        },
        id = QPlayer.PlayerData?.citizenid,
    }
end

function QBFrameworkServer:getPlayerJob(source)
    local QPlayer = self:getPlayer(source)
    return {
        name = QPlayer?.PlayerData?.job?.name,
        label = QBCore.Shared.Jobs[QPlayer?.PlayerData?.job?.name] or 'Unknown',
        type = QPlayer?.PlayerData?.job?.type,
        grade = tonumber(QPlayer?.PlayerData?.job?.grade?.level or 0),
        boss = QPlayer.PlayerData?.job?.isboss or false,
    }
end

function QBFrameworkServer:getJobInfo(name)
    return QBCore.Shared.Jobs[name]
end

function QBFrameworkServer:revive(source)
end

function QBFrameworkServer:notify(source, msg, msgType, duration)
    if config.notify == 'ox' then
        self:notifyOx(source, msg, msgType, duration)
        return
    end
    if type(source) ~= "table" then source = {source} end
    msg = (type(msg) == 'table' and (msg.title or msg.description) or msg)
    for i = 1, #source do
        TriggerClientEvent('QBCore:Notify', source[i], msg, (self.notifyMap[msgType] or msgType), duration)
    end
end

function QBFrameworkServer:isPlayerJob(source, job)
    local QPlayer = self:getPlayer(source)
    return (QPlayer and (QPlayer.PlayerData?.job?.name == job or QPlayer.PlayerData?.job?.type == job))
end

function QBFrameworkServer:isPlayerOnDuty(source)
    local QPlayer = self:getPlayer(source)
    return (QPlayer and QPlayer.PlayerData?.job?.onduty)
end

function QBFrameworkServer:setPlayerDuty(source, duty)
    local QPlayer = self:getPlayer(source)
    duty = duty or (not self:isPlayerOnDuty(source))
    QPlayer.Functions.SetJobDuty(duty)
    return duty
end

function QBFrameworkServer:getPlayerMeta(source, key)
    local QPlayer = self:getPlayer(source)
    return QPlayer?.Functions.GetMetaData(key)
end

function QBFrameworkServer:setPlayerMeta(source, key, value)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return end
    QPlayer.Functions.SetMetaData(key, value)
end

function QBFrameworkServer:addMoney(source, account, amount, note)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return false end
    return QPlayer.Functions.AddMoney(account, amount, note)
end

function QBFrameworkServer:removeMoney(source, account, amount, note)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return false end
    return QPlayer.Functions.RemoveMoney(account, amount, note)
end

function QBFrameworkServer:playerLoaded(source)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return false end
    return not QPlayer.Offline and Player(QPlayer.PlayerData.source).state.isLoggedIn
end

function QBFrameworkServer:getVehModelInfo(modelName)
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
        model = vehData?.name or 'Unknown Model',
        price = vehData?.price,
    }
end

function QBFrameworkServer:getPlayerVehs(source, colFilter)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return {} end
    return util.db.select('player_vehicles', colFilter, {{ key = 'citizenid', value = QPlayer.PlayerData.citizenid }})
end

function QBFrameworkServer:getOwnedVehs(colFilter, modelFilter)
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

function QBFrameworkServer:getOwnedVeh(plate, colFilter)
    local vehs = util.db.select('player_vehicles', colFilter, { key = 'plate', value = plate })
    return vehs and vehs[1]
end

function QBFrameworkServer:getOnDuty(job)
    local QPlayers = QBCore.Functions.GetQBPlayers()
    local count, players = 0, {}

    for source, QPlayer in pairs(QPlayers) do
        if QPlayer.PlayerData?.job.name == job then
            count += 1
            players[#players+1] = source
        end
    end

    return count, players
end

function QBFrameworkServer:getGangs()
    return QBCore.Shared.Gangs
end

function QBFrameworkServer:getJobs()
    return QBCore.Shared.Jobs
end

return QBFrameworkServer
