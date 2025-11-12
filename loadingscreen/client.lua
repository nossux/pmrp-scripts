CreateThread(function()
    while not NetworkIsSessionStarted() do
        Wait(0)
    end

    Wait(1000)
    ShutdownLoadingScreenNui()
end)
