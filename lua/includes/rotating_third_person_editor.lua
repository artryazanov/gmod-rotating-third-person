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

local function DrawDistanceSettings( min, max, offset )

    addScratchLabel( "Camera Distance: ", offset )

    local value = GetConVar( RTP_VAR_CAMERA_FORWARD ):GetInt()

    Editor.PANEL.CamDistanceLb = addScratchTextEntry( value, offset )
    Editor.PANEL.CamDistanceLb.OnTextChanged  = function()

        Editor.PANEL.CamDistancePrf:SetValue( Editor.PANEL.CamDistanceLb:GetValue() )
        Editor.PANEL.CamDistancePrf.OnValueChanged()

    end

    Editor.PANEL.CamDistancePrf = addNumberScratch( min, max, value, offset )
    Editor.PANEL.CamDistancePrf.OnValueChanged  = function()

        Editor.PANEL.CamDistanceLb:SetValue( Editor.PANEL.CamDistancePrf:GetTextValue() )
        RunConsoleCommand( RTP_VAR_CAMERA_FORWARD ,Editor.PANEL.CamDistancePrf:GetTextValue() )

    end

end

local function DrawUpSettings( min, max, offset )

    addScratchLabel( "Camera Up: ", offset )

    local value = GetConVar( RTP_VAR_CAMERA_UP ):GetInt()

    Editor.PANEL.CamUpLb = addScratchTextEntry( value, offset )
    Editor.PANEL.CamUpLb.OnTextChanged  = function()

        Editor.PANEL.CamUpPrf:SetValue( Editor.PANEL.CamUpLb:GetValue() )
        Editor.PANEL.CamUpPrf.OnValueChanged()

    end

    Editor.PANEL.CamUpPrf = addNumberScratch( min, max, value, offset )
    Editor.PANEL.CamUpPrf.OnValueChanged  = function()

        Editor.PANEL.CamUpLb:SetValue( Editor.PANEL.CamUpPrf:GetTextValue() )
        RunConsoleCommand( RTP_VAR_CAMERA_UP ,Editor.PANEL.CamUpPrf:GetTextValue() )

    end

end

local function DrawRightSettings( min, max, offset )

    addScratchLabel( "Camera Right: ", offset )

    local value = GetConVar( RTP_VAR_CAMERA_RIGHT ):GetInt()

    Editor.PANEL.CamRightLb = addScratchTextEntry( value, offset )
    Editor.PANEL.CamRightLb.OnTextChanged  = function()

        Editor.PANEL.CamRightPrf:SetValue( Editor.PANEL.CamRightLb:GetValue() )
        Editor.PANEL.CamRightPrf.OnValueChanged()

    end

    Editor.PANEL.CamRightPrf = addNumberScratch( min, max, value, offset )
    Editor.PANEL.CamRightPrf.OnValueChanged  = function()

        Editor.PANEL.CamRightLb:SetValue( Editor.PANEL.CamRightPrf:GetTextValue() )
        RunConsoleCommand( RTP_VAR_CAMERA_RIGHT ,Editor.PANEL.CamRightPrf:GetTextValue() )

    end

end

local function DrawFovSettings( min, max, offset )

    addScratchLabel( "Camera FOV: ", offset )

    local value = GetConVar( RTP_VAR_CAMERA_FOV ):GetInt()

    Editor.PANEL.CamFovLb = addScratchTextEntry( value, offset )
    Editor.PANEL.CamFovLb.OnTextChanged  = function()

        Editor.PANEL.CamFovPrf:SetValue( Editor.PANEL.CamFovLb:GetValue() )
        Editor.PANEL.CamFovPrf.OnValueChanged()

    end

    Editor.PANEL.CamFovPrf = addNumberScratch( min, max, value, offset )
    Editor.PANEL.CamFovPrf.OnValueChanged  = function()

        Editor.PANEL.CamFovLb:SetValue( Editor.PANEL.CamFovPrf:GetTextValue() )
        RunConsoleCommand( RTP_VAR_CAMERA_FOV ,Editor.PANEL.CamFovPrf:GetTextValue() )

    end

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
        Editor.PANEL.CamDistanceLb:SetValue( RTP_DEFAULT_CAMERA_FORWARD )
        Editor.PANEL.CamDistanceLb.OnTextChanged()

        RunConsoleCommand( RTP_VAR_CAMERA_RIGHT , RTP_DEFAULT_CAMERA_RIGHT )
        Editor.PANEL.CamRightLb:SetValue( RTP_DEFAULT_CAMERA_RIGHT )
        Editor.PANEL.CamRightLb.OnTextChanged()

        RunConsoleCommand( RTP_VAR_CAMERA_UP , RTP_DEFAULT_CAMERA_UP )
        Editor.PANEL.CamUpLb:SetValue( RTP_DEFAULT_CAMERA_UP )
        Editor.PANEL.CamUpLb.OnTextChanged()

        RunConsoleCommand( RTP_VAR_CAMERA_FOV , RTP_DEFAULT_CAMERA_FOV )
        Editor.PANEL.CamFovLb:SetValue( RTP_DEFAULT_CAMERA_FOV )
        Editor.PANEL.CamFovLb.OnTextChanged()

        RunConsoleCommand( RTP_VAR_CAMERA_FOV_CHANGE_SPEED , RTP_DEFAULT_CAMERA_FOV_CHANGE_SPEED )
        RunConsoleCommand( RTP_VAR_PLAYER_ROTATION_SPEED , RTP_DEFAULT_PLAYER_ROTATION_SPEED )

    end

end

local function DrawEditor( window )

    DrawPanel( window )
    DrawSheet()
    DrawEnableButton()
    DrawDistanceSettings( 0 , 1000, 40 )
    DrawUpSettings( -50, 50, 70 )
    DrawRightSettings( -100, 100, 100 )
    DrawFovSettings( 30, 110, 130 )
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