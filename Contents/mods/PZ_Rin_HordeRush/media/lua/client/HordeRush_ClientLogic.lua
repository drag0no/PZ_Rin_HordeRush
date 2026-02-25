require "HordeRush_Data"

local WorldSoundManager = getWorldSoundManager():addSound()
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
    local yMin = y + hordeDistance
    local yMax = y - hordeDistance
    return xMin, xMax, yMin, yMax
end

local function isPlayerInHordeArea(player, targetX, targetY, horderDistance)
    if not player then return false end

    local playerSquare = player:getCurrentSquare()
    if not playerSquare then return false end

    local x = playerSquare:getX()
    local y = playerSquare:getY()
    local xMin, xMax, yMin, yMax = getHordeSquare(targetX, targetY, horderDistance)

    return  x >= xMin and x <= maxX and y >= yMin and y <= yMax
end

local function playStormSounds(targetX, targetY, hordeDistance)
    if not RHR_MOD.ClientSandboxVars.StormAlertSound then
        return
    end

    local x1, x2, y1, y2 = getHordeSquare(targetX, targetY, hordeDistance)
    local WindIntensity = RHR_MOD.RoundFloat(getClimateManager():getWindIntensity(), 2)

    BaseSoundManager:PlaySound("Rumble", false, 0.01)

    local sound = getWorld():getFreeEmitter()
    sound:setVolume(WindIntensity, 1.0)

    sound:setPos(x1, y1, 0)
    sound:playSoundImpl("Wind" .. ZombRand(1, 4), false, nil)
    sound:setPos(x1, y2, 0)
    sound:playSoundImpl("Wind" .. ZombRand(1, 4), false, nil)
    sound:setPos(x2, y1, 0)
    sound:playSoundImpl("Wind" .. ZombRand(1, 4), false, nil)
    sound:setPos(x2, y2, 0)
    sound:playSoundImpl("Wind" .. ZombRand(1, 4), false, nil)

    sound:setPos(x1 + ZombRand(-5, 1), y1 + ZombRand(-5, 1), 0)
    sound:playSoundImpl("Zombies" .. ZombRand(1, 4), false, nil)
    sound:setPos(x1 + ZombRand(-5, 1), y2 + ZombRand(-5, 1), 0)
    sound:playSoundImpl("Zombies" .. ZombRand(1, 4), false, nil)
    sound:setPos(x2 + ZombRand(-5, 1), y1 + ZombRand(-5, 1), 0)
    sound:playSoundImpl("Zombies" .. ZombRand(1, 4), false, nil)
    sound:setPos(x2 + ZombRand(-5, 1), y2 + ZombRand(-5, 1), 0)
    sound:playSoundImpl("Zombies" .. ZombRand(1, 4), false, nil)
end

function RHR_MOD.CooldownPhaseStart()
    RHR_MOD.Log("Cooldown Phase Started!")
end

function RHR_MOD.CalmPhaseStart()
    RHR_MOD.Log("Calm Phase Started!")
end

function RHR_MOD.CalmPhaseUpdate(targetSquare)
    local hordeDistance = RHR_MOD.ClientSandboxVars.HordeDistance
    local hordeRadius = RHR_MOD.ClientSandboxVars.HordeRadius

    local targetX = targetSquare:getX()
    local targetY = targetSquare:getY()
    local x1, x2, y1, y2 = getHordeSquare(targetX, targetY, hordeDistance)

    if RHR_MOD.SandboxVars.MigrationNorth then makeNoise(targetX, y1, hordeRadius) end
    if RHR_MOD.SandboxVars.MigrationEast then makeNoise(x2, targetY, hordeRadius) end
    if RHR_MOD.SandboxVars.MigrationWest then makeNoise(x1, targetY, hordeRadius) end
    if RHR_MOD.SandboxVars.MigrationSouth then makeNoise(targetX, y2, hordeRadius) end
    if RHR_MOD.SandboxVars.MigrationNorthEast then makeNoise(x2, y1, hordeRadius) end
    if RHR_MOD.SandboxVars.MigrationNorthWest then makeNoise(x1, y1, hordeRadius) end
    if RHR_MOD.SandboxVars.MigrationSouthEast then makeNoise(x2, y2, hordeRadius) end
    if RHR_MOD.SandboxVars.MigrationSouthWest then makeNoise(x1, y2, hordeRadius) end
end

function RHR_MOD.StormPhaseStart(targetSquare)
    RHR_MOD.Log("Storm Phase Started!")

    local hordeDistance = RHR_MOD.ClientSandboxVars.HordeDistance
    local stormAlertMessage = RHR_MOD.ClientSandboxVars.StormAlertMessage

    local targetX = targetSquare:getX()
    local targetY = targetSquare:getY()

    local player = getPlayer()
    if not isPlayerInHordeArea(player, targetX, targetY, hordeDistance) then
        return
    end
    if player:isAsleep() then
        player:forceAwake()
    end

    player:Say(StormAlertMessage)
    playStormSounds(targetX, targetY, hordeDistance)
end

function RHR_MOD.StormPhaseUpdate(targetSquare)
    local offset = RHR_MOD.SandboxVars.PlayerPositionOffset
    local targetX = targetSquare:getX() + ZombRand(-offset, offset)
    local targetY = targetSquare:getY() + ZombRand(-offset, offset)

    local hordeDistance = RHR_MOD.SandboxVars.HordeDistance
    makeNoise(targetX, targetY, hordeDistance * 1.5)
end