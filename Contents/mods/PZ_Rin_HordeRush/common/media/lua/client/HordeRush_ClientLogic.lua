require "HordeRush_Data"

local WorldSoundManager = getWorldSoundManager()
local BaseSoundManager = getSoundManager()

local function makeNoise(x, y, radius)
    local player = getPlayer()
    if player then
        WorldSoundManager:addSound(player, x, y, 0, radius, radius * 5000)
    end
end

local function getHordeSquare(x, y, hordeDistance)
    local xMin = x - hordeDistance
    local xMax = x + hordeDistance
    local yMin = y - hordeDistance
    local yMax = y + hordeDistance
    return xMin, xMax, yMin, yMax
end

local function isPlayerInHordeArea(player, targetX, targetY, hordeDistance)
    if not player then return false end

    local playerSquare = player:getCurrentSquare()
    if not playerSquare then return false end

    local x = playerSquare:getX()
    local y = playerSquare:getY()
    local xMin, xMax, yMin, yMax = getHordeSquare(targetX, targetY, hordeDistance * 2)

    return  x >= xMin and x <= xMax and y >= yMin and y <= yMax
end

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

function RHR_MOD.CooldownPhaseStart()
    RHR_MOD.Log("Cooldown Phase: Started")
end

function RHR_MOD.CalmPhaseStart()
    RHR_MOD.Log("Calm Phase: Started")
end

function RHR_MOD.CalmPhaseUpdate()
    local hordeDistance = RHR_MOD.CSandboxVars.HordeDistance
    local hordeRadius = RHR_MOD.CSandboxVars.HordeRadius

    local targetX = RHR_MOD.CModData.PlayerX
    local targetY = RHR_MOD.CModData.PlayerY
    local x1, x2, y1, y2 = getHordeSquare(targetX, targetY, hordeDistance)

    if RHR_MOD.CSandboxVars.MigrationNorth then makeNoise(targetX, y1, hordeRadius) end
    if RHR_MOD.CSandboxVars.MigrationEast then makeNoise(x2, targetY, hordeRadius) end
    if RHR_MOD.CSandboxVars.MigrationWest then makeNoise(x1, targetY, hordeRadius) end
    if RHR_MOD.CSandboxVars.MigrationSouth then makeNoise(targetX, y2, hordeRadius) end
    if RHR_MOD.CSandboxVars.MigrationNorthEast then makeNoise(x2, y1, hordeRadius) end
    if RHR_MOD.CSandboxVars.MigrationNorthWest then makeNoise(x1, y1, hordeRadius) end
    if RHR_MOD.CSandboxVars.MigrationSouthEast then makeNoise(x2, y2, hordeRadius) end
    if RHR_MOD.CSandboxVars.MigrationSouthWest then makeNoise(x1, y2, hordeRadius) end
end

function RHR_MOD.StormPhaseStart()
    RHR_MOD.Log("Storm Phase: Started")

    local hordeDistance = RHR_MOD.CSandboxVars.HordeDistance
    local stormAlertMessage = RHR_MOD.CSandboxVars.StormAlertMessage

    local targetX = RHR_MOD.CModData.PlayerX
    local targetY = RHR_MOD.CModData.PlayerY

    local player = getPlayer()
    if not isPlayerInHordeArea(player, targetX, targetY, hordeDistance*2) then
        return
    end
    if player:isAsleep() then
        player:forceAwake()
    end

    player:Say(stormAlertMessage)
    playStormSounds(targetX, targetY)
end

function RHR_MOD.StormPhaseUpdate()
    local offset = RHR_MOD.CSandboxVars.PlayerPositionOffset
    local targetX = RHR_MOD.CModData.PlayerX + ZombRand(-offset, offset)
    local targetY = RHR_MOD.CModData.PlayerY + ZombRand(-offset, offset)

    local hordeDistance = RHR_MOD.CSandboxVars.HordeDistance
    makeNoise(targetX, targetY, hordeDistance * 1.5)
end