local Generic = require 'shared.class'
local QBCore = exports['qb-core']:GetCoreObject()

---@class QBFrameworkServer : OxClass
local QBFrameworkServer = lib.class('QBFramework', Generic)

function QBFrameworkServer:contructor()
    self:super()
end

---Get Player object
---@param source string | integer @Player source or citizen ID
---@return table
function QBFrameworkServer:getPlayer(source)
    local QPlayer = tonumber(source) and QBCore.Functions.GetPlayer(source) or (
        QBCore.Functions.GetPlayerByCitizenId(source) or QBCore.Functions.GetOfflinePlayerByCitizenId(source))
    if not QPlayer then lib.print.warn(('Unable to get player %s').format(source)) end
    return QPlayer
end

---Notify one or more clients
---@param source table | string | integer
---@param msg string @Message to relay
---@param msgType string @['error', 'success', 'primary']
---@param duration integer @Duration in ms
function QBFrameworkServer:notify(source, msg, msgType, duration)
    if type(source) ~= "table" then source = {source} end
    for i = 1, #source do
        TriggerClientEvent('QBCore:Notify', source[i], msg, msgType, duration)
    end
end

---Remove money from a player
---@param source string | integer @Player source or citizen ID
---@param account? string
---@param amount integer
---@param note? string
---@return boolean @If amount was successfully taken from player
function QBFrameworkServer:removeMoney(source, account, amount, note)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return false end
    return QPlayer.Functions.RemoveMoney(account, amount, note)
end

---Check if player is loaded
---@param source string | integer @Player source or citizen ID
---@return boolean
function QBFrameworkServer:playerLoaded(source)
    local QPlayer = self:getPlayer(source)
    if not QPlayer then return false end
    return not QPlayer.Offline and Player(QPlayer.PlayerData.source).state.isLoggedIn
end

---QBCore Dispatch
---@class QBDispatch : OxClass
local QBDispatch = lib.class('QBDispatch', Generic)

QBFrameworkServer.dispatch = QBDispatch

return QBFrameworkServer
