local classes = require 'shared.class'
local config = require 'shared.config'
local ESX = exports.es_extended:getSharedObject()

---@class ESXFrameworkServer : FrameworkServer
local ESXFrameworkServer = lib.class('ESXFramework', classes.FrameworkServer)

function ESXFrameworkServer:contructor()
    self:super()
    if config.notify == 'framework' then
        self.notifyMap = {
            warn = 'error',
            inform = 'info',
        }
    end
end

function ESXFrameworkServer:getPlayer(source)
    local xPlayer = tonumber(source) and ESX.GetPlayerFromId(source) or ESX.GetPlayerFromIdentifier(source)
    if not xPlayer then lib.print.warn(('Unable to get player %s').format(source)) end
    return xPlayer
end

function ESXFrameworkServer:playerLoaded(source)
    return (self:getPlayer(source) ~= nil)
end

function ESXFrameworkServer:getPlayerJob(source)
    local xPlayer = self:getPlayer(source)
    if not xPlayer then return {} end
    local job = xPlayer.getJob()
    return {
        name = job?.name,
        type = nil,
        grade = job?.grade,
    }
end

function ESXFrameworkServer:notify(source, msg, msgType, duration)
    if config.notify == 'ox' then
        self:notifyOx(source, msg, msgType, duration)
        return
    end
    if type(source) ~= 'table' then source = { source } end
    msg = (type(msg) == 'table' and (msg.title or msg.description) or msg)
    for i = 1, #source do
        TriggerClientEvent('esx:showNotification', source[i], msg, (self.notifyMap[msgType] or msgType), duration)
    end
end

function ESXFrameworkServer:isPlayerJob(source, job)
    local plyJob = self:getPlayerJob(source)
    return plyJob.name == job
end

function ESXFrameworkServer:removeMoney(source, account, amount, note)
    local xPlayer = self:getPlayer(source)
    if not xPlayer then return false end
    account = (account == 'cash') and 'money' or account
    local accData = xPlayer.getAccount(account)
    if accData.money >= amount then
        xPlayer.removeAccountMoney(account, amount)
        return true
    end
    return false
end

return ESXFrameworkServer
