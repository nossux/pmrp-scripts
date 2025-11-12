return {
    _towTrucks = {
        ["flatbed"] = {
            position = 2.0,
            height = 0.4,
        },
        ["rollback2"] = {
            position = 1.4,
            height = 0.4,
        },
        ["rollback4"] = {
            position = 1.4,
            height = 0.2,
        },
    },

    _bannedClasses = {
        [15] = false, -- heli
        [16] = true,  -- planes
    },

    _dotVehicles = {
        ["Alabama Department Of Transportation"] = {
            vehicles = {
                -- { name = "Rollback Tow Truck",          model = "rollback2" },
                { name = "Rollback Tow Truck", model = "rollback4" },
            }
        },
    }
}
