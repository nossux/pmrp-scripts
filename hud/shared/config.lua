currentAOP = "None Set"
usingPerms = true
AOPChangeNotification = true

peacetime = true
peacetimeNS = true
maxPTSpeed = 100

Config = {
    UpdateIntervals = {
        onFoot = 300,          -- 1 second when walking/running
        inVehicle = 50,        -- 150ms when in vehicle (smooth vehicle updates)
        compass = 250,          -- 250ms for compass updates
        aop = 2000,             -- 2 seconds for AOP checks
        health = 250,           -- 250ms for health/armor updates
    },
    
    Thresholds = {
        speed = 1,              -- Only update speed if changed by 1+ mph
        fuel = 1,               -- Only update fuel if changed by 1%
        health = 5,             -- Only update health if changed by 5+
        heading = 2,            -- Only update compass if heading changed by 2+ degrees
    }
}
