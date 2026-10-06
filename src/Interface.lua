-- -----------------------------------------------------------------------------
-- PvPCooldownTracker
-- Author:  @VixenHunny
-- Edited: 4/15/2026
--
-- Interface.lua
-- -----------------------------------------------------------------------------
PvPCooldownTracker = PvPCooldownTracker or {}
PvPCooldownTracker.UI = {}
PvPCooldownTracker.UI.scaleBase = 100

local scaleBase = PvPCooldownTracker.UI.scaleBase
local PCT = PvPCooldownTracker
local WM = WINDOW_MANAGER
local AM = ANIMATION_MANAGER
local CONTAINER_SUFFIX = "_Container"
local TEXTURE_SUFFIX = "_Texture"
local FRAME_SUFFIX = "_Frame"
local LABEL_SUFFIX = "_Label"
local SET_LABEL_SUFFIX = "_123"
local GLOW_SUFFIX = "_Glow"
local NAME_LABEL_SUFFIX = "_NameLabel"
local BAR_BG_SUFFIX = "_BarBG"
local BAR_FILL_SUFFIX = "_BarFill"

local UI_WIDTH = 340
local UI_HEIGHT = 76
local ICON_SIZE = 64
local ICON_OFFSET_X = 36
local BAR_WIDTH = 232
local BAR_HEIGHT = 20
local BAR_OFFSET_X = 94
local BAR_OFFSET_Y = 14

local function GetControl(setKey, suffix)
    return WM:GetControlByName(setKey .. suffix)
end

local function GetSavedVars()
    if PCT.Settings and type(PCT.Settings.EnsureState) == "function" then
        return PCT.Settings.EnsureState()
    end

    if type(PCT.EnsureSavedVariables) == "function" then
        local savedVars = PCT.EnsureSavedVariables()
        return savedVars or {}
    end

    return PCT.savedVars or {}
end

local function IsStateContainer(value)
    if type(PCT.IsStateContainer) == "function" then
        return PCT.IsStateContainer(value)
    end

    local valueType = type(value)
    return value ~= nil and (valueType == "table" or valueType == "userdata")
end

local function GetStyleTable()
    local savedVars = GetSavedVars()
    local style = savedVars.style
    if not IsStateContainer(style) then
        return nil
    end
    return style
end

local function ApplySetLabelStyle(setLabel)
    local savedVars = GetSavedVars()
    local style = GetStyleTable()
    local color = (style and style.labelColor) or { 1, 1, 1, 1 }
    setLabel:SetColor(color[1], color[2], color[3], color[4])
    setLabel:SetFont(savedVars.labelFont or "$(BOLD_FONT)|18|soft-shadow-thick")
    setLabel:SetHorizontalAlignment(CENTER)
    setLabel:SetVerticalAlignment(TOP)
    setLabel:SetPixelRoundingEnabled(true)
    setLabel:SetScale(savedVars.labelSize / scaleBase)
end

local function ApplyNameLabelStyle(nameLabel)
    local savedVars = GetSavedVars()
    local style = GetStyleTable()
    local color = (style and style.labelColor) or { 1, 1, 1, 1 }
    nameLabel:SetColor(color[1], color[2], color[3], color[4])
    nameLabel:SetFont(savedVars.labelFont or "$(BOLD_FONT)|18|soft-shadow-thick")
    nameLabel:SetHorizontalAlignment(LEFT)
    nameLabel:SetVerticalAlignment(CENTER)
    nameLabel:SetPixelRoundingEnabled(true)
end

local function ApplyTimerLabelStyle(label)
    local savedVars = GetSavedVars()
    local style = GetStyleTable()
    local color = (style and style.timerColor) or { 1, 1, 1, 1 }
    label:SetColor(color[1], color[2], color[3], color[4])
    label:SetFont(savedVars.timerFont or "$(BOLD_FONT)|22|soft-shadow-thick")
    label:SetVerticalAlignment(TOP)
    label:SetHorizontalAlignment(RIGHT)
    label:SetPixelRoundingEnabled(true)
