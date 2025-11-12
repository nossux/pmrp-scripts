local function LoadAOPState()
	local data = LoadResourceFile(GetCurrentResourceName(), 'aop_state.json')
	if data then
		local state = json.decode(data)
		if state then
			currentAOP = state.aop or "None Set"
			currentPT = state.peacetime or false
			priorityName = state.priority or nil
			priorityActive = state.priorityActive or false
			prioritySetter = state.prioritySetter or nil
			priorityStartTime = state.priorityStartTime or nil
		end
	end
end

local function SaveAOPState()
	local prioToSave = priorityName
	if not priorityActive or not prioToSave or prioToSave == "" then
		prioToSave = "Normal"
	end
	local state = {
		aop = currentAOP,
		peacetime = currentPT,
		priority = prioToSave,
		priorityActive = priorityActive,
		prioritySetter = prioritySetter,
		priorityStartTime = priorityStartTime
	}
	SaveResourceFile(GetCurrentResourceName(), 'aop_state.json', json.encode(state), #json.encode(state))
end

RegisterNetEvent('hud:server:fetchEnvironment', function()
	local src = source
	local data = LoadResourceFile(GetCurrentResourceName(), 'aop_state.json')
	if data then
		local state = json.decode(data)
		if state then
			currentAOP = state.aop or "None Set"
			currentPT = state.peacetime or false
			priorityName = state.priority or nil
		end
	end
	local prioObj = {
		enabled = priorityName and priorityName ~= "Normal",
		name = priorityName or "Normal"
	}
	TriggerClientEvent('hud:client:environment:update', src, currentAOP, currentPT, priorityName)
	TriggerClientEvent('nos_hud:client:updateAOP', src,
		{ aop = currentAOP, peacetime = currentPT, priority = prioObj })
end)

currentPT = false
currentAOP = "None Set"
peacetimeActive = false
priorityActive = false
priorityName = nil
prioritySetter = nil
priorityStartTime = nil

LoadAOPState()

RegisterServerEvent('AOP:Startup')
AddEventHandler('AOP:Startup', function()
	Wait(3000)
	SetMapName("RP : " .. currentAOP)
end)

TriggerEvent("AOP:Startup")

lib.addCommand('aop', {
	help = 'Change the Area of Patrol',
	restricted = exports.Badger_Discord_API:HasDiscordRole("Staff Team")
}, function(source, args, raw)
	currentAOP = table.concat(args, " ")
	SaveAOPState()
	TriggerEvent("AOP:Sync")
	SetMapName("RP : " .. currentAOP)
	TriggerClientEvent('hud:client:sound', source)
	TriggerClientEvent('ox_lib:notify', -1, {
		description = "AOP set to " .. currentAOP,
		type = "inform"
	})
end)

RegisterServerEvent('AOP:Sync')
AddEventHandler('AOP:Sync', function()
	local data = LoadResourceFile(GetCurrentResourceName(), 'aop_state.json')
	if data then
		local state = json.decode(data)
		if state then
			currentAOP = state.aop or "None Set"
			currentPT = state.peacetime or false
			priorityName = state.priority or nil
		end
	end
	local prioObj = {
		enabled = priorityName and priorityName ~= "Normal",
		name = priorityName or "Normal"
	}
	TriggerClientEvent('hud:client:environment:update', -1, currentAOP, currentPT, priorityName)
	TriggerClientEvent('nos_hud:client:updateAOP', -1,
		{ aop = currentAOP, peacetime = currentPT, priority = prioObj })
end)

RegisterCommand("pt", function(source, args, rawCommand)
	local hasPermission = exports.Badger_Discord_API:HasDiscordRole(source, "Staff Team")
	if hasPermission then
		if not currentPT then
			TriggerClientEvent('ox_lib:notify', -1, {
				description = "Peace Time is now in effect!",
				type = "success"
			})
			currentPT = true
			SaveAOPState()
			TriggerClientEvent('hud:client:sound', source)
			TriggerEvent('AOP:Sync')
		else
			TriggerClientEvent('ox_lib:notify', -1, {
				description = "Peace Time is now off.",
				type = "warning"
			})
			currentPT = false
			SaveAOPState()
			TriggerClientEvent('hud:client:sound', source)
			TriggerEvent('AOP:Sync')
		end
	else
		TriggerClientEvent('ox_lib:notify', source, {
			description = "You do not have the required role to use this command.",
			type = "error"
		})
	end
end, false)

RegisterCommand('prio', function(source, args, rawCommand)
	local hasPermission = exports.Badger_Discord_API:HasDiscordRole("Staff Team", source)
	if priorityActive and #args == 0 then
		if source == prioritySetter or hasPermission then
			priorityActive = false
			local setterName = GetPlayerName(source)
			TriggerClientEvent('ox_lib:notify', -1, {
				description = "Priority disabled by " .. setterName,
				type = "warning"
			})
			priorityName = "Normal"
			prioritySetter = nil
			priorityStartTime = nil
			SaveAOPState()
			TriggerEvent('AOP:Sync')
			TriggerClientEvent('hud:client:sound', source)
		else
			TriggerClientEvent('ox_lib:notify', source, {
				description = "You do not have permission to cancel priority.",
				type = "error"
			})
		end
	elseif not priorityActive then
		if #args == 0 then
			priorityName = GetPlayerName(source)
		else
			priorityName = table.concat(args, " ")
		end
		prioritySetter = source
		priorityStartTime = os.time()
		priorityActive = true
		local setterName = GetPlayerName(source)
		TriggerClientEvent('ox_lib:notify', -1, {
			description = "Priority set to " .. priorityName .. " by " .. setterName,
			type = "success"
		})
		TriggerClientEvent('hud:client:sound', source)
		SaveAOPState()
		TriggerEvent('AOP:Sync')
	else
		TriggerClientEvent('ox_lib:notify', source, {
			description = "Priority is already active.",
			type = "error"
		})
	end
end, false)

local priorityTimeout = 900

CreateThread(function()
	while true do
		Wait(60000)
		if priorityActive and priorityStartTime and (os.time() - priorityStartTime) >= priorityTimeout then
			priorityActive = false
			TriggerClientEvent('ox_lib:notify', -1, {
				description = "Priority has timed out and is now open.",
				type = "warning"
			})
			priorityName = "Normal"
			prioritySetter = nil
			priorityStartTime = nil
			SaveAOPState()
			TriggerEvent('AOP:Sync')
		end
	end
end)

AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
	local src = source
	LoadAOPState()
	local prioObj = {
		enabled = priorityName and priorityName ~= "Normal",
		name = priorityName or "Normal"
	}
	TriggerClientEvent('hud:client:environment:update', src, currentAOP, currentPT, priorityName)
	TriggerClientEvent('nos_hud:client:updateAOP', src,
		{ aop = currentAOP, peacetime = currentPT, priority = prioObj })
end)

AddEventHandler('onResourceStart', function(resourceName)
	if GetCurrentResourceName() == resourceName then
		LoadAOPState()
		TriggerEvent('AOP:Sync')
	end
end)
