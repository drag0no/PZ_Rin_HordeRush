RHR_MOD = RHR_MOD or {}

RHR_DATAKEY = "RHR_MOD"

function RHR_MOD.Log(msg)
    print("Rin_HordeRush: " .. tostring(msg))
end

function RHR_MOD.RoundFloat(number, decimalPlace)
    local mult = math.pow(10, decimalPlace)
    return math.floor(number * mult + 0.5) / mult
end

function RHR_MOD.MinutesToHours(minutest)
    return RHR_MOD.RoundFloat(minutes / 60)
end

function RHR_MOD.IsPlayerAlive(player)
    return player and player:isAlive()
end

function RHR_MOD.IsSinglePlayer()
    return not isClient() and not isServer()
end

function RHR_MOD.IsServerAdmin(player)
    if not player then return false end
    local access = player:getAccessLevel():lower()
    return access == "admin"
end

function RHR_MOD.LoadServerSandboxVar()
    RHR_MOD.ServerSandboxVars = {
        StormAlertSound = SandboxVars.HordeRush.SoundType,
        StormAlertMessage = SandboxVars.HordeRush.StormAlertMessage,
        HordeRadius = SandboxVars.HordeRush.HordeRadius,
        HordeDistance = SandboxVars.HordeRush.HordeDistance,
        MinCooldownPhaseDuration = SandboxVars.CBTS.MinCooldownPhaseDuration * 60 + 0.0,
        MaxCooldownPhaseDuration = SandboxVars.CBTS.MaxCooldownPhaseDuration * 60 + 0.0,
        MinCalmPhaseDuration = SandboxVars.CBTS.MinCalmPhaseDuration * 60 + 0.0,
        MaxCalmPhaseDuration = SandboxVars.CBTS.MaxCalmPhaseDuration * 60 + 0.0,
        MinStormPhaseDuration = SandboxVars.CBTS.MinStormPhaseDuration * 60 + 0.0,
        MaxStormPhaseDuration = SandboxVars.CBTS.MaxStormPhaseDuration * 60 + 0.0,
        PlayerPositionOffset = SandboxVars.HordeRush.PlayerPositionOffset,
        MigrationNorth = SandboxVars.HordeRush.MigrateToNorth,
        MigrationEast = SandboxVars.HordeRush.MigrateToEast,
        MigrationSouth = SandboxVars.HordeRush.MigrateToSouth,
        MigrationWest = SandboxVars.HordeRush.MigrateToWest,
        MigrationNorthEast = SandboxVars.HordeRush.MigrateToNorthEast,
        MigrationNorthWest = SandboxVars.HordeRush.MigrateToNorthWest,
        MigrationSouthEast = SandboxVars.HordeRush.MigrateToSouthEast,
        MigrationSouthWest = SandboxVars.HordeRush.MigrateToSouthWest,
        PhaseUpdateFrequency = SandboxVars.HordeRush.PhaseUpdateFrequency,
        LoggingFrequency = SandboxVars.HordeRush.LoggingFrequency
    }
end

function RHR_MOD.CycleDataToStr()
    return "Counter=" .. tostring(RHR_MOD.ModData.Counter) .. " / FullCycle=" .. tostring(RHR_MOD.ModData.CooldownDuration + RHR_MOD.ModData.CalmDuration + RHR_MOD.ModData.StormDuration) .. " PlayerName=" .. tostring(RHR_MOD.ModData.PlayerName) .. " / PlayerSquare=" .. tostring(RHR_MOD.ModData.PlayerSquare)
end

function RHR_MOD.ResetCycleData()
    RHR_MOD.ModData = {
        Counter = 0,
        CooldownDuration = ZombRand(RHR_MOD.ServerSandboxVars.MinCooldownPhaseDuration, RHR_MOD.ServerSandboxVars.MaxCooldownPhaseDuration),
        CalmDuration = ZombRand(RHR_MOD.ServerSandboxVars.MinCalmPhaseDuration, RHR_MOD.ServerSandboxVars.MaxCalmPhaseDuration),
        StormDuration = ZombRand(RHR_MOD.ServerSandboxVars.MinStormPhaseDuration, RHR_MOD.ServerSandboxVars.MaxStormPhaseDuration),
        PlayerName = nil,
        PlayerSquare = nil
    }
    RHR_MOD.Log("ResetCycleData - " .. RHR_MOD.CycleDataToStr())
end


function RHR_MOD.LoadServerData()
    RHR_MOD.LoadServerSandboxVar()

    if isClient() then
        -- prevent client in multiplayer load local data
        return
    end

    RHR_MOD.ModData = ModData.getOrCreate(RHR_DATAKEY)

    if not RHR_MOD.ModData.CycleCounter then
        RHR_MOD.Log("No ModData Loaded")
        RHR_MOD.ResetCycleData()
    else
        RHR_MOD.Log("ModData Loaded - " .. RHR_MOD.CycleDataToStr())
    end
end