end

local function AnchorSetLabel(setLabel)
    local savedVars = GetSavedVars()
    local labelLocation = savedVars.LabelLocation or {}
    local labelX = tonumber(labelLocation.x) or 600
    local labelY = tonumber(labelLocation.y) or 300

    setLabel:ClearAnchors()
    setLabel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, labelX, labelY)
end

local function SnapToGrid(position, gridSize)
    -- Round down
    position = math.floor(position)

    -- Return value to closest grid point
    if (position % gridSize >= gridSize / 2) then
        return position + (gridSize - (position % gridSize))
    else
        return position - (position % gridSize)
    end
end
local function SetPosition(key, container, left, top)
    PCT:Trace(2, "Setting - Left: " .. left .. " Top: " .. top)
    local context = GetControl(key, container)
    if context == nil then return end
    context:ClearAnchors()
    context:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

local function SavePosition(key)
    local savedVars = GetSavedVars()
    local context = GetControl(key, CONTAINER_SUFFIX)
    if context == nil then return end
    local top   = context:GetTop()
    local left  = context:GetLeft()

    if savedVars.snapToGrid then
        local gridSize = savedVars.gridSize
        top = SnapToGrid(top, gridSize)
        left = SnapToGrid(left, gridSize)
        SetPosition(key, CONTAINER_SUFFIX, left, top)
    end

    PCT:Trace(2, "Saving position for <<1>> - Left: <<2>> Top: <<3>>", key, left, top)

    if savedVars.sets and savedVars.sets[key] then
        savedVars.sets[key].x = left
        savedVars.sets[key].y = top
    end
end

