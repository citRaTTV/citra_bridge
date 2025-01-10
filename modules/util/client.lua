---@class Blip : OxClass
---@field coords table
---@field entity integer
---@field netId integer
---@field active boolean
---@field radius number
---@field sprite integer
---@field colour integer
---@field display integer
---@field alpha number
---@field flash boolean
---@field flashtime integer
---@field pulse boolean
---@field label string
---@field scale number
---@field shortRange boolean
---@field showHeading boolean
---@field number number
---@field category integer?
local Blip = lib.class('Blip')

---Spawn blip
function Blip:create()
    local blip
    if self.coords then
        blip = AddBlipForCoord(self.coords.x, self.coords.y, self.coords.z)
        if self.radius then
            self._radiusBlip = AddBlipForRadius(self.coords.x, self.coords.y, self.coords.z, self.radius)
            SetBlipColour(self._radiusBlip, self.colour)
            SetBlipAlpha(self._radiusBlip, self.alpha)
        end
    elseif self.entity then
        blip = AddBlipForEntity(self.entity)
        if self.showHeading then
            ShowHeadingIndicatorOnBlip(blip, true)
        end
    elseif self.netId then
        self.active = true
        self:entityWatcher()
        return
    else
        return
    end
    if self.showHeading and (self.coords?.w or self.entity) then
        ShowHeadingIndicatorOnBlip(blip, true)
        if not self.entity then
            SetBlipRotation(blip, self.coords.w)
        end
    end
    self.active = true
    self._blip = blip
    self:update()
end

function Blip:update()
    local blip = self._blip
    if self.sprite then SetBlipSprite(blip, self.sprite) end
    if self.colour then SetBlipColour(blip, self.colour) end
    if self.display then SetBlipDisplay(blip, self.display) end
    if self.alpha then SetBlipAlpha(blip, self.alpha) end
    if self.shortRange then SetBlipAsShortRange(blip, true) end
    SetBlipFlashes(blip, self.flash)
    if self.flash then SetBlipFlashInterval(blip, self.flashtime or 1000) end
    if self.pulse then PulseBlip(blip) end
    if self.category then SetBlipCategory(blip, self.category) end
    if self.number then ShowNumberOnBlip(blip, self.number) end
    SetBlipScale(blip, self.scale or 1.0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(self.label)
    EndTextCommandSetBlipName(blip)
end

---Despawn blip
function Blip:delete()
    self.active = false
    if not self._blip then return end
    self:disableRoute()
    RemoveBlip(self._blip)
    if self._radiusBlip then RemoveBlip(self._radiusBlip) end
    self._blip = nil
end

function Blip:updateCoords(coords)
    if not self._blip then return end
    self.coords = coords
    SetBlipCoords(self._blip, coords.x, coords.y, coords.z)
    if coords.w then SetBlipRotation(self._blip, math.ceil(coords.w)) end
end

function Blip:updateSprite(sprite)
    if not self._blip then return end
    self.sprite = sprite
    self:update()
end

function Blip:updateColour(colour)
    if not self._blip then return end
    self.colour = colour
    self:update()
end

---Toggle flash state of blip
function Blip:toggleFlash()
    if not self._blip then return end
    self.flash = not self.flash
    self:update()
end

---Update blip lable
---@param label string
function Blip:setLabel(label)
    if not self._blip then return end
    self.label = label
    self:update()
end

---Enable route to blip
---@param colour integer
function Blip:enableRoute(colour)
    if not self._blip then return end
    SetBlipRoute(self._blip, true)
    SetBlipRouteColour(self._blip, colour)
end

---Disable route to blip
function Blip:disableRoute()
    if not self._blip then return end
    SetBlipRoute(self._blip, false)
end

---Watch to ensure blip on entity
---@protected
function Blip:entityWatcher()
    CreateThread(function()
        while self.active do
            if not self.entity and NetworkDoesEntityExistWithNetworkId(self.netId) then
                self.entity = NetworkGetEntityFromNetworkId(self.netId)
                self:create()
            elseif self.entity and not DoesEntityExist(self.entity) then
                local coords = lib.callback.await('citra_bridge:server:getEntityCoords', nil, self.netId)
                if coords then
                    self.entity = nil
                    self.coords = lib.callback.await('citra_bridge:server:getEntityCoords', nil, self.netId)
                    self:create()
                end
            elseif self.netId and not NetworkDoesEntityExistWithNetworkId(self.netId) then
                local coords = lib.callback.await('citra_bridge:server:getEntityCoords', nil, self.netId)
                if coords then self:updateCoords(coords) end
            end
            Wait(1000)
        end
    end)
end

return {
    blip = function(data)
        local blip = Blip:new()
        blip.label = data.label
        blip.entity = data.entity
        blip.netId = data.netId
        blip.active = true
        blip.coords = data.coords
        blip.radius = data.radius
        blip.sprite = data.sprite
        blip.colour = data.colour or data.color
        blip.display = data.display
        blip.alpha = data.alpha
        blip.flash = data.flash or false
        blip.pulse = data.pulse or false
        blip.shortRange = data.shortRange or false
        blip.flashtime = data.flashtime
        blip.scale = data.scale
        blip.showHeading = data.heading or data.showHeading or false
        blip.number = data.number
        blip.category = data.category
        blip:create()
        return blip
    end,
}
