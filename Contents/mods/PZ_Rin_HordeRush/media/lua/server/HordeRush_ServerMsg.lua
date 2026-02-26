require "HordeRush_Data"
require "HordeRush_ServerLogic"

local function serverLog(msg)
    if RHR_MOD.SModData.LogCounter % RHR_MOD.SSandboxVars.LoggingFrequency == 0 then
        RHR_MOD.Log(msg)
    end
end

local function sendCommand(commandName, commandArgs)
    serverLog("Server Sent " .. commandName)
    if RHR_MOD.IsSinglePlayer() then
        RHR_MOD.OnServerCommand("HordeRush", commandName, commandArgs)
    else
        sendServerCommand("HordeRush", commandName, commandArgs)
    end
end

function RHR_MOD.CheckPhase()
    if isClient() then
        -- prevent client in multiplayer to run updates
        return
    end

    RHR_MOD.SModData.LogCounter = RHR_MOD.SModData.LogCounter + 1
    -- Avoid overflow
    if RHR_MOD.SModData.LogCounter >= RHR_MOD.SSandboxVars.LoggingFrequency then RHR_MOD.SModData.LogCounter = 0 end

    local counter = RHR_MOD.SModData.Counter
    local cooldownPhase = RHR_MOD.SModData.CooldownDuration
    local calmPhase = cooldownPhase + RHR_MOD.SModData.CalmDuration
    local stormPhase = calmPhase + RHR_MOD.SModData.StormDuration
    local dataSet = {sandbox=RHR_MOD.SSandboxVars, data=RHR_MOD.SModData}

    if counter % RHR_MOD.SSandboxVars.PhaseUpdateFrequency ~= 0 then
        serverLog("CheckPhase - " .. RHR_MOD.CycleDataToStr(RHR_MOD.SModData))
        RHR_MOD.SModData.Counter = RHR_MOD.SModData.Counter + 1
        return
    end

    -- Cooldown Phase
    if counter < cooldownPhase then
        serverLog("CheckPhase - The calm phase begins in " .. tostring(RHR_MOD.MinutesToHours(cooldownPhase - counter)) .. " in-game hours")
        sendCommand("CooldownPhaseUpdate", dataSet)
    -- Calm Phase
    elseif counter >= cooldownPhase and counter < calmPhase then
        if not RHR_MOD.UpdatePlayerData() then
            serverLog("CheckPhase - No Player Data. Skipping Calm Phase Update.")
            return
        end
        sendCommand("CalmPhaseUpdate", dataSet)
        serverLog("CheckPhase - The storm phase begins in " .. tostring(RHR_MOD.MinutesToHours(calmPhase - counter)) .. " in-game hours")
    -- Storm Phase
    elseif counter >= calmPhase and counter < stormPhase then
        if not RHR_MOD.UpdatePlayerData() then
            serverLog("CheckPhase - No Player Data. Skipping Storm Phase Update.")
            return
        end
        sendCommand("StormPhaseUpdate", dataSet)
        serverLog("CheckPhase - The cooldown phase begins in " .. tostring(RHR_MOD.MinutesToHours(stormPhase - counter)) .. " in-game hours")
    -- Reset Cycle
    else
        RHR_MOD.ResetModData()
    end

    serverLog("CheckPhase - " .. RHR_MOD.CycleDataToStr(RHR_MOD.SModData))
    RHR_MOD.SModData.Counter = RHR_MOD.SModData.Counter + 1
end

function RHR_MOD.OnServerLoad()
    if isClient() then
        -- prevent client in multiplayer load local data
        return
    end

    RHR_MOD.LoadModData()
end

Events.OnServerStarted.Add(RHR_MOD.OnServerLoad) -- multi player
Events.OnLoad.Add(RHR_MOD.OnServerLoad) -- single player
Events.EveryOneMinute.Add(RHR_MOD.CheckPhase)
