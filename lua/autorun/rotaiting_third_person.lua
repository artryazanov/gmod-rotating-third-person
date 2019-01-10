if CLIENT then

	include( "includes/rotating_third_person_config.lua" )
	include( "includes/rotating_third_person_editor.lua" )

	local cameraOrigin
	local cameraAngles
	local cameraFOV
	local playerAngles
	local isRightMouseWasPressed = false

	local function isPlayerMoves()

		local ply = LocalPlayer()
		local isMoves = ply:KeyDown( IN_FORWARD ) or ply:KeyDown( IN_BACK ) or ply:KeyDown( IN_MOVERIGHT ) or ply:KeyDown( IN_MOVELEFT )
		return isMoves

	end

	local function calcDeltaYawByX( x )

		local xDirection
		if x < 0 then
			xDirection = 1
		else
			xDirection = -1
		end

		local deltaYaw = 0
		if x ~= 0 then
			deltaYaw = xDirection * ( math.abs( x ) / ScrW() * cameraFOV )
		end

		return deltaYaw

	end

	local function calcDeltaPitchByY( y )

		local yDirection
		if y < 0 then
			yDirection = -1
		else
			yDirection = 1
		end

		local deltaPitch = 0
		if y ~= 0 then
			deltaPitch = yDirection * ( math.abs( y ) / ScrH() * cameraFOV )
		end


		return deltaPitch

	end

	local function UpdateCameraAngles( x, y )

		cameraAngles.yaw = cameraAngles.yaw + calcDeltaYawByX( x )
		cameraAngles.pitch = cameraAngles.pitch + calcDeltaPitchByY( y )
		cameraAngles.pitch = math.min(cameraAngles.pitch, 89)
		cameraAngles.pitch = math.max(cameraAngles.pitch, -89)

	end

	local function Xor( a, b )

		if ( a or b ) and ( not a or not b ) then
			return true
		else
			return false
		end

	end

	local function UpdatePlayerAngles( x )

		local ply = LocalPlayer()

		if isPlayerMoves() then
			playerAngles.yaw = playerAngles.yaw + calcDeltaYawByX( x )
		end

		if input.IsMouseDown( MOUSE_RIGHT ) then

			playerAngles = Angle( cameraAngles )
			isRightMouseWasPressed = true

		elseif isRightMouseWasPressed
				or ( Xor( ply:KeyDown( IN_FORWARD ), ply:KeyDownLast( IN_FORWARD ) ) )
				or ( Xor( ply:KeyDown( IN_BACK ), ply:KeyDownLast( IN_BACK ) ) )
				or ( Xor( ply:KeyDown( IN_MOVERIGHT ), ply:KeyDownLast( IN_MOVERIGHT ) ) )
				or ( Xor( ply:KeyDown( IN_MOVELEFT ), ply:KeyDownLast( IN_MOVELEFT ) ) )
		then

			isRightMouseWasPressed = false

			if ply:KeyDown( IN_FORWARD ) then

				playerAngles = cameraAngles:Forward():Angle()
				if ply:KeyDown( IN_MOVERIGHT ) then
					playerAngles.yaw = playerAngles.yaw - 45
				elseif ply:KeyDown( IN_MOVELEFT ) then
					playerAngles.yaw = playerAngles.yaw + 45
				end

			elseif ply:KeyDown( IN_BACK ) then

				playerAngles = ( cameraAngles:Forward() * -1 ):Angle()
				if ply:KeyDown( IN_MOVERIGHT ) then
					playerAngles.yaw = playerAngles.yaw + 45
				elseif ply:KeyDown( IN_MOVELEFT ) then
					playerAngles.yaw = playerAngles.yaw - 45
				end

			elseif ply:KeyDown( IN_MOVERIGHT ) then
				playerAngles = cameraAngles:Right():Angle()
			elseif ply:KeyDown( IN_MOVELEFT ) then
				playerAngles = ( cameraAngles:Right() * -1 ):Angle()
			end

		end

	end

	local function UpdatePlayerMove( cmd )

		if not input.IsMouseDown( MOUSE_RIGHT ) and isPlayerMoves() then

			cmd:SetForwardMove( 1000 )
			cmd:SetSideMove( 0 )

		end

	end

	local function RotatePlayer( cmd, ang )

		local rotationSpeed = GetConVar( RTP_VAR_PLAYER_ROTATION_SPEED ):GetInt()
		ang.yaw = math.ApproachAngle(ang.yaw, playerAngles.yaw, rotationSpeed)
		ang.pitch = math.ApproachAngle(ang.pitch, playerAngles.pitch, rotationSpeed)
		ang.row = math.ApproachAngle(ang.row, playerAngles.row, rotationSpeed)

		cmd:SetViewAngles( ang )

	end

	local function UpdateCameraOrigin( ply, origin )

		local cameraForward = GetConVar( RTP_VAR_CAMERA_FORWARD ):GetInt()
		local cameraRight = GetConVar( RTP_VAR_CAMERA_RIGHT ):GetInt()

		cameraUp = GetConVar( RTP_VAR_CAMERA_UP ):GetInt()
		if (ply:Crouching()) then
			cameraUp = cameraUp + 20
		end

		local traceData = {}
		traceData.start = origin
		traceData.endpos = traceData.start + cameraAngles:Forward() * -cameraForward
		traceData.endpos = traceData.endpos + cameraAngles:Right() * cameraRight
		traceData.endpos = traceData.endpos + cameraAngles:Up() * cameraUp
		traceData.filter = ply

		local trace = util.TraceLine( traceData )
		cameraOrigin = trace.HitPos
		if trace.Fraction < 1.0 then
			cameraOrigin = cameraOrigin + trace.HitNormal * 5
		end

	end

	local function UpdateCameraFOV()

		local plyFOV = GetConVar( RTP_VAR_CAMERA_FOV ):GetInt()
		if input.IsMouseDown( MOUSE_RIGHT ) then
			plyFOV = plyFOV - 5
		end

		changeSpeed = GetConVar( RTP_VAR_CAMERA_FOV_CHANGE_SPEED ):GetInt()
		if cameraFOV > plyFOV then
			cameraFOV = cameraFOV - changeSpeed
		elseif cameraFOV < plyFOV then
			cameraFOV = cameraFOV + changeSpeed
		end

	end

	local function InitParameters( origin, angles, fov )

		if cameraOrigin == nil then
			cameraOrigin = Vector( origin )
		end

		if cameraAngles == nil then
			cameraAngles = Angle( angles )
		end

		if cameraFOV == nil then
			cameraFOV = fov
		end

		if playerAngles == nil then
			playerAngles = Angle( angles )
		end

	end

	local function IsAddonEnabled()

		local inVehicle = false
		local ply = LocalPlayer()
		if IsValid( ply ) then
			inVehicle = ply:InVehicle()
		end

		return not inVehicle and GetConVar( RTP_VAR_ADDON_ENABLED ):GetBool()

	end

	local function DrawCustomCrossHair()

		local ply = LocalPlayer()

		local traceData = {}
		traceData.start = ply:GetShootPos()
		traceData.endpos = traceData.start + ply:GetAimVector() * 9000
		traceData.filter = ply

		local trace = util.TraceLine( traceData )
		local pos = trace.HitPos:ToScreen()

		surface.SetDrawColor(255, 230, 0, 240)

		surface.DrawLine(pos.x - 5, pos.y, pos.x - 8, pos.y)
		surface.DrawLine(pos.x + 5, pos.y, pos.x + 8, pos.y)

		surface.DrawLine(pos.x, pos.y - 5, pos.x, pos.y - 8)
		surface.DrawLine(pos.x, pos.y + 5, pos.x, pos.y + 8)

	end

	hook.Add( "ShouldDrawLocalPlayer", "RotatingThirdPerson.ShouldDrawLocalPlayer", function( ply )

		if ( IsAddonEnabled() ) then
			return true
		end

	end )

	hook.Add( "HUDShouldDraw", "RotatingThirdPerson.HUDShouldDraw", function( name )

		if ( IsAddonEnabled() ) then

			if name == "CHudCrosshair" then
				return false
			end

		end

	end )

	hook.Add( "HUDPaint", "RotatingThirdPerson.HUDPaint", function()

		if ( IsAddonEnabled() ) then
			DrawCustomCrossHair()
		end

	end )

	hook.Add( "InputMouseApply", "RotatingThirdPerson.InputMouseApply", function( cmd, x, y, ang )

		if ( IsAddonEnabled() ) then

			UpdateCameraAngles( x, y )
			UpdatePlayerAngles( x )

			RotatePlayer( cmd, ang )
			UpdatePlayerMove( cmd )

			return true

		end

	end )

	hook.Add( "CalcView", "RotatingThirdPerson.CalcView", function( ply, origin, angles, fov )

		if ( IsAddonEnabled() ) then

			InitParameters( origin, angles, fov )
			if IsValid( ply ) then

				UpdateCameraOrigin( ply, origin )
				UpdateCameraFOV()

			end

			return {
				origin = cameraOrigin,
				angles = cameraAngles,
				fov = cameraFOV
			}

		end

	end )

end