local function EnsureSetControls(key, set, saved)
    local savedVars = GetSavedVars()
    local container = GetControl(key, CONTAINER_SUFFIX)
    if container == nil then
        container = WM:CreateTopLevelWindow(key .. CONTAINER_SUFFIX)
        container:SetHandler("OnMoveStop", function() SavePosition(key) end)
    end

    container:SetClampedToScreen(true)
    container:SetDimensions(UI_WIDTH, UI_HEIGHT)
    container:SetMouseEnabled(true)
    container:SetMovable(savedVars.unlocked)
    container:SetAlpha(1)
    container:SetScale(saved.size / scaleBase)
    container:SetHidden(PCT.HUDHidden and not PCT.ForceShow)

    local texture = GetControl(key, TEXTURE_SUFFIX)
    if texture == nil then
        texture = WM:CreateControl(key .. TEXTURE_SUFFIX, container, CT_TEXTURE)
    end
    texture:SetTexture(set.texture)
    texture:SetDimensions(ICON_SIZE, ICON_SIZE)
    texture:SetAnchor(LEFT, container, LEFT, ICON_OFFSET_X, 0)

    local glow = GetControl(key, GLOW_SUFFIX)
    if glow == nil then
        glow = WM:CreateControl(key .. GLOW_SUFFIX, container, CT_TEXTURE)
    end
    glow:SetTexture("/esoui/art/actionbar/abilityhighlight_round.dds")
    glow:SetDimensions(ICON_SIZE + 24, ICON_SIZE + 24)
    glow:SetAnchor(CENTER, texture, CENTER, 0, 0)
    local style = GetStyleTable()
    local glowColor = (style and style.glowColor) or { 0.92, 0.40, 0.18, 0.45 }
    glow:SetColor(glowColor[1], glowColor[2], glowColor[3], glowColor[4])
    glow:SetAlpha(0.15)

    local frame = GetControl(key, FRAME_SUFFIX)
    if set.showFrame then
        if frame == nil then
            frame = WM:CreateControl(key .. FRAME_SUFFIX, container, CT_TEXTURE)
        end

        if set.procType == "passive" then
            frame:SetTexture("/esoui/art/actionbar/passiveabilityframe_round_up.dds")
            frame:SetDimensions(ICON_SIZE + 5, ICON_SIZE + 5)
        else
            frame:SetTexture("/esoui/art/actionbar/gamepad/gp_abilityframe64.dds")
            frame:SetDimensions(ICON_SIZE, ICON_SIZE)
        end

        frame:SetAnchor(CENTER, texture, CENTER, 0, 0)
        frame:SetHidden(false)
    elseif frame ~= nil then
        frame:SetHidden(true)
    end

    local barBg = GetControl(key, BAR_BG_SUFFIX)
    if barBg == nil then
        barBg = WM:CreateControl(key .. BAR_BG_SUFFIX, container, CT_BACKDROP)
    end
    barBg:SetDimensions(BAR_WIDTH, BAR_HEIGHT)
    barBg:SetAnchor(TOPLEFT, container, TOPLEFT, BAR_OFFSET_X, BAR_OFFSET_Y)
    barBg:SetEdgeTexture(nil, 1, 1, 1)
    barBg:SetEdgeColor(0.45, 0.45, 0.45, 0.9)
    local barBackground = (style and style.barBackgroundColor) or { 0.08, 0.08, 0.08, 0.80 }
    barBg:SetCenterColor(barBackground[1], barBackground[2], barBackground[3], barBackground[4])

    local barFill = GetControl(key, BAR_FILL_SUFFIX)
    if barFill == nil then
        barFill = WM:CreateControl(key .. BAR_FILL_SUFFIX, barBg, CT_STATUSBAR)
    end
    barFill:SetAnchor(TOPLEFT, barBg, TOPLEFT, 2, 2)
    barFill:SetAnchor(BOTTOMRIGHT, barBg, BOTTOMRIGHT, -2, -2)
    barFill:SetTexture("/esoui/art/miscellaneous/progressbar_genericfill.dds")
    barFill:SetMinMax(0, 1)
    barFill:SetValue(1)
    local readyColor = (style and style.barReadyColor) or { 0.42, 0.72, 0.24, 0.95 }
    barFill:SetColor(readyColor[1], readyColor[2], readyColor[3], readyColor[4])

    local timerLabel = GetControl(key, LABEL_SUFFIX)
    if timerLabel == nil then
        timerLabel = WM:CreateControl(key .. LABEL_SUFFIX, container, CT_LABEL)
    end
    timerLabel:SetAnchor(RIGHT, barBg, RIGHT, -6, 0)
    ApplyTimerLabelStyle(timerLabel)

    local nameLabel = GetControl(key, NAME_LABEL_SUFFIX)
    if nameLabel == nil then
        nameLabel = WM:CreateControl(key .. NAME_LABEL_SUFFIX, container, CT_LABEL)
    end
    nameLabel:SetAnchor(BOTTOMLEFT, barBg, TOPLEFT, 2, -2)
    nameLabel:SetDimensions(BAR_WIDTH - 8, 20)
    ApplyNameLabelStyle(nameLabel)
    nameLabel:SetText(tostring(key))

    local setLabel = GetControl(key, SET_LABEL_SUFFIX)
    if setLabel == nil then
        setLabel = WM:CreateControl(key .. SET_LABEL_SUFFIX, container, CT_LABEL)
    end
    ApplySetLabelStyle(setLabel)
    AnchorSetLabel(setLabel)

    SetPosition(key, CONTAINER_SUFFIX, saved.x, saved.y)

    return container
end

function PvPCooldownTracker.UI.Draw(key)
    local set = PCT.Data.Sets[key]
    if set == nil then return end

    local container = GetControl(key, CONTAINER_SUFFIX)
    if set.enabled then
        local savedVars = GetSavedVars()
        local saved = savedVars.sets and savedVars.sets[key]
        if saved == nil and PCT.Settings and type(PCT.Settings.EnsureSetSavedVars) == "function" then
            saved = PCT.Settings.EnsureSetSavedVars(key)
        end
        if saved == nil then return end

        PCT:Trace(2, "Drawing: <<1>>", key)
        container = EnsureSetControls(key, set, saved)

        if container and not PCT.HUDHidden then
            container:SetHidden(false)
        end
    elseif container ~= nil then
        container:SetHidden(true)
    end

    PCT:Trace(2, "Finished DrawUI()")
