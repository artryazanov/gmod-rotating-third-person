if CLIENT then

	local cameraOrigin
	local cameraAngles
	local cameraFOV
	local playerAngles

	local VAR_CAMERA_FORWARD = "rotating_third_person_camera_forward"
	local VAR_CAMERA_RIGHT = "rotating_third_person_camera_right"
	local VAR_CAMERA_UP = "rotating_third_person_camera_up"
	local VAR_CAMERA_FOV_CHANGE_SPEED = "rotating_third_person_camera_fov_change_speed"
	local VAR_CAMERA_CROUCHING_UP = "rotating_third_person_camera_crouching_up"
	local VAR_PLAYER_ROTATION_SPEED = "rotating_third_person_player_rotation_speed"

	CreateClientConVar( VAR_CAMERA_FORWARD, "50", false, false )
	CreateClientConVar( VAR_CAMERA_RIGHT, "20", false, false )
	CreateClientConVar( VAR_CAMERA_UP, "-10", false, false )
	CreateClientConVar( VAR_CAMERA_FOV_CHANGE_SPEED, "1", false, false )
	CreateClientConVar( VAR_CAMERA_CROUCHING_UP, "14", false, false )
	CreateClientConVar( VAR_PLAYER_ROTATION_SPEED, "3", false, false )

	hook.Add( "ShouldDrawLocalPlayer", "RotatingThirdPerson.ShouldDrawLocalPlayer", function( ply )

		return true

	end )

	hook.Add( "HUDShouldDraw", "RotatingThirdPerson.HUDShouldDraw", function( name )

		if name == "CHudCrosshair" then
			return false
		end

	end )

	hook.Add( "HUDPaint", "RotatingThirdPerson.HUDPaint", function()

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

	end )

	local function UpdateCameraAngles( x, y )

		local xDirection
		if x < 0 then
			xDirection = 1
		else
			xDirection = -1
		end

		if x ~= 0 then
			cameraAngles.yaw = cameraAngles.yaw + xDirection * ( math.abs( x ) / ScrW() * cameraFOV )
		end

		local yDirection
		if y < 0 then
			yDirection = -1
		else
			yDirection = 1
		end

		if y ~= 0 then

			cameraAngles.pitch = cameraAngles.pitch + yDirection * ( math.abs( y ) / ScrH() * cameraFOV )
			cameraAngles.pitch = math.min(cameraAngles.pitch, 90)
			cameraAngles.pitch = math.max(cameraAngles.pitch, -90)

		end

	end

	local function Xor( a, b )

		if ( a or b ) and ( not a or not b ) then
			return true
		else
			return false
		end

	end

	local function UpdatePlayerAngles()

		local ply = LocalPlayer()

		if input.IsMouseDown( MOUSE_RIGHT ) then
			playerAngles = Angle( cameraAngles )
		elseif ( Xor( ply:KeyDown( IN_FORWARD ), ply:KeyDownLast( IN_FORWARD ) ) )
				or ( Xor( ply:KeyDown( IN_BACK ), ply:KeyDownLast( IN_BACK ) ) )
				or ( Xor( ply:KeyDown( IN_MOVERIGHT ), ply:KeyDownLast( IN_MOVERIGHT ) ) )
				or ( Xor( ply:KeyDown( IN_MOVELEFT ), ply:KeyDownLast( IN_MOVELEFT ) ) )
		then

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

		local ply = LocalPlayer()

		if ply:KeyDown( IN_FORWARD ) or ply:KeyDown( IN_BACK ) or ply:KeyDown( IN_MOVERIGHT ) or ply:KeyDown( IN_MOVELEFT ) then

			cmd:SetForwardMove( 1000 )
			cmd:SetSideMove( 0 )

		end

	end

	local function RotatePlayer( cmd, ang )

		local rotationSpeed = GetConVar( VAR_PLAYER_ROTATION_SPEED ):GetInt()
		ang.yaw = math.ApproachAngle(ang.yaw, playerAngles.yaw, rotationSpeed)
		ang.pitch = math.ApproachAngle(ang.pitch, playerAngles.pitch, rotationSpeed)
		ang.row = math.ApproachAngle(ang.row, playerAngles.row, rotationSpeed)

		cmd:SetViewAngles( ang )

	end

	hook.Add( "InputMouseApply", "RotatingThirdPerson.InputMouseApply", function( cmd, x, y, ang )

		UpdateCameraAngles( x, y )
		UpdatePlayerAngles()

		RotatePlayer( cmd, ang )
		UpdatePlayerMove( cmd )

		return true

	end )

	local function UpdateCameraOrigin( ply, origin )

		local cameraForward = GetConVar( VAR_CAMERA_FORWARD ):GetInt()
		local cameraRight = GetConVar( VAR_CAMERA_RIGHT ):GetInt()

		local cameraUp
		if (ply:Crouching()) then
			cameraUp = GetConVar( VAR_CAMERA_CROUCHING_UP ):GetInt()
		else
			cameraUp = GetConVar( VAR_CAMERA_UP ):GetInt()
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

	local function UpdateCameraFOV( ply )

		local plyFOV = ply:GetFOV()
		if input.IsMouseDown( MOUSE_RIGHT ) then
			plyFOV = plyFOV - 5
		end

		changeSpeed = GetConVar( VAR_CAMERA_FOV_CHANGE_SPEED ):GetInt()
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

	hook.Add( "CalcView", "RotatingThirdPerson.CalcView", function( ply, origin, angles, fov )

		InitParameters( origin, angles, fov )
		if IsValid( ply ) then

			UpdateCameraOrigin( ply, origin )
			UpdateCameraFOV( ply )

		end

		return {
			origin = cameraOrigin,
			angles = cameraAngles,
			fov = cameraFOV
		}

	end )

end