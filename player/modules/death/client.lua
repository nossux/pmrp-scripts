DeathManager = {}
DeathManager.__index = DeathManager

local function playDeadAnimation()
    local playerPed = PlayerPedId()
    local deadAnimDict = 'dead'
    local deadAnim = 'dead_a'

    local deadVehAnimDict = 'veh@low@front_ps@idle_duck'
    local deadVehAnim = 'sit'

    local isInVehicle = IsPedInAnyVehicle(playerPed, false)
    
    if isInVehicle then
        if not HasAnimDictLoaded(deadVehAnimDict) then
            RequestAnimDict(deadVehAnimDict)
            while not HasAnimDictLoaded(deadVehAnimDict) do
                Wait(10)
            end
        end
        
        if not IsEntityPlayingAnim(playerPed, deadVehAnimDict, deadVehAnim, 3) then
            TaskPlayAnim(playerPed, deadVehAnimDict, deadVehAnim, 1.0, 1.0, -1, 1, 0, false, false, false)
        end
    else
        if not HasAnimDictLoaded(deadAnimDict) then
            RequestAnimDict(deadAnimDict)
            while not HasAnimDictLoaded(deadAnimDict) do
                Wait(10)
            end
        end
        
        if not IsEntityPlayingAnim(playerPed, deadAnimDict, deadAnim, 3) then
            TaskPlayAnim(playerPed, deadAnimDict, deadAnim, 1.0, 1.0, -1, 1, 0, false, false, false)
        end
    end
end

function DeathManager:new()
    local instance = {}
    setmetatable(instance, DeathManager)
    
    instance.isDead = false
    instance.deathTime = 0
    instance.reviveTimer = 60
    instance.holdTimer = 0
    instance.holdDuration = 3000
    instance.isHolding = false
    instance.canRevive = false
    
    return instance
end

function DeathManager:startDeath()
    if self.isDead then return end
    
    self.isDead = true
    self.deathTime = GetGameTimer()
    self.canRevive = false
    self.isHolding = false
    self.holdTimer = 0
    
    local playerPed = PlayerPedId()
    
    ClearPedTasks(playerPed)
    SetPedCanRagdoll(playerPed, false)
    
    SetEntityHealth(playerPed, 0)
    
    CreateThread(function()
        Wait(100)
        playDeadAnimation()
    end)
    
    self:showDeathScreen()
    
    print("You have died! Wait " .. self.reviveTimer .. " seconds before you can revive.")
end

function DeathManager:update()
    if not self.isDead then return end
    
    local playerPed = PlayerPedId()
    
    if GetEntityHealth(playerPed) > 0 then
        SetEntityHealth(playerPed, 0)
    end
    
    playDeadAnimation()
    
    SetPedCanRagdoll(playerPed, false)
    
    DisableAllControlActions(0)
    
    EnableControlAction(0, 1, true)   -- Camera LookLeftRight
    EnableControlAction(0, 2, true)   -- Camera LookUpDown
    EnableControlAction(0, 3, true)   -- Camera Zoom In
    EnableControlAction(0, 4, true)   -- Camera Zoom Out
    EnableControlAction(0, 5, true)   -- Camera Zoom In Alternative
    EnableControlAction(0, 6, true)   -- Camera Zoom Out Alternative
    
    EnableControlAction(0, 245, true) -- Chat
    EnableControlAction(0, 249, true) -- Push to talk
    
    if self.canRevive then
        EnableControlAction(0, 38, true) -- E
    end
    
    local currentTime = GetGameTimer()
    local timeSinceDeath = (currentTime - self.deathTime) / 1000
    local timeRemaining = math.max(0, self.reviveTimer - timeSinceDeath)
    
    self:updateDeathScreen(timeRemaining)
    
    if timeRemaining <= 0 and not self.canRevive then
        self.canRevive = true
        print("You can now hold E for 3 seconds to revive!")
    end
    
    if self.canRevive then
        self:handleReviveInput()
    end
end

function DeathManager:handleReviveInput()
    local isEPressed = IsControlPressed(0, 38) or IsDisabledControlPressed(0, 38)
    
    if isEPressed then
        if not self.isHolding then
            self.isHolding = true
            self.holdTimer = GetGameTimer()
            print("^3[DEBUG] Started holding E^0")
        end
        
        local holdTime = GetGameTimer() - self.holdTimer
        local progress = math.min(holdTime / self.holdDuration, 1.0)
        
        if holdTime % 500 < 50 then -- Print every half second
            print("^6[DEBUG] Hold progress: " .. math.floor(progress * 100) .. "%^0")
        end
        
        self:updateReviveProgress(progress)
        
        if holdTime >= self.holdDuration then
            print("^2[DEBUG] Hold completed, reviving player^0")
            self:revive()
        end
    else
        if self.isHolding then
            self.isHolding = false
            self.holdTimer = 0
            self:updateReviveProgress(0)
            print("^1[DEBUG] Stopped holding E^0")
        end
    end
    
    if self.canRevive then
        if IsControlJustPressed(0, 38) or IsDisabledControlJustPressed(0, 38) then
            print("^4[DEBUG] E key just pressed detected!^0")
        end
    end
end

function DeathManager:revive()
    if not self.isDead then return end
    
    local playerPed = PlayerPedId()
    local playerId = PlayerId()
    
    self.isDead = false
    self.canRevive = false
    self.isHolding = false
    self.holdTimer = 0
    
    NetworkResurrectLocalPlayer(296.0, -585.0, 42.0, 0.0, true, false)
    SetEntityHealth(playerPed, 200)
    SetPlayerControl(playerId, true, 0)
    
    ClearPedTasks(playerPed)
    
    self:hideDeathScreen()
    
    print("You have been revived!")
end

function DeathManager:showDeathScreen()
    print("^2[DEBUG] Showing death screen^0")
    SendNUIMessage({
        action = "showDeath",
        data = {
            timer = self.reviveTimer
        }
    })
    SetNuiFocus(false, false)
end

function DeathManager:updateDeathScreen(timeRemaining)
    SendNUIMessage({
        action = "updateTimer",
        data = {
            timer = math.floor(timeRemaining),
            canRevive = self.canRevive
        }
    })
end

function DeathManager:updateReviveProgress(progress)
    SendNUIMessage({
        action = "updateReviveProgress",
        data = {
            progress = progress
        }
    })
end

function DeathManager:hideDeathScreen()
    print("^2[DEBUG] Hiding death screen^0")
    SendNUIMessage({
        action = "hideDeath",
        data = {}
    })
end

function DeathManager:checkDeath()
    local playerPed = PlayerPedId()
    
    if IsPedFatallyInjured(playerPed) and not self.isDead then
        self:startDeath()
    elseif not IsPedFatallyInjured(playerPed) and self.isDead then
        self.isDead = false
        self.canRevive = false
        self.isHolding = false
        self:hideDeathScreen()
    end
end

local deathManager = DeathManager:new()

CreateThread(function()
    while true do
        deathManager:checkDeath()
        deathManager:update()
        Wait(0)
    end
end)

RegisterNetEvent('nos_death:admin:kill', function()
    deathManager:startDeath()
end)

RegisterNetEvent('nos_death:revive', function()
    deathManager:revive()
end)