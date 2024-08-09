local Generic = require 'shared.class'
local ESX = exports.es_extended:getSharedObject()

---@class ESXFramework : OxClass
local ESXFramework = lib.class('ESXFramework', Generic)

function ESXFramework:contructor()
    self:super()
end

---Get Player object
---@param source string | integer @Player source or citizen ID
---@return table
function ESXFramework:getPlayer(source)
    local xPlayer = tonumber(source) and ESX.GetPlayerFromId(source) or ESX.GetPlayerFromIdentifier(source)
    if not xPlayer then lib.print.warn(('Unable to get player %s').format(source)) end
    return xPlayer
end

---Remove money from a player
---@param source string | integer @Player source or citizen ID
---@param account? string
---@param amount integer
---@param note? string
---@return boolean @If amount was successfully taken from player
function ESXFramework:removeMoney(source, account, amount, note)
    local xPlayer = self:getPlayer(source)
    if not xPlayer then return false end
    account = account == 'cash' and 'money' or account
    local acc = xPlayer.getAccount(account)
    if acc.money >= amount then
        xPlayer.removeAccountMoney(account, amount)
        return true
    end
    return false
end

---Check if player is loaded
---@param source string | integer @Player source or citizen ID
---@return boolean
function ESXFramework:playerLoaded(source)
    return true
end

---QBCore Dispatch
---@class ESXDispatch : OxClass
local ESXDispatch = lib.class('ESXDispatch', Generic)

ESXFramework.dispatch = ESXDispatch

return ESXFramework
