require "HordeRush_Data"
require "HordeRush_ClientLogic"

local function clientLog(msg)
    if not RHR_MOD.ClientData or not RHR_MOD.ClientSandboxVars then return end
    if RHR_MOD.ClientData.Counter % RHR_MOD.ClientSandboxVars.LoggingFrequency == 0 then
        RHR_MOD.Log(msg)
    end
end

function RHR_MOD.OnServerCommand(module, command, args)
    if module ~= "HordeRush" then return end

    if command == "SandboxVarUpdate" then
        RHR_MOD.Log("Client received SandboxVarUpdate")
        RHR_MOD.ClientSandboxVars = args
    elseif command == "CooldownPhaseUpdate" then
        RHR_MOD.ClientData = args
        if RHR_MOD.CurrentPhase ~= 0 then
            RHR_MOD.CooldownPhaseStart()
            RHR_MOD.CurrentPhase = 0
        end
    elseif command == "CalmPhaseUpdate" then
        RHR_MOD.ClientData = args
        if RHR_MOD.CurrentPhase ~= 1 then
            RHR_MOD.CalmPhaseStart()
            RHR_MOD.CurrentPhase = 1
        end
        RHR_MOD.CalmPhaseUpdate(args.PlayerSquare)
    elseif command == "StormPhaseUpdate" then
        RHR_MOD.ClientData = args
        if RHR_MOD.CurrentPhase ~= 2 then
            RHR_MOD.StormPhaseStart(args.PlayerSquare)
            RHR_MOD.CurrentPhase = 2
        end
        RHR_MOD.StormPhaseUpdate(args.PlayerSquare)
    end
    clientLog("ClientUpdate - " .. RHR_MOD.CycleDataToStr())
end

function RHR_MOD.OnClientLoad()
    RHR_MOD.CurrentPhase = 0
    RHR_MOD.Log("Client requested SandboxVarUpdate")
    sendClientCommand(getPlayer(), "HordeRush", "SandboxVarUpdate", nil)
    Events.OnTick.Remove(RHR_MOD.OnClientLoad)
end

Events.OnServerCommand.Add(RHR_MOD.OnServerCommand)
Events.OnTick.Add(RHR_MOD.OnClientLoad)