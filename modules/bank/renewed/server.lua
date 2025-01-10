local classes = lib.load('shared.class')

---@class RNBankingServer : BankingServer
local RNBankingServer = lib.class('RNBankingServer', classes.BankingServer)

function RNBankingServer:constructor()
    self:super()
    self.resource = 'Renewed-Banking'
end

function RNBankingServer:statement(data)
    self:export('handleTransaction', data.account, data.title, data.amount, data.message or '',
        data.type == 'deposit' and data.name or data.otherParty, data.type == 'deposit' and data.otherParty or data.name, data.type)
end

function RNBankingServer:deposit(data)
    self:export('addAccountMoney', data.account, data.amount)
    data.type = 'deposit'
    self:statement(data)
end

function RNBankingServer:withdraw(data)
    self:export('removeAccountMoney', data.account, data.amount)
    data.type = 'withdraw'
    self:statement(data)
end

function RNBankingServer:balance(account)
    return self:export('getAccountMoney', account)
end

function RNBankingServer:newAccount(data)
    --noop
    return false
end

return RNBankingServer
