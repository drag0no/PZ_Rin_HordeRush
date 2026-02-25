require "HordeRush_Data"

local function serverLog(msg)
    if RHR_MOD.ModData.Counter % RHR_MOD.ServerSandboxVars.LoggingFrequency == 0 then
        RHR_MOD.Log(msg)
    end
end

local function sendCommand(commandName, commandArgs)
    serverLog("Sent " .. commandName)
    if RI_MOD.IsSinglePlayer() then
        RI_MOD.OnServerCommand("HordeRush", commandName, commandArgs)
    else
        sendServerCommand("HordeRush", commandName, commandArgs)
    end
end

local function getRandomPlayer()
    local onlinePlayers = getOnlinePlayers()
    if onlinePlayers == nil or onlinePlayers:isEmpty() then
        return nil
    end

    local playerCount = onlinePlayers:size()
    local randomIndex = ZombRand(playerCount)
    return onlinePlayers:get(randomIndex)
end

local function updatePlayerData()
    local player
    if not RHR_MOD.ModData.PlayerName then
        player = getRandomPlayer()
        if not player then
            return false
        end
    else
        player = getPlayerFromUsername(RHR_MOD.ModData.PlayerName)
        if not player then
            return true
        end
    end
    RHR_MOD.ModData.PlayerName = player:getUsername()
    RHR_MOD.ModData.PlayerSquare = player:getCurrentSquare()
    return true
end

function RHR_MOD.CheckPhase()
    local counter = RHR_MOD.ModData.Counter
    local cooldownPhase = RHR_MOD.ModData.CooldownDuration
    local calmPhase = cooldownPhase + RHR_MOD.ModData.CalmDuration
    local stormPhase = calmPhase + RHR_MOD.ModData.StormDuration

    if counter % RHR_MOD.ServerSandboxVars.PhaseUpdateFrequency ~= 0 then
        RHR_MOD.ModData.Counter = RHR_MOD.ModData.Counter + 1
        return
    end

    -- Cooldown Phase
    if counter < cooldownPhase then
        serverLog("CheckPhase - The calm phase begins in " .. tostring(RHR_MOD.MinutesToHours(cooldownPhase - counter)) .. "in-game hours")
        sendCommand("CooldownPhaseUpdate", RHR_MOD.ModData)
    -- Calm Phase
    elseif counter >= cooldownPhase and counter < calmPhase then
        if not updatePlayerData() then
            serverLog("CheckPhase - No Player Data. Skipping Calm Phase Update.")
            return
        end
        sendCommand("CalmPhaseUpdate", RHR_MOD.ModData)
        serverLog("CheckPhase - The storm phase begins in " .. tostring(RHR_MOD.MinutesToHours(calmPhase - counter)) .. "in-game hours")
    -- Storm Phase
    elseif counter >= calmPhase and counter < stormPhase then
        if not updatePlayerData() then
            serverLog("CheckPhase - No Player Data. Skipping Storm Phase Update.")
            return
        end
        sendCommand("StormPhaseUpdate", RHR_MOD.ModData)
        serverLog("CheckPhase - The cooldown phase begins in " .. tostring(RHR_MOD.MinutesToHours(stormPhase - counter)) .. "in-game hours")
    -- Reset Cycle
    else
        RHR_MOD.ResetCycleData()
    end

    serverLog("CheckPhase - " .. RHR_MOD.CycleDataToStr())
    RHR_MOD.ModData.Counter = RHR_MOD.ModData.Counter + 1
end

function RHR_MOD.OnClientCommand(module, command, playerObj, args)
    if module ~= "HordeRush" then return end

    if command == "SandboxVarUpdate" then
        sendCommand("SandboxVarUpdate",  RHR_MOD.ServerSandboxVars)
    end
end

function RHR_MOD.OnServerLoad()
    RHR_MOD.LoadServerData()
end

Events.OnClientCommand.Add(RHR_MOD.OnClientCommand)
Events.OnServerStarted.Add(RHR_MOD.OnServerLoad) -- multi player
Events.OnLoad.Add(RHR_MOD.OnServerLoad) -- single player
Events.EveryOneMinute.Add(RHR_MOD.CheckPhase)
