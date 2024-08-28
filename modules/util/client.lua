---@class Blip
---@field coords table
---@field entity integer
---@field radius number
---@field sprite integer
---@field colour integer
---@field display integer
---@field alpha number
---@field flash boolean
---@field flashtime integer
---@field label string
---@field scale number
---@field shortRange boolean
local Blip = {}

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
    else
        return
    end
    if self.sprite then SetBlipSprite(blip, self.sprite) end
    if self.colour then SetBlipColour(blip, self.colour) end
    if self.display then SetBlipDisplay(blip, self.display) end
    if self.alpha then SetBlipAlpha(blip, self.alpha) end
    if self.shortRange then SetBlipAsShortRange(blip, true) end
    SetBlipFlashes(blip, self.flash)
    if self.flash then SetBlipFlashInterval(blip, self.flashtime or 1000) end
    SetBlipScale(blip, self.scale or 1.0)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName(self.label)
    EndTextCommandSetBlipName(blip)
    self._blip = blip
end

---Despawn blip
function Blip:delete()
    if not self._blip then return end
    self:disableRoute()
    RemoveBlip(self._blip)
    if self._radiusBlip then RemoveBlip(self._radiusBlip) end
    self._blip = nil
end

---Toggle flash state of blip
function Blip:toggleFlash()
    if not self._blip then return end
    self.flash = not self.flash
    SetBlipFlashes(self._blip, self.flash)
end

---Update blip lable
---@param label string
function Blip:setLabel(label)
    if not self._blip then return end
    self.label = label
    BeginTextCommandSetBlipName(self.label)
    AddTextComponentSubstringBlipName(self._blip)
    EndTextCommandSetBlipName(self._blip)
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

setmetatable(Blip, {
    __index = function(self, key)
        return rawget(self, key)
    end,
    __call = function(self, data)
        data = data or {}
        self.label = data.label
        self.entity = data.entity
        self.coords = data.coords
        self.radius = data.radius
        self.sprite = data.sprite
        self.colour = data.colour or data.color
        self.display = data.display
        self.alpha = data.alpha
        self.flash = data.flash or false
        self.shortRange = data.shortRange or false
        self.flashtime = data.flashtime
        self.scale = data.scale
        self:create()
        return self
    end,
})

return {
    blip = Blip,
}
