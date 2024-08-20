local classes = require 'shared.class'

--- CD Dispatch
--- @class CDDispatch : DispatchClient
local CDDispatch = lib.class('Dispatch', classes.DispatchClient)

function CDDispatch:constructor()
    self:super()
    self.resource = 'cd_dispatch'
    self.typeMap = {}
end

---Internal custom alert
function CDDispatch:customAlert(jobs, alertData)
    local data = self:export('GetPlayerInfo')
    TriggerServerEvent(self.resource .. ':AddNotification', {
        job_table = jobs,
        coords = alertData.coords or GetEntityCoords(cache.ped),
        title = alertData.title or alertData.msg,
        message = ("%s (%s on %s)"):format(alertData.msg, alertData.player?.showGender and data.sex or 'Unknown', data.street),
        flash = 0,
        unique_id = data?.unique_id,
        sound = alertData.sound,
        blip = {
            sprite = alertData.blip?.sprite,
            scale = alertData.blip?.scale,
            colour = alertData.blip?.colour or alertData.blip?.color,
            flashes = alertData.blip?.flash or false,
            text = alertData.title or 'Dispatch Alert',
            time = alertData.time,
            radius = alertData.blip?.radius or 0,
        }
    })
end

--- Sends an alert to police
--- @param alertType string
--- @param alertData any
function CDDispatch:policeAlert(alertType, alertData)
    self:customAlert({bridge.framework.jobs.police?.names}, alertData)
end

--- Sends an alert to EMS
--- @param alertType string
--- @param alertData any
function CDDispatch:emsAlert(alertType, alertData)
    self:customAlert({bridge.framework.jobs.ems?.names}, alertData)
end

return CDDispatch
