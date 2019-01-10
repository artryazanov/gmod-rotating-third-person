local PANEL_WIDTH = 300
local PANEL_HEIGHT = 260
local PANEL_TITLE = "Third Person Rotating Camera"

local Editor = {}
Editor.EnableToggle = GetConVar( RTP_VAR_MOD_ENABLED ):GetBool() or false

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
        RunConsoleCommand( RTP_VAR_MOD_ENABLED , BoolToInt( Editor.EnableToggle ) )

        UpdateEnableButton()

    end

end

local function DrawDistanceSettings( min, max, offset )

    Editor.PANEL.CamDistanceTxt = Editor.PANEL.Settings:Add( "DLabel" )
    Editor.PANEL.CamDistanceTxt:SetPos( 10, offset + 5 )
    Editor.PANEL.CamDistanceTxt:SetText( "Camera Distance: " )
    Editor.PANEL.CamDistanceTxt:SizeToContents()

    Editor.PANEL.CamDistanceLb = Editor.PANEL.Settings:Add( "DTextEntry" )
    Editor.PANEL.CamDistanceLb:SetPos( 110 , offset )
    Editor.PANEL.CamDistanceLb:SetValue(GetConVar( RTP_VAR_CAMERA_FORWARD ):GetInt())
    Editor.PANEL.CamDistanceLb:SetSize( 40, 20 )
    Editor.PANEL.CamDistanceLb:SetNumeric( true )
    Editor.PANEL.CamDistanceLb:SetUpdateOnType( true )
    Editor.PANEL.CamDistanceLb.OnTextChanged  = function()

        Editor.PANEL.CamDistance_PRF:SetValue( Editor.PANEL.CamDistanceLb:GetValue() )
        Editor.PANEL.CamDistance_PRF.OnValueChanged()

    end

    Editor.PANEL.CamDistance_PRF = Editor.PANEL.Settings:Add( "DNumberScratch" )
    Editor.PANEL.CamDistance_PRF:SetPos( 155, offset + 2 )
    Editor.PANEL.CamDistance_PRF:SetValue( GetConVar( RTP_VAR_CAMERA_FORWARD ):GetInt() )
    Editor.PANEL.CamDistance_PRF:SetMin( min )
    Editor.PANEL.CamDistance_PRF:SetMax( max )
    Editor.PANEL.CamDistance_PRF:SetDecimals( 0 )
    Editor.PANEL.CamDistance_PRF.OnValueChanged  = function()

        Editor.PANEL.CamDistanceLb:SetValue( Editor.PANEL.CamDistance_PRF:GetTextValue() )
        RunConsoleCommand( RTP_VAR_CAMERA_FORWARD ,Editor.PANEL.CamDistance_PRF:GetTextValue() )

    end

end

local function DrawUpSettings( min, max, offset )

    Editor.PANEL.CamUpTxt = Editor.PANEL.Settings:Add( "DLabel" )
    Editor.PANEL.CamUpTxt:SetPos( 10, offset + 5 )
    Editor.PANEL.CamUpTxt:SetText( "Camera Up: " )
    Editor.PANEL.CamUpTxt:SizeToContents()

    Editor.PANEL.CamUpLb = Editor.PANEL.Settings:Add( "DTextEntry" )
    Editor.PANEL.CamUpLb:SetPos( 110 , offset )
    Editor.PANEL.CamUpLb:SetValue(GetConVar( RTP_VAR_CAMERA_UP ):GetInt())
    Editor.PANEL.CamUpLb:SetSize( 40, 20 )
    Editor.PANEL.CamUpLb:SetNumeric( true )
    Editor.PANEL.CamUpLb:SetUpdateOnType( true )
    Editor.PANEL.CamUpLb.OnTextChanged  = function()

        Editor.PANEL.CamUp_PRF:SetValue( Editor.PANEL.CamUpLb:GetValue() )
        Editor.PANEL.CamUp_PRF.OnValueChanged()

    end

    Editor.PANEL.CamUp_PRF = Editor.PANEL.Settings:Add( "DNumberScratch" )
    Editor.PANEL.CamUp_PRF:SetPos( 155, offset + 2 )
    Editor.PANEL.CamUp_PRF:SetValue( GetConVar( RTP_VAR_CAMERA_UP ):GetInt() )
    Editor.PANEL.CamUp_PRF:SetMin( min )
    Editor.PANEL.CamUp_PRF:SetMax( max )
    Editor.PANEL.CamUp_PRF:SetDecimals( 0 )
    Editor.PANEL.CamUp_PRF.OnValueChanged  = function()

        Editor.PANEL.CamUpLb:SetValue( Editor.PANEL.CamUp_PRF:GetTextValue() )
        RunConsoleCommand( RTP_VAR_CAMERA_UP ,Editor.PANEL.CamUp_PRF:GetTextValue() )

    end

