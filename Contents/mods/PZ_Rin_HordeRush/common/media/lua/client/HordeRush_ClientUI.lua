require "HordeRush_Data"

local function createIcon(x, y, width, height, texture)
    local obj = {}
    obj.image = ISImage:new(x, y, width, height, texture);
    obj.image:initialise();
    obj.image:setVisible(false);
    obj.image:addToUIManager();
    return obj
end

local function sendSetCounterValue(player, value)
    if not value or value < 0 then
        player:Say("Error: Not a valid Counter number.")
        return
    end

    sendClientCommand(player, "HordeRush", "SetCounter", {value = value})
    if value == 0 then
        player:Say("Counter has been reset.")
    else
        player:Say("Counter set to: " .. tostring(value))
    end
end


function RHR_MOD.OnFillWorldObjectContextMenu(playerNum, context, _, _)
    local player = getSpecificPlayer(playerNum)
    if not (RHR_MOD.IsSinglePlayer() or RHR_MOD.IsServerAdmin(player)) then return end

    local adminOption = context:addOption("Horde Rush Admin")
    local subMenu = ISContextMenu:getNew(context)
    context:addSubMenu(adminOption, subMenu)

    subMenu:addOption("Reset Phase Counter", player, function()
        sendSetCounterValue(player, 0)
    end)

    subMenu:addOption("Set Phase Counter", player, function()
        -- Calculate screen center for the text box
        local core = getCore()
        local x = (core:getScreenWidth() / 2) - 140
        local y = (core:getScreenHeight() / 2) - 90

        -- Create and display the input box
        local modal = ISTextBox:new(x, y, 280, 180, "Enter new value for Counter:", "0", nil,
            function (_, button, _, _)
                if button.internal ~= "OK" then return end

                local textValue = button.parent.entry:getText()
                local floatValue = tonumber(textValue)
                sendSetCounterValue(player, floatValue)
            end,
            playerNum, "SetCounter"
        )

        modal:initialise()
        modal:addToUIManager()
    end)
end

function RHR_MOD.UISetup()
    local screenWidth = getCore():getScreenWidth()
    local x, y, width, height = screenWidth - 210, 12, 32, 32
    RHR_MOD.UI = {
        CalmIcon = createIcon(x, y, width, height, Texture.getTexture("media/ui/RHR_Calm_Icon.png")),
        StormIcon = createIcon(x, y, width, height, Texture.getTexture("media/ui/RHR_Storm_Icon.png"))
    }
end

function RHR_MOD.UIUpdate()
    if not RHR_MOD.CSandboxVars or not RHR_MOD.CurrentPhase then return end

    if RHR_MOD.CurrentPhase == 1 and RHR_MOD.CSandboxVars.CalmPhaseIcon then
        RHR_MOD.UI.CalmIcon.image:setVisible(true)
        RHR_MOD.UI.StormIcon.image:setVisible(false)
    elseif RHR_MOD.CurrentPhase == 2 and RHR_MOD.CSandboxVars.StormPhaseIcon then
        RHR_MOD.UI.CalmIcon.image:setVisible(false)
        RHR_MOD.UI.StormIcon.image:setVisible(true)
    else
        RHR_MOD.UI.CalmIcon.image:setVisible(false)
        RHR_MOD.UI.StormIcon.image:setVisible(false)
    end
end

Events.OnCreateUI.Add(RHR_MOD.UISetup)
Events.EveryOneMinute.Add(RHR_MOD.UIUpdate)
Events.OnFillWorldObjectContextMenu.Add(RHR_MOD.OnFillWorldObjectContextMenu)
