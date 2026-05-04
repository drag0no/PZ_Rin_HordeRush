require "HordeRush_Data"

function RHR_MOD.IsPlayerAlive(player)
    return player and player:isAlive()
end

function RHR_MOD.IsSinglePlayer()
    return not isClient() and not isServer()
end

function RHR_MOD.IsServerAdmin(player)
    if not player then return false end
    local access = player:getAccessLevel():lower()
    return access == "admin"
end

function RHR_MOD.GetDistance(player, targetX, targetY)
    if not player then return math.huge end

    local playerSquare = player:getCurrentSquare()
    if not playerSquare then return math.huge end

    local x = playerSquare:getX()
    local y = playerSquare:getY()
    local dx = targetX - x
    local dy = targetY - y
    return math.sqrt(dx * dx + dy * dy)
end

function RHR_MOD.GetSquare(x, y, distance)
    local xMin = x - distance
    local xMax = x + distance
    local yMin = y - distance
    local yMax = y + distance
    return xMin, xMax, yMin, yMax
end

function RHR_MOD.IsInSquare(x, y, centerX, centerY, distance)
    local xMin, xMax, yMin, yMax = RHR_MOD.GetSquare(centerX, centerY, distance)
    return  x >= xMin and x <= xMax and y >= yMin and y <= yMax
end

function RHR_MOD.IsPlayerInHordeArea(player, targetX, targetY, hordeDistance, mult)
    if not player then return false end

    local playerSquare = player:getCurrentSquare()
    if not playerSquare then return false end

    local x = playerSquare:getX()
    local y = playerSquare:getY()

    return RHR_MOD.IsInSquare(x, y, targetX, targetY, hordeDistance * mult)
end
