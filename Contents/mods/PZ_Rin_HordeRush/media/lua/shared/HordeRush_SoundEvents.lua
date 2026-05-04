require "HordeRush_Data"
require "HordeRush_Utils"

local WorldSoundManager = getWorldSoundManager()

local calmSoundIdx = 0
local stormSoundIdx = 0

local function makeWorldNoise(x, y, radius, volume)
    WorldSoundManager:addSound(nil, x, y, 0, radius, volume)
end

local function makeCalmGatherNoise(soundIdx, targetX, targetY, hordeDistance, volume)
    local hordeRadius = hordeDistance * 1.25
    local x1, x2, y1, y2 = RHR_MOD.GetSquare(targetX, targetY, hordeDistance)

    local checkIdx = (soundIdx + 1) % 4
    if checkIdx == 0 then
        makeWorldNoise(x1, y1, hordeRadius, volume)
    elseif checkIdx == 1 then
        makeWorldNoise(x2, y2, hordeRadius, volume)
    elseif checkIdx == 2 then
        makeWorldNoise(x1, y2, hordeRadius, volume)
    else
        makeWorldNoise(x2, y1, hordeRadius, volume)
    end
    return checkIdx
end

local function makeStormGatherNoise(soundIdx, phaseUpdateFreq, targetX, targetY, hordeDistance, pulseRadius, volume)
    local x1, x2, y1, y2 = RHR_MOD.GetSquare(targetX, targetY, hordeDistance)

    local cycleLength = math.ceil(240 / phaseUpdateFreq)
    local cycleHalf = math.floor(cycleLength / 4)

    local checkIdx = (soundIdx + 1) % cycleLength
    if checkIdx < cycleHalf then
        makeWorldNoise(x1, y1, pulseRadius, volume)
    elseif checkIdx < cycleHalf * 2 then
        makeWorldNoise(x2, y2, pulseRadius, volume)
    elseif checkIdx < cycleHalf * 3 then
        makeWorldNoise(x1, y2, pulseRadius, volume)
    else
        makeWorldNoise(x2, y1, pulseRadius, volume)
    end
    return checkIdx
end

local function redirectLoadedZombie(targetX, targetY, offsetX, offsetY, distance)
    local zombieList = getCell():getZombieList()
    if not zombieList then return end

    for i = 0, zombieList:size() - 1 do
        local zed = zombieList:get(i)
        local zx, zy = zed:getX(), zed:getY()
        if RHR_MOD.IsInSquare(zx, zy, targetX, targetY, distance) then
            zed:pathToLocationF(targetX + offsetX, targetY + offsetY, 0)
        end
    end
end

function RHR_MOD.CalmPhaseEventNoise(targetX, targetY, hordeDistance)
    calmSoundIdx = makeCalmGatherNoise(calmSoundIdx, targetX, targetY, hordeDistance, 10000)
end

function RHR_MOD.StormPhaseEventNoise(targetX, targetY, offset, hordeDistance, phaseUpdateFreq)
    stormSoundIdx = makeStormGatherNoise(stormSoundIdx, phaseUpdateFreq, targetX, targetY, 110, hordeDistance*2, 10000)

    local offsetX, offsetY = ZombRandBetween(-offset, offset), ZombRandBetween(-offset, offset)
    redirectLoadedZombie(targetX, targetY, offsetX, offsetY, 120)
end
