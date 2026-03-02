require "HordeRush_Data"
require "HordeRush_ClientLogic"

local function clientLog(msg)
    if not RHR_MOD.CModData or not RHR_MOD.CSandboxVars then return end
    if RHR_MOD.CModData.LogCounter % RHR_MOD.CSandboxVars.LoggingFrequency == 0 then
        RHR_MOD.Log(msg)
    end
end

local function unpackUpdate(args)
    RHR_MOD.CModData = args.data
    RHR_MOD.CSandboxVars = args.sandbox
end

function RHR_MOD.OnServerCommand(module, command, args)
    if module ~= "HordeRush" then return end

    unpackUpdate(args)
    if command == "CooldownPhaseUpdate" then
        if RHR_MOD.CurrentPhase ~= 0 then
            RHR_MOD.CooldownPhaseStart()
            RHR_MOD.CurrentPhase = 0
        end
    elseif command == "CalmPhaseUpdate" then
        if RHR_MOD.CurrentPhase ~= 1 then
            RHR_MOD.CalmPhaseStart()
            RHR_MOD.CurrentPhase = 1
        end
        RHR_MOD.CalmPhaseUpdate()
    elseif command == "StormPhaseUpdate" then
        if RHR_MOD.CurrentPhase ~= 2 then
            RHR_MOD.StormPhaseStart()
            RHR_MOD.CurrentPhase = 2
        end
        RHR_MOD.StormPhaseUpdate()
    end
    clientLog("ClientUpdate: Phase=" .. RHR_MOD.CurrentPhase .. " / " .. RHR_MOD.CycleDataToStr(RHR_MOD.CModData))
end

function RHR_MOD.OnGameStart()
    RHR_MOD.CurrentPhase = 0
end

Events.OnServerCommand.Add(RHR_MOD.OnServerCommand)
Events.OnGameStart.Add(RHR_MOD.OnGameStart)
