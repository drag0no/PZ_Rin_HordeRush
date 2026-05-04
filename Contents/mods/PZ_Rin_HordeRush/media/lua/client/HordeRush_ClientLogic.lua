require "HordeRush_Data"
require "HordeRush_Utils"
require "HordeRush_SoundEvents"

local BaseSoundManager = getSoundManager()

local function playStormSounds(targetX, targetY)
    if not RHR_MOD.CSandboxVars.StormAlertSound then
        return
    end

    local WindIntensity = RHR_MOD.RoundFloat(getClimateManager():getWindIntensity(), 2)

    BaseSoundManager:PlaySound("Rumble", false, 0.01)

    local sound = getWorld():getFreeEmitter()
    sound:setVolume(WindIntensity, 1.0)

    sound:setPos(targetX, targetY, 0)
    sound:playSoundImpl("Wind" .. ZombRand(1, 4), false, nil)
    sound:setPos(targetX + ZombRand(-20, 20), targetY + ZombRand(-20, 20), 0)
    sound:playSoundImpl("Zombies" .. ZombRand(1, 4), false, nil)

    RHR_MOD.Log("Storm Phase: Sounds played")
end

function RHR_MOD.ClientCooldownPhaseStart()
    RHR_MOD.Log("Cooldown Phase: Started")
end

function RHR_MOD.ClientCooldownPhaseUpdate()
    RHR_MOD.ClearTracking()
end

function RHR_MOD.ClientCalmPhaseStart()
    RHR_MOD.Log("Calm Phase: Started")
end

function RHR_MOD.ClientCalmPhaseUpdate()
    local targetX = RHR_MOD.CModData.PlayerX
    local targetY = RHR_MOD.CModData.PlayerY
    local hordeDistance = RHR_MOD.CSandboxVars.HordeDistance
    RHR_MOD.ClearTracking()
    RHR_MOD.CalmPhaseEventNoise(targetX, targetY, hordeDistance)
end

function RHR_MOD.ClientStormPhaseStart()
    RHR_MOD.Log("Storm Phase: Started")

    local hordeDistance = RHR_MOD.CSandboxVars.HordeDistance
    local stormAlertMessage = RHR_MOD.CSandboxVars.StormAlertMessage

    local targetX = RHR_MOD.CModData.PlayerX
    local targetY = RHR_MOD.CModData.PlayerY

    local player = getPlayer()
    if not RHR_MOD.IsPlayerInHordeArea(player, targetX, targetY, hordeDistance, 2) then
        return
    end
    if player:isAsleep() then
        player:forceAwake()
    end

    player:Say(stormAlertMessage)
    playStormSounds(targetX, targetY)
end

function RHR_MOD.ClientStormPhaseUpdate()
    local targetX = RHR_MOD.CModData.PlayerX
    local targetY = RHR_MOD.CModData.PlayerY
    local offset = RHR_MOD.CSandboxVars.PlayerPositionOffset
    local hordeDistance = RHR_MOD.CSandboxVars.HordeDistance
    local phaseUpdateFreq =  RHR_MOD.CSandboxVars.PhaseUpdateFrequency
    RHR_MOD.SetTracking(targetX, targetY, offset)
    RHR_MOD.StormPhaseEventNoise(targetX, targetY, hordeDistance, phaseUpdateFreq)
end
