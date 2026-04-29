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

function RHR_MOD.GetHordeSquare(x, y, hordeDistance)
    local xMin = x - hordeDistance
    local xMax = x + hordeDistance
    local yMin = y - hordeDistance
    local yMax = y + hordeDistance
    return xMin, xMax, yMin, yMax
end

function RHR_MOD.IsPlayerInHordeArea(player, targetX, targetY, hordeDistance, mult)
    if not player then return false end

    local playerSquare = player:getCurrentSquare()
    if not playerSquare then return false end

    local x = playerSquare:getX()
    local y = playerSquare:getY()
    local xMin, xMax, yMin, yMax = RHR_MOD.GetHordeSquare(targetX, targetY, hordeDistance * mult)

    return  x >= xMin and x <= xMax and y >= yMin and y <= yMax
end