end

local function DrawRightSettings( min, max, offset )

    Editor.PANEL.CamRightTxt = Editor.PANEL.Settings:Add( "DLabel" )
    Editor.PANEL.CamRightTxt:SetPos( 10, offset + 5 )
    Editor.PANEL.CamRightTxt:SetText( "Camera Right: " )
    Editor.PANEL.CamRightTxt:SizeToContents()

    Editor.PANEL.CamRightLb = Editor.PANEL.Settings:Add( "DTextEntry" )
    Editor.PANEL.CamRightLb:SetPos( 110 , offset )
    Editor.PANEL.CamRightLb:SetValue(GetConVar( RTP_VAR_CAMERA_RIGHT ):GetInt())
    Editor.PANEL.CamRightLb:SetSize( 40, 20 )
    Editor.PANEL.CamRightLb:SetNumeric( true )
    Editor.PANEL.CamRightLb:SetUpdateOnType( true )
    Editor.PANEL.CamRightLb.OnTextChanged  = function()

        Editor.PANEL.CamRight_PRF:SetValue( Editor.PANEL.CamRightLb:GetValue() )
        Editor.PANEL.CamRight_PRF.OnValueChanged()

    end

    Editor.PANEL.CamRight_PRF = Editor.PANEL.Settings:Add( "DNumberScratch" )
    Editor.PANEL.CamRight_PRF:SetPos( 155, offset + 2 )
    Editor.PANEL.CamRight_PRF:SetValue( GetConVar( RTP_VAR_CAMERA_RIGHT ):GetInt() )
    Editor.PANEL.CamRight_PRF:SetMin( min )
    Editor.PANEL.CamRight_PRF:SetMax( max )
    Editor.PANEL.CamRight_PRF:SetDecimals( 0 )
    Editor.PANEL.CamRight_PRF.OnValueChanged  = function()

        Editor.PANEL.CamRightLb:SetValue( Editor.PANEL.CamRight_PRF:GetTextValue() )
        RunConsoleCommand( RTP_VAR_CAMERA_RIGHT ,Editor.PANEL.CamRight_PRF:GetTextValue() )

    end

end

local function DrawFovSettings( min, max, offset )

    Editor.PANEL.CamFovTxt = Editor.PANEL.Settings:Add( "DLabel" )
    Editor.PANEL.CamFovTxt:SetPos( 10, offset + 5 )
    Editor.PANEL.CamFovTxt:SetText( "Camera FOV: " )
    Editor.PANEL.CamFovTxt:SizeToContents()

    Editor.PANEL.CamFovLb = Editor.PANEL.Settings:Add( "DTextEntry" )
    Editor.PANEL.CamFovLb:SetPos( 110 , offset )
    Editor.PANEL.CamFovLb:SetValue(GetConVar( RTP_VAR_CAMERA_FOV ):GetInt())
    Editor.PANEL.CamFovLb:SetSize( 40, 20 )
    Editor.PANEL.CamFovLb:SetNumeric( true )
    Editor.PANEL.CamFovLb:SetUpdateOnType( true )
    Editor.PANEL.CamFovLb.OnTextChanged  = function()

        Editor.PANEL.CamFov_PRF:SetValue( Editor.PANEL.CamFovLb:GetValue() )
        Editor.PANEL.CamFov_PRF.OnValueChanged()

    end

    Editor.PANEL.CamFov_PRF = Editor.PANEL.Settings:Add( "DNumberScratch" )
    Editor.PANEL.CamFov_PRF:SetPos( 155, offset + 2 )
    Editor.PANEL.CamFov_PRF:SetValue( GetConVar( RTP_VAR_CAMERA_FOV ):GetInt() )
    Editor.PANEL.CamFov_PRF:SetMin( min )
    Editor.PANEL.CamFov_PRF:SetMax( max )
    Editor.PANEL.CamFov_PRF:SetDecimals( 0 )
    Editor.PANEL.CamFov_PRF.OnValueChanged  = function()

        Editor.PANEL.CamFovLb:SetValue( Editor.PANEL.CamFov_PRF:GetTextValue() )
        RunConsoleCommand( RTP_VAR_CAMERA_FOV ,Editor.PANEL.CamFov_PRF:GetTextValue() )

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

        RunConsoleCommand( RTP_VAR_MOD_ENABLED , RTP_DEFAULT_MOD_ENABLED )

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
    icon = "icon16/arrow_rotate_clockwise.png",
    width = PANEL_WIDTH,
    height = PANEL_HEIGHT,
    onewindow = true,
    init = function( icon, window )
        DrawEditor( window )
    end
} )