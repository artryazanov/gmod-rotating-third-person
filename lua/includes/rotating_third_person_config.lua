RTP_DEFAULT_ADDON_ENABLED = "1"
RTP_DEFAULT_CAMERA_FORWARD = "50"
RTP_DEFAULT_CAMERA_RIGHT = "20"
RTP_DEFAULT_CAMERA_UP = "-10"
RTP_DEFAULT_CAMERA_FOV = "75"
RTP_DEFAULT_CAMERA_FOV_CHANGE_SPEED = "1"
RTP_DEFAULT_PLAYER_ROTATION_SPEED = "3"

RTP_VAR_ADDON_ENABLED = "rotating_third_person_addon_enabled"
RTP_VAR_CAMERA_FORWARD = "rotating_third_person_camera_forward"
RTP_VAR_CAMERA_RIGHT = "rotating_third_person_camera_right"
RTP_VAR_CAMERA_UP = "rotating_third_person_camera_up"
RTP_VAR_CAMERA_FOV = "rotating_third_person_camera_fov"
RTP_VAR_CAMERA_FOV_CHANGE_SPEED = "rotating_third_person_camera_fov_change_speed"
RTP_VAR_PLAYER_ROTATION_SPEED = "rotating_third_person_player_rotation_speed"

CreateClientConVar( RTP_VAR_ADDON_ENABLED, RTP_DEFAULT_ADDON_ENABLED, true, false )
CreateClientConVar( RTP_VAR_CAMERA_FORWARD, RTP_DEFAULT_CAMERA_FORWARD, true, false )
CreateClientConVar( RTP_VAR_CAMERA_RIGHT, RTP_DEFAULT_CAMERA_RIGHT, true, false )
CreateClientConVar( RTP_VAR_CAMERA_UP, RTP_DEFAULT_CAMERA_UP, true, false )
CreateClientConVar( RTP_VAR_CAMERA_FOV, RTP_DEFAULT_CAMERA_FOV, true, false )
CreateClientConVar( RTP_VAR_CAMERA_FOV_CHANGE_SPEED, RTP_DEFAULT_CAMERA_FOV_CHANGE_SPEED, true, false )
CreateClientConVar( RTP_VAR_PLAYER_ROTATION_SPEED, RTP_DEFAULT_PLAYER_ROTATION_SPEED, true, false )