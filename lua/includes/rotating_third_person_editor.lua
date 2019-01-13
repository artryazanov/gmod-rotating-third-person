local PANEL_WIDTH = 300
local PANEL_HEIGHT = 370
local PANEL_TITLE = "Third Person Rotating Camera"
local ELEMENTS_HEIGHT = 30

local Editor = {}

local function BoolToInt( bool )

    if bool then
        return 1
    else
        return 0
    end

end

local function getNewElementYOffset()

    local newOffset = Editor.newElementYOffset
    Editor.newElementYOffset = newOffset + ELEMENTS_HEIGHT

    return newOffset

end

local function DrawPanel( window )

    Editor.enableToggle = GetConVar( RTP_VAR_ADDON_ENABLED ):GetBool() or false
    Editor.newElementYOffset = 0

    if Editor.PANEL ~= nil then
        Editor.PANEL:Remove()
    end

    if window == nil then
        window = vgui.Create( "DFrame" )
        window:SetSize( PANEL_WIDTH, PANEL_HEIGHT )
        window:SetTitle( PANEL_TITLE )
        window:SetVisible( true )
        window:SetDraggable( true )
        window:ShowCloseButton( true )
        window:MakePopup()
    end

    Editor.PANEL = window
    Editor.PANEL:SetPos( ScrW() - PANEL_WIDTH - 10, 40 )

end

local function DrawSheet()

    Editor.PANEL.Sheet = Editor.PANEL:Add( "DPropertySheet" )
    Editor.PANEL.Sheet:Dock( LEFT )
    Editor.PANEL.Sheet:SetSize( PANEL_WIDTH - 10, 0 )
    Editor.PANEL.Sheet:SetPos( 5, 0 )

    Editor.PANEL.Settings = Editor.PANEL.Sheet:Add( "DPanelSelect" )
    Editor.PANEL.Sheet:AddSheet( "Settings", Editor.PANEL.Settings, "icon16/cog_edit.png" )

end

local function UpdateEnableButton()

    if Editor.enableToggle then

        Editor.PANEL.EnableThird:SetText( "Disable Third Person" )
        Editor.PANEL.EnableThird:SetTextColor( Color( 150, 0, 0) )

    else

        Editor.PANEL.EnableThird:SetText( "Enable Third Person" )
        Editor.PANEL.EnableThird:SetTextColor( Color( 0, 150 ,0 ) )

    end

end

local function DrawEnableButton()

    Editor.PANEL.EnableThird = Editor.PANEL.Settings:Add( "DButton" )
    Editor.PANEL.EnableThird:SizeToContents()
    Editor.PANEL.EnableThird:SetPos( 10, getNewElementYOffset() + 3 )
    Editor.PANEL.EnableThird:SetSize( 250, 20 )

    UpdateEnableButton()
    Editor.PANEL.EnableThird.DoClick = function()

        Editor.enableToggle = not Editor.enableToggle
        RunConsoleCommand( RTP_VAR_ADDON_ENABLED , BoolToInt( Editor.enableToggle ) )

        UpdateEnableButton()

    end

end

local function addScratchLabel( text, offset )

    local label = Editor.PANEL.Settings:Add( "DLabel" )
    label:SetPos( 10, offset + 5 )
    label:SetText( text )
    label:SizeToContents()

    return label

end

local function addScratchTextEntry( value, offset )

    local textEntry = Editor.PANEL.Settings:Add( "DTextEntry" )
    textEntry:SetPos( 110 , offset )
    textEntry:SetValue( value )
    textEntry:SetSize( 40, 20 )
    textEntry:SetNumeric( true )
    textEntry:SetUpdateOnType( true )

    return textEntry

end

local function addNumberScratch( min, max, value, offset )

    local numberScratch = Editor.PANEL.Settings:Add( "DNumberScratch" )
    numberScratch:SetPos( 155, offset + 2 )
    numberScratch:SetValue( value )
    numberScratch:SetMin( min )
    numberScratch:SetMax( max )
    numberScratch:SetDecimals( 0 )

    return numberScratch

end

