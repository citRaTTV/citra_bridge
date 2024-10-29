local classes = require 'shared.class'

---@class PSDispatchServer : DispatchServer
local PSDispatchServer = lib.class('PSDispatchServer', classes.DispatchServer)

function PSDispatchServer:constructor()
    self:super()
    self.resource = 'ps-dispatch'
end

function PSDispatchServer:alert(alertData)
    TriggerEvent('ps-dispatch:server:notify', {
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
        vehicle = alertData.vehicle?.model,
        plate = alertData.vehicle?.plate,
        alertTime = alertData.time,
        doorCount = alertData.vehicle?.doors,
        automaticGunfire = alertData.automaticFire,
        alert = {
            radius = alertData.blip?.radius,
            recipientList = alertData.jobs,
            sprite = alertData.blip?.sprite,
            color = alertData.blip?.colour or alertData.blip?.color,
            scale = alertData.blip?.scale,
            length = alertData.time,
            flash = alertData.blip?.flash,
            sound = 'Lose_1st',
            sound2 = 'GTAO_FM_Events_Soundset',
            offset = "false",
        },
        jobs = alertData.jobs,
    })
end

return PSDispatchServer
