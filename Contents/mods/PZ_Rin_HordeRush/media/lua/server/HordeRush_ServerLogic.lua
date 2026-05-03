require "HordeRush_Data"
require "HordeRush_Utils"

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

function RHR_MOD.GetModPlayer()
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

function RHR_MOD.UpdatePlayerData(player)
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
