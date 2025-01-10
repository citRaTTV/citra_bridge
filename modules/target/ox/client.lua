local classes = lib.load('shared.class')

---ox_target
---@class OxTarget : TargetClient
local OXTarget = lib.class('OXTarget', classes.TargetClient)

function OXTarget:constructor()
    self:super()
    self.resource = 'ox_target'
end

---Convert options to ox_target format
---@param options table
---@return table oxOpts
---@private
function OXTarget:convertOptions(options, distance)
    local oxOpts = {}
    for i = 1, #options do
        local opt = options[i]
        oxOpts[#oxOpts+1] = {
            label = opt.label,
            icon = opt.icon,
            iconColor = opt.iconColour or opt.iconColor,
            distance = distance,
            groups = opt.require?.job or opt.require?.gang,
            items = opt.require?.item,
            canInteract = opt.require?.func,
            onSelect = opt.func and function(data)
                opt.func(data.entity, data)
            end,
            event = opt.event?.type == 'client' and opt.event?.name,
            serverEvent = opt.event?.type == 'server' and opt.event?.name,
            bones = opt.bones,
        }
    end
    return oxOpts
end

function OXTarget:addEntity(entity, options, distance)
    if not options or #options < 1 then return end
    local export = 'addLocalEntity'
    if NetworkGetEntityIsNetworked(entity) then
        entity = NetworkGetNetworkIdFromEntity(entity)
        export = 'addEntity'
    end
    self:export(export, entity, self:convertOptions(options, distance))
end

function OXTarget:removeEntity(entity, options)
    local export = 'removeLocalEntity'
    if NetworkGetEntityIsNetworked(entity) then
        entity = NetworkGetNetworkIdFromEntity(entity)
        export = 'removeEntity'
    end
    self:export(export, entity, options)
end

function OXTarget:addModels(models, options, distance)
    if not options or #options < 1 then return end
    self:export('addModel', models, self:convertOptions(options, distance))
end

function OXTarget:removeModels(models, options)
    self:export('removeModel', models, options)
end

function OXTarget:addVehicles(options, distance)
    if not options or #options < 1 then return end
    self:export('addGlobalVehicle', self:convertOptions(options, distance))
end

function OXTarget:removeVehicles(options)
    self:export('removeGlobalVehicle', options)
end

function OXTarget:addPeds(options, distance)
    if not options or #options < 1 then return end
    self:export('addGlobalPed', self:convertOptions(options, distance))
end

function OXTarget:removePeds(options)
    self:export('removeGlobalPed', options)
end

function OXTarget:addPlayers(options, distance)
    if not options or #options < 1 then return end
    self:export('addGlobalPlayer', self:convertOptions(options, distance))
end

function OXTarget:removePlayers(options)
    self:export('removeGlobalPlayer', options)
end

function OXTarget:addZone(zoneData, options, distance)
    if not options or #options < 1 then return end
    if zoneData.type == 'poly' then
        self:export('addPolyZone', {
            name = zoneData.name, points = zoneData.points, thickness = zoneData.height, options = self:convertOptions(options, distance)
        })
    elseif zoneData.type == 'box' then
        self:export('addBoxZone', {
            name = zoneData.name, coords = zoneData.coords.xyz, size = zoneData.size, rotation = zoneData.coords.w, options = self:convertOptions(options, distance)
        })
    elseif zoneData.type == 'sphere' then
        self:export('addSphereZone', {
            name = zoneData.name, coords = zoneData.coords.xyz, radius = zoneData.radius, options = self:convertOptions(options, distance)
        })
    end
end

function OXTarget:removeZone(zoneName)
    self:export('removeZone', zoneName)
end

return OXTarget
