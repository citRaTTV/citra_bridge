local classes = require 'shared.class'

---qb-target
---@class QBTarget : TargetClient
local QBTarget = lib.class('QBTarget', classes.TargetClient)

function QBTarget:constructor()
    self:super()
    self.resource = 'qb-target'
end

---Convert options to qb-target format
---@param options table
---@return table qbOpts
---@private
function QBTarget:convertOptions(options)
    local qbOpts = {}
    for i = 1, #options do
        local opt = options[i]
        qbOpts[#qbOpts+1] = {
            num = opt.order,
            type = opt.event?.type,
            event = opt.event?.name,
            icon = opt.icon,
            label = opt.label,
            targeticon = opt.targeticon,
            item = opt.require?.item,
            action = opt.func,
            canInteract = opt.require?.func,
            job = opt.require?.job,
            gang = opt.require?.gang,
            citizenid = opt.require?.playerId,
        }
    end
    return qbOpts
end

function QBTarget:addEntity(entity, options, distance)
    if not DoesEntityExist(entity) then return end
    self:export('AddTargetEntity', entity, { options = self:convertOptions(options), distance = distance or 2.5 })
end

function QBTarget:removeEntity(entity, options)
    if not DoesEntityExist(entity) then return end
    self:export('RemoveTargetEntity', entity, options)
end

function QBTarget:addModels(models, options, distance)
    if type(models) ~= 'table' then models = { models } end
    self:export('AddTargetModel', models, { options = self:convertOptions(options), distance = distance or 2.5 })
end

function QBTarget:removeModels(models, options)
    if type(models) ~= 'table' then models = { models } end
    self:export('RemoveTargetModel', models, options)
end

function QBTarget:addVehicles(options, distance)
    self:export('AddGlobalVehicle', { options = self:convertOptions(options), distance = distance or 2.5 })
end

function QBTarget:removeVehicles(options)
    self:export('RemoveGlobalVehicle', options)
end

function QBTarget:addZone(zoneData, options, distance)
    if zoneData.type == 'poly' then
        self:export('AddPolyZone', zoneData.name, zoneData.points, {
            name = zoneData.name,
            minZ = zoneData.points[1].z - (zoneData.height / 2),
            maxZ = zoneData.points[1].z + (zoneData.height / 2),
        }, { options = self:convertOptions(options), distance = distance or 2.5 })
    elseif zoneData.type == 'box' then
        self:export('AddBoxZone', zoneData.name, zoneData.coords.xyz, zoneData.size.x, zoneData.size.y, {
            name = zoneData.name,
            heading = zoneData.coords.w,
            minZ = zoneData.coords.z - (zoneData.size.z / 2),
            maxZ = zoneData.coords.z + (zoneData.size.z / 2),
        }, { options = self:convertOptions(options), distance = distance or 2.5 })
    elseif zoneData.type == 'sphere' then
        self:export('AddCircleZone', zoneData.name, zoneData.coords.xyz, zoneData.radius, {
            name = zoneData.name
        }, { options = self:convertOptions(options), distance = distance or 2.5 })
    end
end

function QBTarget:removeZone(zoneName)
    self:export('RemoveZone', zoneName)
end

return QBTarget
