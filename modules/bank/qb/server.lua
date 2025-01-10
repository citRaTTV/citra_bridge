local classes = lib.load('shared.class')

---@class QBBankingServer : BankingServer
local QBBankingServer = lib.class('QBBankingServer', classes.BankingServer)

function QBBankingServer:statement(data)
end

function QBBankingServer:deposit(data)
end

function QBBankingServer:withdraw(data)
end

function QBBankingServer:balance(account)
end

function QBBankingServer:newAccount(data)
end

return QBBankingServer