end

function PvPCooldownTracker.UI:SetCombatStateDisplay()
    PCT:Trace(3, "Setting combat state display, in combat: <<1>>", tostring(PCT.isInCombat))
    local savedVars = GetSavedVars()

    if PCT.isInCombat or (savedVars.showOutsideCombat and not PCT.isDead) then
        PCT.UI.ShowIcon(true)
    else
        PCT.UI.ShowIcon(false)
    end
end

function PvPCooldownTracker.UI.PlaySound(sound)
    if sound and sound.enabled then
        PlaySound(SOUNDS[sound.sound])
    end
end

local function PlayStatusAnimation(setKey, text)
    local container = GetControl(setKey, CONTAINER_SUFFIX)
    local setLabel = GetControl(setKey, SET_LABEL_SUFFIX)
    if not container or not setLabel then return end

    local savedVars = GetSavedVars()
    local animation = AM:CreateTimeline(true)
    local slide = animation:InsertAnimation(ANIMATION_TRANSLATE, setLabel, 0)
    local fade = animation:InsertAnimation(ANIMATION_ALPHA, setLabel, 200)

    slide:SetTranslateOffsets(0, 0, 0, -120)
    slide:SetDuration(900)
    slide:SetEasingFunction(ZO_EaseInCubic)

    fade:SetAlphaValues(1, 0)
    fade:SetDuration(900)
    fade:SetEasingFunction(ZO_EaseOutCubic)

    animation:SetHandler("OnPlay", function()
        setLabel:SetAlpha(1)
        setLabel:SetScale(savedVars.labelSize / scaleBase)
        setLabel:SetText(text)
    end)

    animation:SetHandler("OnStop", function()
        local set = PCT.Data.Sets[setKey]
        if set and set.onCooldown then
            setLabel:SetText(string.format("|c%s%s|r", savedVars.set_active, setKey))
        else
            setLabel:SetText("")
        end

        setLabel:SetAlpha(1)
        AnchorSetLabel(setLabel)
        setLabel:SetScale(savedVars.labelSize / scaleBase)
    end)

    animation:PlayFromStart()
end

