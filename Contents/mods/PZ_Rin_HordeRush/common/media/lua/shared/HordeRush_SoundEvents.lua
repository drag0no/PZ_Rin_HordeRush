require "HordeRush_Data"
require "HordeRush_Utils"

local WorldSoundManager = getWorldSoundManager()

local lastCalmIdx = 0
local lastStormIdx = 0

local function makeNoise(player, x, y, radius, volume)
    if player then
        WorldSoundManager:addSound(player, x, y, 0, radius, volume)
    end
end

local function makeGatherNoise(player, targetX, targetY, hordeDistance, volume, lastIdx)
    local hordeRadius = hordeDistance * 1.42
    local x1, x2, y1, y2 = RHR_MOD.GetHordeSquare(targetX, targetY, hordeDistance)

    local checkIdx = (lastIdx + 1) % 4
    if checkIdx == 0 then
        makeNoise(player,x2, y1, hordeRadius, volume)
    elseif checkIdx == 1 then
        makeNoise(player,x1, y1, hordeRadius, volume - 500)
    elseif checkIdx == 2 then
        makeNoise(player,x2, y2, hordeRadius, volume - 1000)
    elseif checkIdx == 3 then
        makeNoise(player,x1, y2, hordeRadius, volume - 1500)
    end
    return checkIdx
end

function RHR_MOD.CalmPhaseEventNoise(player, targetX, targetY, hordeDistance)
    lastCalmIdx = makeGatherNoise(player, targetX, targetY, hordeDistance, 5000, lastCalmIdx)
end

function RHR_MOD.StormPhaseEventNoise(player, targetX, targetY, offset, hordeDistance)
    lastStormIdx = makeGatherNoise(player, targetX, targetY, 110, 1000, lastStormIdx)

    local offsetX, offsetY = ZombRandBetween(-offset, offset), ZombRandBetween(-offset, offset)
    local x, y = targetX + offsetX, targetY + offsetY
    makeNoise(player, x, y, hordeDistance * 2, 5000)
end

