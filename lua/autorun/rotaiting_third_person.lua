if CLIENT then

	local cameraAngle
	local playerAngle

	local VAR_CAMERA_FORWARD = "rotating_third_person_camera_forward"
	local VAR_CAMERA_RIGHT = "rotating_third_person_camera_right"
	local VAR_CAMERA_UP = "rotating_third_person_camera_up"
	local VAR_CAMERA_CROUCHING_UP = "rotating_third_person_camera_crouching_up"
	local VAR_PLAYER_ROTATION_SPEED = "rotating_third_person_player_rotation_speed"

	CreateClientConVar( VAR_CAMERA_FORWARD, "50", false, false )
	CreateClientConVar( VAR_CAMERA_RIGHT, "20", false, false )
	CreateClientConVar( VAR_CAMERA_UP, "-10", false, false )
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

	local function UpdateCameraAngle( x, y )

		local ply = LocalPlayer()

		local xDirection
		if x < 0 then
			xDirection = 1
		else
			xDirection = -1
		end

		if x ~= 0 then
			cameraAngle.yaw = cameraAngle.yaw + xDirection * ( math.abs( x ) / ScrW() * ply:GetFOV() )
		end

		local yDirection
		if y < 0 then
			yDirection = -1
		else
			yDirection = 1
		end

		if y ~= 0 then
			cameraAngle.pitch = cameraAngle.pitch + yDirection * ( math.abs( y ) / ScrH() * ply:GetFOV() )
			cameraAngle.pitch = math.min(cameraAngle.pitch, 90)
			cameraAngle.pitch = math.max(cameraAngle.pitch, -90)
		end

	end

	local function Xor( a, b )
		if ( a or b ) and ( not a or not b ) then
			return true
		else
			return false
		end
	end

	local function UpdatePlayerAngleAndPlayerWalking( cmd )

		local ply = LocalPlayer()

		if input.IsMouseDown( MOUSE_RIGHT ) then

			playerAngle = cameraAngle

		elseif ( Xor( ply:KeyDown( IN_FORWARD ), ply:KeyDownLast( IN_FORWARD ) ) )
				or ( Xor( ply:KeyDown( IN_BACK ), ply:KeyDownLast( IN_BACK ) ) )
				or ( Xor( ply:KeyDown( IN_MOVERIGHT ), ply:KeyDownLast( IN_MOVERIGHT ) ) )
				or ( Xor( ply:KeyDown( IN_MOVELEFT ), ply:KeyDownLast( IN_MOVELEFT ) ) )
		then

			if ply:KeyDown( IN_FORWARD ) then
				playerAngle = cameraAngle:Forward():Angle()
				if ply:KeyDown( IN_MOVERIGHT ) then
					playerAngle.yaw = playerAngle.yaw - 45
				elseif ply:KeyDown( IN_MOVELEFT ) then
					playerAngle.yaw = playerAngle.yaw + 45
				end
			elseif ply:KeyDown( IN_BACK ) then
				playerAngle = ( cameraAngle:Forward() * -1 ):Angle()
				if ply:KeyDown( IN_MOVERIGHT ) then
					playerAngle.yaw = playerAngle.yaw + 45
				elseif ply:KeyDown( IN_MOVELEFT ) then
					playerAngle.yaw = playerAngle.yaw - 45
				end
			elseif ply:KeyDown( IN_MOVERIGHT ) then
				playerAngle = cameraAngle:Right():Angle()
			elseif ply:KeyDown( IN_MOVELEFT ) then
				playerAngle = ( cameraAngle:Right() * -1 ):Angle()
			end

			cmd:SetForwardMove( 1000 )
			cmd:SetSideMove( 0 )

		elseif ply:KeyDown( IN_FORWARD ) or ply:KeyDown( IN_BACK ) or ply:KeyDown( IN_MOVERIGHT ) or ply:KeyDown( IN_MOVELEFT ) then

			cmd:SetForwardMove( 1000 )
			cmd:SetSideMove( 0 )

		end

	end

	hook.Add( "InputMouseApply", "RotatingThirdPerson.InputMouseApply", function( cmd, x, y, ang )

		UpdateCameraAngle( x, y )
		UpdatePlayerAngleAndPlayerWalking( cmd )

		local rotationSpeed = GetConVar( VAR_PLAYER_ROTATION_SPEED ):GetInt()
		ang.yaw = math.ApproachAngle(ang.yaw, playerAngle.yaw, rotationSpeed)
		ang.pitch = math.ApproachAngle(ang.pitch, playerAngle.pitch, rotationSpeed)
		ang.row = math.ApproachAngle(ang.row, playerAngle.row, rotationSpeed)

		cmd:SetViewAngles( ang )

		return true
	end )

	local function ApplyCollisionToCameraPosition( pos )

		local ply = LocalPlayer()

		local cameraForward = GetConVar( VAR_CAMERA_FORWARD ):GetInt()
		local cameraRight = GetConVar( VAR_CAMERA_RIGHT ):GetInt()

		local cameraUp
		if (ply:Crouching()) then
			cameraUp = GetConVar( VAR_CAMERA_CROUCHING_UP ):GetInt()
		else
			cameraUp = GetConVar( VAR_CAMERA_UP ):GetInt()
		end

		local traceData = {}
		traceData.start = pos
		traceData.endpos = traceData.start + cameraAngle:Forward() * -cameraForward
		traceData.endpos = traceData.endpos + cameraAngle:Right() * cameraRight
		traceData.endpos = traceData.endpos + cameraAngle:Up() * cameraUp
		traceData.filter = ply

		local trace = util.TraceLine( traceData )
		pos = trace.HitPos
		if trace.Fraction < 1.0 then
			pos = pos + trace.HitNormal * 5
		end

		return pos
	end

	hook.Add( "CalcView", "RotatingThirdPerson.CalcView", function( ply, pos, angles, fov )

		if IsValid( ply ) then

			if cameraAngle == nil then
				cameraAngle = angles
			end

			if playerAngle == nil then
				playerAngle = angles
			end

			pos = ApplyCollisionToCameraPosition( pos )

			local view = {
				origin = pos,
				angles = cameraAngle,
				fov = fov
			}

			return view
		end
	end )

end