function PvPCooldownTracker:SetAppearance(x, y, setKey)
    if setKey == nil then return end

    local savedVars = GetSavedVars()
    local saved = savedVars.sets and savedVars.sets[setKey]
    if saved == nil and PCT.Settings and type(PCT.Settings.EnsureSetSavedVars) == "function" then
        saved = PCT.Settings.EnsureSetSavedVars(setKey)
    end
    if saved == nil then return end

    PCT:Trace(3, "Setting appearance for <<1>> X: <<2>> Y: <<3>>", setKey, x, y)

    local set = PCT.Data.Sets[setKey]
    if not set then return end

    if set.enabled then
        EnsureSetControls(setKey, set, saved)
    end

    local container = GetControl(setKey, CONTAINER_SUFFIX)
    if container ~= nil then
        container:SetScale(saved.size / scaleBase)
        SetPosition(setKey, CONTAINER_SUFFIX, saved.x, saved.y)
    end

    local setLabel = GetControl(setKey, SET_LABEL_SUFFIX)
    if setLabel and container then
        ApplySetLabelStyle(setLabel)
        AnchorSetLabel(setLabel)
    end

    local label = GetControl(setKey, LABEL_SUFFIX)
    if label then
        ApplyTimerLabelStyle(label)
    end

    local nameLabel = GetControl(setKey, NAME_LABEL_SUFFIX)
    if nameLabel then
        ApplyNameLabelStyle(nameLabel)
        nameLabel:SetText(tostring(setKey))
    end

    local barBg = GetControl(setKey, BAR_BG_SUFFIX)
    if barBg then
        local style = GetStyleTable()
        local bgColor = (style and style.barBackgroundColor) or { 0.08, 0.08, 0.08, 0.80 }
        barBg:SetCenterColor(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
    end

    PCT:Trace(3, "SetAppearance complete")
end
function PvPCooldownTracker:Check_Cooldown(setKey)
    local set = PCT.Data.Sets[setKey]
    return set ~= nil and set.onCooldown == true
end
function PvPCooldownTracker.UI.Update(setKey)
    local set = PCT.Data.Sets[setKey]
    if not set then return end

    local savedVars = GetSavedVars()
    local saved = savedVars.sets and savedVars.sets[setKey]
    if saved == nil and PCT.Settings and type(PCT.Settings.EnsureSetSavedVars) == "function" then
        saved = PCT.Settings.EnsureSetSavedVars(setKey)
    end
    if not saved then return end

    if set.enabled then
        EnsureSetControls(setKey, set, saved)
    end

    local container = GetControl(setKey, CONTAINER_SUFFIX)
    local texture = GetControl(setKey, TEXTURE_SUFFIX)
    local label = GetControl(setKey, LABEL_SUFFIX)
    local setLabel = GetControl(setKey, SET_LABEL_SUFFIX)
    local nameLabel = GetControl(setKey, NAME_LABEL_SUFFIX)
    local barFill = GetControl(setKey, BAR_FILL_SUFFIX)
    local glow = GetControl(setKey, GLOW_SUFFIX)
    if not container or not texture or not label or not setLabel then return end
    local style = GetStyleTable()

    if nameLabel then
        nameLabel:SetText(tostring(setKey))
    end

    local savedVars = GetSavedVars()
    if PCT.first_run[setKey] or set.justProcced then
        PCT.first_run[setKey] = nil
        set.justProcced = false
        PlayStatusAnimation(setKey, string.format("|c%s%s Cooling Down|r", savedVars.set_active, setKey))
    end

    if not set.onCooldown then
        label:SetText("")
        setLabel:SetText("")
        texture:SetColor(1, 1, 1, 1)
        if barFill then
            local readyColor = (style and style.barReadyColor) or { 0.42, 0.72, 0.24, 0.95 }
            barFill:SetColor(readyColor[1], readyColor[2], readyColor[3], readyColor[4])
            barFill:SetValue(1)
        end
        if glow then
            glow:SetAlpha(0.15)
        end
        return
    end

    local cooldownTint = (style and style.cooldownTint) or { 0.55, 0.48, 0.48, 1.0 }
    texture:SetTexture(set.texture)
    texture:SetColor(cooldownTint[1], cooldownTint[2], cooldownTint[3], cooldownTint[4])
    if glow then
        glow:SetAlpha(0.42)
    end

    local countdown = (set.timeOfProc + set.cooldownDurationMs - GetGameTimeMilliseconds()) / 1000
    if countdown <= 0 then
        set.onCooldown = false
        EVENT_MANAGER:UnregisterForUpdate(PCT.name .. setKey .. "Count")
        label:SetText("")
        texture:SetColor(1, 1, 1, 1)
        if barFill then
            local readyColor = (style and style.barReadyColor) or { 0.42, 0.72, 0.24, 0.95 }
            barFill:SetColor(readyColor[1], readyColor[2], readyColor[3], readyColor[4])
            barFill:SetValue(1)
        end
        if glow then
            glow:SetAlpha(0.20)
        end

        PlayStatusAnimation(setKey, string.format("|c%s%s Ready!|r", savedVars.cooldown_expired, setKey))
        if savedVars.sets and savedVars.sets[setKey] and savedVars.sets[setKey].sounds then
            PCT.UI.PlaySound(savedVars.sets[setKey].sounds.onReady)
        end
        return
    end

    local countdownText
    if countdown < 10 then
        countdownText = string.format("%.1f", countdown)
    else
        countdownText = tostring(math.floor(countdown + 0.5))
    end

    label:SetText(countdownText)
    setLabel:SetText("")

    if barFill then
        local durationSeconds = math.max(0.1, set.cooldownDurationMs / 1000)
        local progress = countdown / durationSeconds
        progress = math.max(0, math.min(1, progress))
        local barColor = (style and style.barFillColor) or { 0.84, 0.46, 0.20, 0.95 }
        barFill:SetColor(barColor[1], barColor[2], barColor[3], barColor[4])
        barFill:SetValue(progress)
    end

end

function PvPCooldownTracker.UI.ToggleHUD()
    local hudScene = SCENE_MANAGER:GetScene("hud")
    hudScene:RegisterCallback("StateChange", function(oldState, newState)

        -- Don't change states if display should be forced to show
        if PCT.ForceShow then return end

        -- Transitioning to a menu/non-HUD
        if newState == SCENE_HIDDEN and SCENE_MANAGER:GetNextScene():GetName() ~= "hudui" then
            PCT:Trace(3, "Hiding HUD")
            PCT.HUDHidden = true
            PCT.UI:SetCombatStateDisplay()
        end

        -- Transitioning to a HUD/non-menu
        if newState == SCENE_SHOWING then
            PCT:Trace(3, "Showing HUD")
            PCT.HUDHidden = false
            PCT.UI:SetCombatStateDisplay()
        end
    end)

    PCT:Trace(2, "Finished ToggleHUD()")
end

function PvPCooldownTracker.UI.ShowIcon(shouldShow)

    for key, set in pairs(PCT.Data.Sets) do
        local context = WM:GetControlByName(key .. "_Container")
        if context ~= nil then
            if PCT.ForceShow and set.enabled then
                context:SetHidden(false)
            elseif (shouldShow and set.enabled and not PCT.HUDHidden) then
                context:SetHidden(false)
            else
                context:SetHidden(true)
            end
        end
    end

end

function PvPCooldownTracker.UI.SlashCommand(command)
    local prefix = PCT.prefix or "[PCT] "
    local savedVars = GetSavedVars()

    if savedVars == nil
        and PCT.Settings
        and type(PCT.Settings.EnsureState) == "function"
    then
        savedVars = PCT.Settings.EnsureState()
    end

    -- Debug Options ----------------------------------------------------------
    if command == "debug 0" then
        d(prefix .. "Setting debug level to 0 (Off)")
        PCT.debugMode = 0
        if savedVars ~= nil then
            savedVars.debugMode = 0
        end
    elseif command == "debug 1" then
        d(prefix .. "Setting debug level to 1 (Low)")
        PCT.debugMode = 1
        if savedVars ~= nil then
            savedVars.debugMode = 1
        end
    elseif command == "debug 2" then
        d(prefix .. "Setting debug level to 2 (Medium)")
        PCT.debugMode = 2
        if savedVars ~= nil then
            savedVars.debugMode = 2
        end
    elseif command == "debug 3" then
        d(prefix .. "Setting debug level to 3 (High)")
        PCT.debugMode = 3
        if savedVars ~= nil then
            savedVars.debugMode = 3
            d(prefix .. "Debug mode set to 3, showing all debug messages!")
        end

    -- Unfiltered Events
    elseif command == "all on" then
        d(prefix .. "Registering unfiltered events, setting debug mode to 1")
        PCT.debugMode = 1
        if savedVars ~= nil then
            savedVars.debugMode = 1
        end
        PCT.Tracking.RegisterUnfiltered()
    elseif command == "all off" then
        d(prefix .. "Unregistering unfiltered events, setting debug mode to 0")
        PCT.Tracking.UnregisterUnfiltered()
        PCT.debugMode = 0
        if savedVars ~= nil then
            savedVars.debugMode = 0
        end

    -- Default ----------------------------------------------------------------
    else
        d(prefix .. "Command not recognized!")
    end
end
