local util = require 'shared.utils'

--- Generic super class
--- @class Generic : OxClass
local Generic = lib.class('Generic')

function Generic:constructor()
    self.util = util
    self.resource = ''
end

function Generic:export(...)
    util:runExport(self.resource, ...)
end

return Generic
