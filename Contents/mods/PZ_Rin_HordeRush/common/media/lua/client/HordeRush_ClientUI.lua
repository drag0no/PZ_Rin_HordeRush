require "HordeRush_Data"

local function createIcon(x, y, width, height, texture)
    local obj = {}
    obj.image = ISImage:new(x, y, width, height, texture);
    obj.image:initialise();
    obj.image:setVisible(false);
    obj.image:addToUIManager();
    return obj
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