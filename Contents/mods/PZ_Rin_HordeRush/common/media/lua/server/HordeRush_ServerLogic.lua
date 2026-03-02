require "HordeRush_Data"

local function getRandomPlayer()
    local onlinePlayers = getOnlinePlayers()
    if onlinePlayers == nil or onlinePlayers:isEmpty() then
        return nil
    end

    local playerCount = onlinePlayers:size()
    local randomIndex = ZombRand(playerCount)
    return onlinePlayers:get(randomIndex)
end

function RHR_MOD.UpdatePlayerData()
    local player
    if RHR_MOD.IsSinglePlayer() then
        player = getPlayer()
    elseif not RHR_MOD.SModData.PlayerName then
        player = getRandomPlayer()
    else
        player = getPlayerFromUsername(RHR_MOD.SModData.PlayerName)
    end

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