require "HordeRush_Data"
require "HordeRush_Utils"

local WorldSoundManager = getWorldSoundManager()

local calmLastIdx = 0
local calmLastTick = 0
local stormLastIdx = {}
local stormLastTick = {}

local function makeNoise(player, x, y, radius, volume)
    if player then
        WorldSoundManager:addSound(player, x, y, 0, radius, volume)
    end
end

local function makeGatherNoise(player, targetX, targetY, hordeDistance, volume, lastIdx, lastTick, waitTicks)
    lastTick = lastTick + 1
    if lastTick < waitTicks then return lastIdx, lastTick end

    local hordeRadius = hordeDistance * 1.42
    local x1, x2, y1, y2 = RHR_MOD.GetHordeSquare(targetX, targetY, hordeDistance)

    local checkIdx = (lastIdx + 1) % 6
    if checkIdx == 0 then
        makeNoise(player,x1, y1, hordeRadius, volume)
    elseif checkIdx == 1 then
        makeNoise(player,x2, y2, hordeRadius, volume)
    elseif checkIdx == 2 then
        -- do nothing
    elseif checkIdx == 3 then
        makeNoise(player,x1, y2, hordeRadius, volume)
    elseif checkIdx == 4 then
        makeNoise(player,x2, y1, hordeRadius, volume)
    elseif checkIdx == 5 then
        -- do nothing
    end

    lastTick = 0
    return checkIdx, lastTick
end

function RHR_MOD.CalmPhaseEventNoise(player, targetX, targetY, hordeDistance)
    calmLastIdx, calmLastTick = makeGatherNoise(player, targetX, targetY, hordeDistance, 5000, calmLastIdx, calmLastTick, 5)
end

function RHR_MOD.StormPhaseEventNoise(player, targetX, targetY, offset, hordeDistance)
    local idx = 0
    local volume = 1000
    local currDistance = hordeDistance
    while currDistance > 0 do
        if not stormLastIdx[idx] then stormLastIdx[idx] = 0 end
        if not stormLastTick[idx] then stormLastTick[idx] = 0 end

        if currDistance < 110 then
            stormLastIdx[idx], stormLastTick[idx] = makeGatherNoise(player, targetX, targetY, 105, volume, stormLastIdx[idx], stormLastTick[idx], 0)
            break
        else
            stormLastIdx[idx], stormLastTick[idx] = makeGatherNoise(player, targetX, targetY, currDistance, volume, stormLastIdx[idx], stormLastTick[idx], 0)
            currDistance = currDistance - 100
            volume = volume + 1000
            idx = idx + 1
        end
    end

    local offsetX, offsetY = ZombRandBetween(-offset, offset), ZombRandBetween(-offset, offset)
    local x, y = targetX + offsetX, targetY + offsetY
    makeNoise(player, x, y, hordeDistance * 2, volume + 1000)
end

