RHR_MOD = RHR_MOD or {}

RHR_DATAKEY = "RHR_MOD"

function RHR_MOD.Log(msg)
    print("Rin_HordeRush: " .. tostring(msg))
end

function RHR_MOD.RoundFloat(number, decimalPlace)
    local mult =  math.pow(10, decimalPlace)
    return math.floor(number * mult + 0.5) / mult
end

function RHR_MOD.MinutesToHours(minutes)
    return RHR_MOD.RoundFloat(minutes / 60, 1)
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

function RHR_MOD.LoadSandboxVars()
    RHR_MOD.SSandboxVars = {
        StormAlertSound = SandboxVars.HordeRush.StormAlertSound,
        StormAlertMessage = SandboxVars.HordeRush.StormAlertMessage,
        HordeRadius = SandboxVars.HordeRush.HordeRadius,
        HordeDistance = SandboxVars.HordeRush.HordeDistance,
        MinCooldownPhaseDuration = SandboxVars.HordeRush.MinCooldownPhaseDuration * 60 + 0.0,
        MaxCooldownPhaseDuration = SandboxVars.HordeRush.MaxCooldownPhaseDuration * 60 + 0.0,
        MinCalmPhaseDuration = SandboxVars.HordeRush.MinCalmPhaseDuration * 60 + 0.0,
        MaxCalmPhaseDuration = SandboxVars.HordeRush.MaxCalmPhaseDuration * 60 + 0.0,
        MinStormPhaseDuration = SandboxVars.HordeRush.MinStormPhaseDuration * 60 + 0.0,
        MaxStormPhaseDuration = SandboxVars.HordeRush.MaxStormPhaseDuration * 60 + 0.0,
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

function RHR_MOD.CycleDataToStr(dataObj)
    if not dataObj then return "No Data Set" end
    return "Counter=" .. tostring(dataObj.Counter) .. " / Phases=[".. tostring(dataObj.CooldownDuration) .. "|" .. tostring(dataObj.CooldownDuration + dataObj.CalmDuration) .."|" .. tostring(dataObj.CooldownDuration + dataObj.CalmDuration + dataObj.StormDuration) .. "] / PlayerName=" .. tostring(dataObj.PlayerName) .. " / PlayerCoords=[" .. tostring(dataObj.PlayerX) .. "," .. tostring(dataObj.PlayerY) .. "]"
end

local function resetPhaseDurations()
    RHR_MOD.SModData.CooldownDuration = ZombRand(RHR_MOD.SSandboxVars.MinCooldownPhaseDuration, RHR_MOD.SSandboxVars.MaxCooldownPhaseDuration)
    RHR_MOD.SModData.CalmDuration = ZombRand(RHR_MOD.SSandboxVars.MinCalmPhaseDuration, RHR_MOD.SSandboxVars.MaxCalmPhaseDuration)
    RHR_MOD.SModData.StormDuration = ZombRand(RHR_MOD.SSandboxVars.MinStormPhaseDuration, RHR_MOD.SSandboxVars.MaxStormPhaseDuration)
end

function RHR_MOD.ResetModData()
    resetPhaseDurations()
    RHR_MOD.SModData.Counter = 0
    RHR_MOD.SModData.LogCounter = 0
    RHR_MOD.SModData.PlayerName = nil
    RHR_MOD.SModData.PlayerX = nil
    RHR_MOD.SModData.PlayerY = nil
    RHR_MOD.Log("ResetModData - " .. RHR_MOD.CycleDataToStr(RHR_MOD.SModData))
end

local function validateModData()
    if not RHR_MOD.SModData.CooldownDuration or not RHR_MOD.SModData.CalmDuration or not RHR_MOD.SModData.StormDuration then
        resetPhaseDurations()
    end
    if not RHR_MOD.SModData.Counter then RHR_MOD.SModData.Counter = 0 end
    if not RHR_MOD.SModData.LogCounter then RHR_MOD.SModData.LogCounter = 0 end
end

function RHR_MOD.LoadModData()
    RHR_MOD.LoadSandboxVars()

    RHR_MOD.SModData = ModData.getOrCreate(RHR_DATAKEY)
    if not RHR_MOD.SModData.Counter then
        RHR_MOD.Log("No ModData Loaded")
        RHR_MOD.ResetModData()
    else
        RHR_MOD.Log("ModData Loaded - " .. RHR_MOD.CycleDataToStr(RHR_MOD.SModData))
        validateModData()
    end
end
