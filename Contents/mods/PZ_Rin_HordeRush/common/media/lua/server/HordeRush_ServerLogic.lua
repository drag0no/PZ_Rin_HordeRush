require "HordeRush_Data"
require "HordeRush_Utils"

local function serverLog(msg)
    if RHR_MOD.SModData.LogCounter % RHR_MOD.SSandboxVars.LoggingFrequency == 0 then
        RHR_MOD.Log(msg)
    end
end

local function getRandomPlayer()
    local onlinePlayers = getOnlinePlayers()
    if onlinePlayers == nil or onlinePlayers:isEmpty() then
        return nil
    end

    local playerCount = onlinePlayers:size()
    local randomIndex = ZombRand(playerCount)
    return onlinePlayers:get(randomIndex)
end

local function getOnlinePlayerByUsername(username)
    local onlinePlayers = getOnlinePlayers()
    if onlinePlayers == nil or onlinePlayers:isEmpty() then
            return nil
    end

    for i = 0, onlinePlayers:size() - 1 do
        local player = onlinePlayers:get(i)
        if player and player:getUsername() == username then
            return player
        end
    end

    return nil
end

local function getOnlinePlayerByDistance(targetX, targetY, hordeDistance)
    local onlinePlayers = getOnlinePlayers()
    if onlinePlayers == nil or onlinePlayers:isEmpty() then
            return nil
    end

    local player, minDistance = nil, math.huge
    for i = 0, onlinePlayers:size() - 1 do
        local candidate = onlinePlayers:get(i)
        if RHR_MOD.IsPlayerInHordeArea(candidate, targetX, targetY, hordeDistance, 1.2) then
            local distance = RHR_MOD.GetDistance(candidate, targetX, targetY)
            if distance < minDistance then
                player, minDistance = candidate, distance
            end
        end
    end
    return player
end

local function getModPlayer()
    if RHR_MOD.IsSinglePlayer() then
        return getPlayer()
    elseif not RHR_MOD.SModData.PlayerName then
        return getRandomPlayer()
    end

    local player = getOnlinePlayerByUsername(RHR_MOD.SModData.PlayerName)
    if not player and RHR_MOD.SModData.PlayerX and RHR_MOD.SModData.PlayerY then
        player = getOnlinePlayerByDistance(RHR_MOD.SModData.PlayerX, RHR_MOD.SModData.PlayerY, RHR_MOD.SSandboxVars.HordeDistance)
    end

    return player
end

local function updatePlayerData(player)
    if not player then
        if RHR_MOD.SModData.PlayerX and RHR_MOD.SModData.PlayerY then
            return true
        else
            return false
        end
    end

    local playerSquare = player:getCurrentSquare()
    if not playerSquare then
        if RHR_MOD.SModData.PlayerX and RHR_MOD.SModData.PlayerY then
            return true
        else
            return false
        end
    end

    RHR_MOD.SModData.PlayerName = player:getUsername()
    RHR_MOD.SModData.PlayerX = playerSquare:getX()
    RHR_MOD.SModData.PlayerY = playerSquare:getY()
    return true
end


local function tryUpdateSData(phaseName)
    local player = getModPlayer()
    if not updatePlayerData(player) then
        serverLog("UpdatePhase: No Player Data. Skipping " .. phaseName .. " Phase Update.")
        return false
    end
    return true
end


function RHR_MOD.ServerCooldownPhaseUpdate()
    if RHR_MOD.IsSinglePlayer() then return end

    RHR_MOD.ClearTracking()
end

function RHR_MOD.ServerCalmPhaseUpdate()
    if not tryUpdateSData("Calm") then return end
    if RHR_MOD.IsSinglePlayer() then return end

    RHR_MOD.ClearTracking()
    RHR_MOD.CalmPhaseEventNoise(RHR_MOD.SModData.PlayerX, RHR_MOD.SModData.PlayerY, RHR_MOD.SSandboxVars.HordeDistance)
end

function RHR_MOD.ServerStormPhaseUpdate()
    if not tryUpdateSData("Storm") then return end
    if RHR_MOD.IsSinglePlayer() then return end

    RHR_MOD.SetTracking(RHR_MOD.SModData.PlayerX, RHR_MOD.SModData.PlayerY, RHR_MOD.SSandboxVars.PlayerPositionOffset)
    RHR_MOD.StormPhaseEventNoise(RHR_MOD.SModData.PlayerX, RHR_MOD.SModData.PlayerY, RHR_MOD.SSandboxVars.HordeDistance, RHR_MOD.SSandboxVars.PhaseUpdateFrequency)
end