local function DrawScratchBlock( labelText, min, max, variable )

    local yOffset = getNewElementYOffset()

    local value = GetConVar( variable ):GetInt()

    local label = addScratchLabel( labelText, yOffset )
    local textEntry = addScratchTextEntry( value, yOffset )
    local numberScratch = addNumberScratch( min, max, value, yOffset )

    textEntry.OnTextChanged = function()

        local newValue = textEntry:GetValue()
        numberScratch:SetValue( newValue )
        RunConsoleCommand( variable, newValue )

    end

    numberScratch.OnValueChanged = function()

        local newValue = numberScratch:GetTextValue()
        textEntry:SetValue( newValue )
        RunConsoleCommand( variable, newValue )

    end

    return {
        label = label,
        textEntry = textEntry,
        numberScratch = numberScratch
    }

end

local function DrawDistanceSettings()

    local labelText = "Camera Distance: "
    local min = 0
    local max = 1000
    Editor.PANEL.CamDistance = DrawScratchBlock( labelText, min, max, RTP_VAR_CAMERA_FORWARD )

end

local function DrawUpSettings()

    local labelText = "Camera Up: "
    local min = -50
    local max = 50
    Editor.PANEL.CamUp = DrawScratchBlock( labelText, min, max, RTP_VAR_CAMERA_UP )

end

local function DrawRightSettings()

    local labelText = "Camera Right: "
    local min = -100
    local max = 100
    Editor.PANEL.CamRight = DrawScratchBlock( labelText, min, max, RTP_VAR_CAMERA_RIGHT )

end

local function DrawFovSettings()

    local labelText = "Camera FOV: "
    local min = 30
    local max = 110
    Editor.PANEL.CamFov = DrawScratchBlock( labelText, min, max, RTP_VAR_CAMERA_FOV )

end

local function ResetSettings()

    RunConsoleCommand( RTP_VAR_ADDON_ENABLED, RTP_DEFAULT_ADDON_ENABLED )

    RunConsoleCommand( RTP_VAR_CAMERA_FORWARD, RTP_DEFAULT_CAMERA_FORWARD )
    Editor.PANEL.CamDistance.textEntry:SetValue( RTP_DEFAULT_CAMERA_FORWARD )
    Editor.PANEL.CamDistance.textEntry.OnTextChanged()

    RunConsoleCommand( RTP_VAR_CAMERA_RIGHT, RTP_DEFAULT_CAMERA_RIGHT )
    Editor.PANEL.CamRight.textEntry:SetValue( RTP_DEFAULT_CAMERA_RIGHT )
    Editor.PANEL.CamRight.textEntry.OnTextChanged()

    RunConsoleCommand( RTP_VAR_CAMERA_UP, RTP_DEFAULT_CAMERA_UP )
    Editor.PANEL.CamUp.textEntry:SetValue( RTP_DEFAULT_CAMERA_UP )
    Editor.PANEL.CamUp.textEntry.OnTextChanged()

    RunConsoleCommand( RTP_VAR_CAMERA_FOV, RTP_DEFAULT_CAMERA_FOV )
    Editor.PANEL.CamFov.textEntry:SetValue( RTP_DEFAULT_CAMERA_FOV )
    Editor.PANEL.CamFov.textEntry.OnTextChanged()

    RunConsoleCommand( RTP_VAR_CAMERA_FOV_CHANGE_SPEED, RTP_DEFAULT_CAMERA_FOV_CHANGE_SPEED )

    RunConsoleCommand( RTP_VAR_CAMERA_DISABLE_ROTATION_WHEN_MOVE, RTP_DEFAULT_CAMERA_DISABLE_ROTATION_WHEN_MOVE )
    Editor.PANEL.IsDisableCameraRotationWhenMove:SetValue( RTP_DEFAULT_CAMERA_DISABLE_ROTATION_WHEN_MOVE )

    RunConsoleCommand( RTP_VAR_PLAYER_ROTATION_SPEED, RTP_DEFAULT_PLAYER_ROTATION_SPEED )

    RunConsoleCommand( RTP_VAR_PLAYER_AIMING_BUTTON, RTP_DEFAULT_PLAYER_AIMING_BUTTON )
    Editor.PANEL.AimingBinder:SetValue( RTP_DEFAULT_PLAYER_AIMING_BUTTON )

    RunConsoleCommand( RTP_VAR_CROSSHAIR_HIDDEN_IF_NOT_AIMING, RTP_DEFAULT_CROSSHAIR_HIDDEN_IF_NOT_AIMING )
    Editor.PANEL.IsCrosshairHiddenIfNotAiming:SetValue( RTP_DEFAULT_CROSSHAIR_HIDDEN_IF_NOT_AIMING )

    RunConsoleCommand( RTP_VAR_CROSSHAIR_TRACE_POSITION, RTP_DEFAULT_CROSSHAIR_TRACE_POSITION )
    Editor.PANEL.IsTraceCrosshairPosition:SetValue( RTP_DEFAULT_CROSSHAIR_TRACE_POSITION )

