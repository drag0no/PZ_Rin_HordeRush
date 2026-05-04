require "HordeRush_Data"
require "HordeRush_ServerLogic"
require "HordeRush_SoundEvents"

local function serverLog(msg)
    if RHR_MOD.SModData.LogCounter % RHR_MOD.SSandboxVars.LoggingFrequency == 0 then
        RHR_MOD.Log(msg)
    end
end

local function sendCommand(commandName, commandArgs)
    serverLog("Server Sent: " .. commandName)
    if RHR_MOD.IsSinglePlayer() then
        RHR_MOD.OnServerCommand("HordeRush", commandName, commandArgs)
    else
        sendServerCommand("HordeRush", commandName, commandArgs)
    end
end

function RHR_MOD.OnClientCommand(module, command, player, args)
    if module ~= "HordeRush" then return end
    if not (RHR_MOD.IsSinglePlayer() or RHR_MOD.IsServerAdmin(player)) then
        serverLog("Attempt to execute a server command from non-admin account!")
        return
    end

    if command == "SetCounter" then
        if type(args.value) ~= "number" then
            serverLog("SetCounter: Wrong value: " .. tostring(args.value))
            return
        end

        RHR_MOD.SModData.Counter = args.value
        RHR_MOD.Log("SetCounter: " .. player:getUsername() .. " set the Counter to: " .. tostring(args.value))
    end
end

function RHR_MOD.CheckPhase()
    RHR_MOD.SModData.LogCounter = RHR_MOD.SModData.LogCounter + 1
    -- Avoid overflow
    if RHR_MOD.SModData.LogCounter >= RHR_MOD.SSandboxVars.LoggingFrequency then RHR_MOD.SModData.LogCounter = 0 end

    local counter = RHR_MOD.SModData.Counter
    local cooldownPhase = RHR_MOD.SModData.CooldownDuration
    local calmPhase = cooldownPhase + RHR_MOD.SModData.CalmDuration
    local stormPhase = calmPhase + RHR_MOD.SModData.StormDuration
    local dataSet = {sandbox=RHR_MOD.SSandboxVars, data=RHR_MOD.SModData}

    if counter % RHR_MOD.SSandboxVars.PhaseUpdateFrequency ~= 0 then
        serverLog("CheckPhase: " .. RHR_MOD.CycleDataToStr(RHR_MOD.SModData))
        RHR_MOD.SModData.Counter = RHR_MOD.SModData.Counter + 1
        return
    end

    -- Cooldown Phase
    if counter < cooldownPhase then
        RHR_MOD.ServerCooldownPhaseUpdate()
        serverLog("CheckPhase: The calm phase begins in " .. tostring(RHR_MOD.MinutesToHours(cooldownPhase - counter)) .. " in-game hours")
        sendCommand("CooldownPhaseUpdate", dataSet)
    -- Calm Phase
    elseif counter >= cooldownPhase and counter < calmPhase then
        RHR_MOD.ServerCalmPhaseUpdate()
        sendCommand("CalmPhaseUpdate", dataSet)
        serverLog("CheckPhase: The storm phase begins in " .. tostring(RHR_MOD.MinutesToHours(calmPhase - counter)) .. " in-game hours")
    -- Storm Phase
    elseif counter >= calmPhase and counter < stormPhase then
        RHR_MOD.ServerStormPhaseUpdate()
        sendCommand("StormPhaseUpdate", dataSet)
        serverLog("CheckPhase: The cooldown phase begins in " .. tostring(RHR_MOD.MinutesToHours(stormPhase - counter)) .. " in-game hours")
    -- Reset Cycle
    else
        RHR_MOD.ResetModData()
    end

    serverLog("CheckPhase: " .. RHR_MOD.CycleDataToStr(RHR_MOD.SModData))
    RHR_MOD.SModData.Counter = RHR_MOD.SModData.Counter + 1
end

function RHR_MOD.OnServerLoad()
    RHR_MOD.LoadModData()
end

if not isClient() then
    Events.OnServerStarted.Add(RHR_MOD.OnServerLoad) -- multi player
    Events.OnLoad.Add(RHR_MOD.OnServerLoad) -- single player
    Events.OnClientCommand.Add(RHR_MOD.OnClientCommand)
    Events.EveryOneMinute.Add(RHR_MOD.CheckPhase)
end
