local classes = require 'shared.class'
local ESX = exports.es_extended:getSharedObject()

---@class ESXFrameworkServer : FrameworkServer
local ESXFrameworkServer = lib.class('ESXFramework', classes.FrameworkServer)

function ESXFrameworkServer:contructor()
    self:super()
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
    if type(source) ~= 'table' then source = { source } end
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