end

local function DrawResetButton()

    Editor.PANEL.ResetButton= Editor.PANEL.Settings:Add( "DButton" )
    Editor.PANEL.ResetButton:SizeToContents()

    Editor.PANEL.ResetButton:SetPos( 10, getNewElementYOffset() + 3 )
    Editor.PANEL.ResetButton:SetSize( 250, 20 )

    Editor.PANEL.ResetButton:SetText( "Reset Settings" )
    Editor.PANEL.ResetButton:SetTextColor( Color( 150, 0, 0) )

    Editor.PANEL.ResetButton.DoClick = function()
        ResetSettings()
    end

end

local function DrawCheckBox( labelText, variable )

    local checkBox = Editor.PANEL.Settings:Add( "DCheckBoxLabel" )
    checkBox:SetPos( 8, getNewElementYOffset() + 6 )
    checkBox:SetText( labelText )
    checkBox:SetConVar( variable )
    checkBox:SetValue( GetConVar( variable ):GetBool() )

    return checkBox

end

local function DrawIsCrosshairHiddenIfNotAiming()
    Editor.PANEL.IsCrosshairHiddenIfNotAiming = DrawCheckBox( "Hide crosshair if not aiming", RTP_VAR_CROSSHAIR_HIDDEN_IF_NOT_AIMING )
end

local function DrawIsTraceCrosshairPosition()
    Editor.PANEL.IsTraceCrosshairPosition = DrawCheckBox( "Trace crosshair position", RTP_VAR_CROSSHAIR_TRACE_POSITION )
end

local function DrawIsDisableCameraRotationWhenMove()
    Editor.PANEL.IsDisableCameraRotationWhenMove = DrawCheckBox( "Disable camera rotation when move", RTP_VAR_CAMERA_DISABLE_ROTATION_WHEN_MOVE )
end

local function DrawAimingBinder()

    local offset = getNewElementYOffset()

    local label = Editor.PANEL.Settings:Add( "DLabel" )
    label:SetPos( 10, offset + 5 )
    label:SetText( 'Aiming button: ' )
    label:SizeToContents()

    Editor.PANEL.AimingBinder = Editor.PANEL.Settings:Add( "DBinder" )
    Editor.PANEL.AimingBinder:SetPos( 110, offset + 3 )
    Editor.PANEL.AimingBinder:SetSize( 150, 20 )
    Editor.PANEL.AimingBinder:SetConVar( RTP_VAR_PLAYER_AIMING_BUTTON )
    Editor.PANEL.AimingBinder:SetValue( GetConVar( RTP_VAR_PLAYER_AIMING_BUTTON ):GetInt() )

end

local function DrawEditor( window )

    DrawPanel( window )
    DrawSheet()

    DrawEnableButton()
    DrawDistanceSettings()
    DrawUpSettings()
    DrawRightSettings()
    DrawFovSettings()
    DrawAimingBinder()
    DrawIsCrosshairHiddenIfNotAiming()
    DrawIsTraceCrosshairPosition()
    DrawIsDisableCameraRotationWhenMove()
    DrawResetButton()

end

list.Set( "DesktopWindows", "RotatingThirdPerson", {
    title = PANEL_TITLE,
    icon = "icon64/rotating_third_person.png",
    width = PANEL_WIDTH,
    height = PANEL_HEIGHT,
    onewindow = true,
    init = function( icon, window )
        DrawEditor( window )
    end
} )