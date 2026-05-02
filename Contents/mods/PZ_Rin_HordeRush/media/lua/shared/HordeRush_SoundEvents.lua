require "HordeRush_Data"
require "HordeRush_Utils"

local WorldSoundManager = getWorldSoundManager()

local function makeNoise(player, x, y, radius)
    if player then
        WorldSoundManager:addSound(player, x, y, 0, radius, radius * 5000)
    end
end

function RHR_MOD.MakeCalmPhaseNoise(player, sandboxVars, targetX, targetY)
    local hordeDistance = sandboxVars.HordeDistance
    local hordeRadius = sandboxVars.HordeRadius

    local x1, x2, y1, y2 = RHR_MOD.GetHordeSquare(targetX, targetY, hordeDistance)

    if sandboxVars.MigrationNorth then makeNoise(player,targetX, y1, hordeRadius) end
    if sandboxVars.MigrationEast then makeNoise(player,x2, targetY, hordeRadius) end
    if sandboxVars.MigrationWest then makeNoise(player,x1, targetY, hordeRadius) end
    if sandboxVars.MigrationSouth then makeNoise(player,targetX, y2, hordeRadius) end
    if sandboxVars.MigrationNorthEast then makeNoise(player,x2, y1, hordeRadius) end
    if sandboxVars.MigrationNorthWest then makeNoise(player,x1, y1, hordeRadius) end
    if sandboxVars.MigrationSouthEast then makeNoise(player,x2, y2, hordeRadius) end
    if sandboxVars.MigrationSouthWest then makeNoise(player,x1, y2, hordeRadius) end
end

function RHR_MOD.MakeStormPhaseNoise(player, sandboxVars, targetX, targetY)
    local offset = sandboxVars.PlayerPositionOffset
    local hordeDistance = sandboxVars.HordeDistance

    local x = targetX + ZombRandBetween(-offset, offset)
    local y = targetY + ZombRandBetween(-offset, offset)

    makeNoise(player,x, y, hordeDistance * 1.5)
end
