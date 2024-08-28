local classes = require 'shared.class'

--- ps-dispatch bridge class
--- @class Dispatch : DispatchClient
local PSDispatch = lib.class('PSDispatch', classes.DispatchClient)

function PSDispatch:constructor()
    self:super()
    self.resource = 'ps-dispatch'
    self.typeMap = {
        vehTheft = 'VehicleTheft',
        vehJacking = 'CarJacking',
        shooting = 'Shooting',
        shootingVeh = 'VehicleShooting',
        hunting = 'Hunting',
        speeding = 'SpeedingVehicle',
        fight = 'Fight',
        houseRobbery = 'HouseRobbery',
    }
end

---Sends a custom alert
---@param jobs table
---@param alertData table
function PSDispatch:customAlert(jobs, alertData)
    self:export('CustomAlert', {
        message = alertData.title or alertData.msg,
        code = alertData.code,
        icon = alertData.icon,
        priority = alertData.colour or alertData.color,
        coords = alertData.coords or GetEntityCoords(cache.ped),
        camId = alertData.cam,
        firstColor = alertData.vehicle?.colour?.primary,
        callsign = alertData.player?.callsign,
        name = alertData.player?.name,
        gender = alertData.player?.showGender,
        model = alertData.vehicle?.model,
        plate = alertData.vehicle?.plate,
        alertTime = alertData.time,
        doorCount = alertData.vehicle?.doors,
        automaticGunfire = alertData.automaticFire,
        radius = alertData.blip?.radius,
        recipientList = jobs,
        sprite = alertData.blip?.sprite,
        color = alertData.blip?.colour or alertData.blip?.color,
        scale = alertData.blip?.scale,
        length = alertData.time,
        flash = alertData.blip?.flash,
    })
end

--- Internal custom alert
--- @param job string | table
--- @param alertData table
function PSDispatch:_customAlert(job, alertData)
    -- alertData needs mapping
    alertData.job = bridge.framework.jobs[job]?.type
    self:export('CustomAlert', alertData)
end

--- Sends an alert to police
--- @param alertType string?
--- @param alertData table?
function PSDispatch:policeAlert(alertType, alertData)
    if alertType and self.typeMap[alertType] then
        self:export(self.typeMap[alertType])
    elseif alertData then
        self:customAlert(bridge.framework.jobs.police?.type, alertData)
    else
        lib.print.error('Unable to send dispatch')
    end
end

--- Sends an alert to EMS
--- @param alertType string?
--- @param alertData table?
function PSDispatch:emsAlert(alertType, alertData)
    if alertType and self.typeMap[alertType] then
        self:export(self.typeMap[alertType])
    elseif alertData then
        self:customAlert(bridge.framework.jobs.ems?.type, alertData)
    else
        lib.print.error('Unable to send dispatch')
    end
end

return PSDispatch
