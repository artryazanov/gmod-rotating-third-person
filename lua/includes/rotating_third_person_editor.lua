local PANEL_WIDTH = 300
local PANEL_HEIGHT = 260
local PANEL_TITLE = "Third Person Rotating Camera"

local Editor = {}
Editor.EnableToggle = GetConVar( RTP_VAR_ADDON_ENABLED ):GetBool() or false

local function BoolToInt( bool )

    if bool then
        return 1
    else
        return 0
    end

end

local function DrawPanel( window )

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

    Editor.PANEL.EnableThird:SetPos( 10, 6 )
    Editor.PANEL.EnableThird:SetSize( 250, 20 )

    if Editor.EnableToggle then

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

    UpdateEnableButton()
    Editor.PANEL.EnableThird.DoClick = function()

        Editor.EnableToggle = not Editor.EnableToggle
        RunConsoleCommand( RTP_VAR_ADDON_ENABLED , BoolToInt( Editor.EnableToggle ) )

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

local function DrawScratchBlock( labelText, min, max, variable, yOffset )

    local value = GetConVar( variable ):GetInt()

    local label = addScratchLabel( labelText, yOffset )
    local textEntry = addScratchTextEntry( value, yOffset )
    local numberScratch = addNumberScratch( min, max, value, yOffset )

    textEntry.OnTextChanged  = function()

        local newValue = textEntry:GetValue()
        numberScratch:SetValue( newValue )
        RunConsoleCommand( variable, newValue )

    end

    numberScratch.OnValueChanged  = function()

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

local function DrawDistanceSettings( offset )

    local labelText = "Camera Distance: "
    local min = 0
    local max = 1000
    Editor.PANEL.CamDistance = DrawScratchBlock( labelText, min, max, RTP_VAR_CAMERA_FORWARD, offset )

end

local function DrawUpSettings( offset )

    local labelText = "Camera Up: "
    local min = -50
    local max = 50
    Editor.PANEL.CamUp = DrawScratchBlock( labelText, min, max, RTP_VAR_CAMERA_UP, offset )

end

local function DrawRightSettings( offset )

    local labelText = "Camera Right: "
    local min = -100
    local max = 100
    Editor.PANEL.CamRight = DrawScratchBlock( labelText, min, max, RTP_VAR_CAMERA_RIGHT, offset )

end

local function DrawFovSettings( offset )

    local labelText = "Camera FOV: "
    local min = 30
    local max = 110
    Editor.PANEL.CamFov = DrawScratchBlock( labelText, min, max, RTP_VAR_CAMERA_FOV, offset )

end

local function DrawResetButton()

    Editor.PANEL.Reset= Editor.PANEL.Settings:Add( "DButton" )
    Editor.PANEL.Reset:SizeToContents()

    Editor.PANEL.Reset:SetPos( 10, 166 )
    Editor.PANEL.Reset:SetSize( 250, 20 )

    Editor.PANEL.Reset:SetText( "Reset Settings" )
    Editor.PANEL.Reset:SetTextColor( Color( 150, 0, 0) )

    Editor.PANEL.Reset.DoClick = function()

        RunConsoleCommand( RTP_VAR_ADDON_ENABLED , RTP_DEFAULT_ADDON_ENABLED )

        RunConsoleCommand( RTP_VAR_CAMERA_FORWARD , RTP_DEFAULT_CAMERA_FORWARD )
        Editor.PANEL.CamDistance.textEntry:SetValue( RTP_DEFAULT_CAMERA_FORWARD )
        Editor.PANEL.CamDistance.textEntry.OnTextChanged()

        RunConsoleCommand( RTP_VAR_CAMERA_RIGHT , RTP_DEFAULT_CAMERA_RIGHT )
        Editor.PANEL.CamRight.textEntry:SetValue( RTP_DEFAULT_CAMERA_RIGHT )
        Editor.PANEL.CamRight.textEntry.OnTextChanged()

        RunConsoleCommand( RTP_VAR_CAMERA_UP , RTP_DEFAULT_CAMERA_UP )
        Editor.PANEL.CamUp.textEntry:SetValue( RTP_DEFAULT_CAMERA_UP )
        Editor.PANEL.CamUp.textEntry.OnTextChanged()

        RunConsoleCommand( RTP_VAR_CAMERA_FOV , RTP_DEFAULT_CAMERA_FOV )
        Editor.PANEL.CamFov.textEntry:SetValue( RTP_DEFAULT_CAMERA_FOV )
        Editor.PANEL.CamFov.textEntry.OnTextChanged()

        RunConsoleCommand( RTP_VAR_CAMERA_FOV_CHANGE_SPEED , RTP_DEFAULT_CAMERA_FOV_CHANGE_SPEED )
        RunConsoleCommand( RTP_VAR_PLAYER_ROTATION_SPEED , RTP_DEFAULT_PLAYER_ROTATION_SPEED )

    end

end

local function DrawEditor( window )

    DrawPanel( window )
    DrawSheet()
    DrawEnableButton()
    DrawDistanceSettings( 40 )
    DrawUpSettings( 70 )
    DrawRightSettings( 100 )
    DrawFovSettings( 130 )
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