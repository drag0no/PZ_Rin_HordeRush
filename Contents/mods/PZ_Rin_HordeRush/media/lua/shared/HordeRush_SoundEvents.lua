require "HordeRush_Data"
require "HordeRush_Utils"

local WorldSoundManager = getWorldSoundManager()

local calmSoundIdx = 0
local stormSoundIdx = 0
local tickCounter = 0
local tracking = {
    active = false,
    targetX = 0,
    targetY = 0,
    offset = 0
}

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

local function makeStormInnerNoise(targetX, targetY, offset)
    local offsetX = offset > 0 and ZombRandBetween(-offset, offset) or 0
    local offsetY = offset > 0 and ZombRandBetween(-offset, offset) or 0
    makeWorldNoise(targetX + offsetX, targetY + offsetY, 150, 20000)
end

local function processZombieRedirect(zed, targetX, targetY, offset, distance)
    if not zed:isAlive() then return end
    if zed:getTarget() ~= nil then return end
    if zed:isMoving() then return end
    if zed:getThumpTarget() ~= nil then return end

    local zx, zy = zed:getX(), zed:getY()
    if not RHR_MOD.IsInSquare(zx, zy, targetX, targetY, distance) then return end

    local offsetX = offset > 0 and ZombRandBetween(-offset, offset) or 0
    local offsetY = offset > 0 and ZombRandBetween(-offset, offset) or 0
    zed:pathToLocationF(targetX + offsetX, targetY + offsetY, 0)
end

local function redirectLoadedZombie(targetX, targetY, offset, distance)
    local cell = getCell()
    if not cell then return end

    local zombieList = cell:getZombieList()
    if not zombieList or zombieList:isEmpty() then return end

    for i = 0, zombieList:size() - 1 do
        local zed = zombieList:get(i)
        processZombieRedirect(zed, targetX, targetY, offset, distance)
    end
end

function RHR_MOD.CalmPhaseEventNoise(targetX, targetY, hordeDistance)
    calmSoundIdx = makeCalmGatherNoise(calmSoundIdx, targetX, targetY, hordeDistance, 10000)
end

function RHR_MOD.StormPhaseEventNoise(targetX, targetY, hordeDistance, phaseUpdateFreq, offset)
    stormSoundIdx = makeStormGatherNoise(stormSoundIdx, phaseUpdateFreq, targetX, targetY, 110, hordeDistance * 2, 10000)
    makeStormInnerNoise(targetX, targetY, offset or tracking.offset or 0)
end

function RHR_MOD.SetTracking(targetX, targetY, offset)
    tracking.targetX = targetX
    tracking.targetY = targetY
    tracking.offset = offset or 0
    tracking.active = true
end

function RHR_MOD.ClearTracking()
    tracking.active = false
    tickCounter = 0
end

function RHR_MOD.TrackOnTick()
    if not tracking.active then return end

    tickCounter = tickCounter + 1
    if tickCounter < 30 then return end
    tickCounter = 0

    redirectLoadedZombie(tracking.targetX, tracking.targetY, tracking.offset, 120)
end

Events.OnTick.Add(RHR_MOD.TrackOnTick)
