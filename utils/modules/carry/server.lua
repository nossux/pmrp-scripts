local carrying = {}
local carried = {}

RegisterServerEvent("nos_player:carry:sync")
AddEventHandler("nos_player:carry:sync", function(targetSrc)
    local source = source
    local sourcePed = GetPlayerPed(source)
    local sourceCoords = GetEntityCoords(sourcePed)
    local targetPed = GetPlayerPed(targetSrc)
    local targetCoords = GetEntityCoords(targetPed)
    if #(sourceCoords - targetCoords) <= 3.0 then
        TriggerClientEvent("nos_player:carry:syncTarget", targetSrc, source)
        carrying[source] = targetSrc
        carried[targetSrc] = source
    end
end)

RegisterServerEvent("nos_player:carry:stop")
AddEventHandler("nos_player:carry:stop", function(targetSrc)
    local source = source

    if carrying[source] then
        TriggerClientEvent("nos_player:carry:cl_stop", targetSrc)
        carrying[source] = nil
        carried[targetSrc] = nil
    elseif carried[source] then
        TriggerClientEvent("nos_player:carry:cl_stop", carried[source])
        carrying[carried[source]] = nil
        carried[source] = nil
    end
end)

AddEventHandler('playerDropped', function(reason)
    local source = source

    if carrying[source] then
        TriggerClientEvent("nos_player:carry:cl_stop", carrying[source])
        carried[carrying[source]] = nil
        carrying[source] = nil
    end

    if carried[source] then
        TriggerClientEvent("nos_player:carry:cl_stop", carried[source])
        carrying[carried[source]] = nil
        carried[source] = nil
    end
end)
