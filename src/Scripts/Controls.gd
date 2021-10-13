extends Node

onready var world = get_node("/root/World")
onready var camera = get_node("/root/World/Camera")
onready var UI = get_node("/root/World/UI")

export var mouseSpeed = 0.005
export var dragSpeed = 0.008
export var scrollSensitivity = 1.0

func _input(event):
	if(UI.inEditMode): return
	if event is InputEventMouseMotion:
		var mouseOffset = event.relative
		var resolutionCompensatorX = OS.get_window_size().x / 1920.0
		var resolutionCompensatorY = OS.get_window_size().y / 1080.0
		if Input.is_action_pressed("mouse_left"):
			Parameters.IncrementTime(0.001 * mouseOffset.x *resolutionCompensatorX, true)
			world.MovePoint()
		if Input.is_action_pressed("mouse_right"):
			var cameraMode = camera.GetMode()
			if(cameraMode >= 4):
				if(camera.following):
					camera.transform.origin += camera.transform.basis.x  * (-mouseOffset.x) * mouseSpeed * resolutionCompensatorX * 5.0
					camera.transform.origin += camera.transform.basis.y  * mouseOffset.y * mouseSpeed * resolutionCompensatorY * 5.0
				else:
					camera.transform.basis = camera.transform.basis.rotated(Vector3.UP, -mouseOffset.x * mouseSpeed * resolutionCompensatorX)
					camera.transform.basis = camera.transform.basis.rotated(camera.transform.basis.x.normalized(), -mouseOffset.y * mouseSpeed * resolutionCompensatorY)
			else:
				match cameraMode:
					1:
						camera.transform.origin += Vector3.RIGHT * -mouseOffset.x * dragSpeed
						camera.transform.origin += Vector3.FORWARD * mouseOffset.y * dragSpeed
					2:
						camera.transform.origin += Vector3.FORWARD * -mouseOffset.x * dragSpeed
						camera.transform.origin += Vector3.UP * mouseOffset.y * dragSpeed
					3:
						camera.transform.origin += Vector3.RIGHT * -mouseOffset.x * dragSpeed
						camera.transform.origin += Vector3.UP * mouseOffset.y * dragSpeed
	if event is InputEventMouseButton and (event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN):
		if(event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN):
			camera.Zoom(event)
	if event is InputEvent:
		if event.is_action_pressed("1"): camera.ChangeView(1)
		if event.is_action_pressed("2"): camera.ChangeView(2)
		if event.is_action_pressed("3"): camera.ChangeView(3)
		if event.is_action_pressed("4"): camera.ChangeView(4)
		if event.is_action_pressed("5"): camera.ChangeView(5)
		if event.is_action_pressed("shift"):
			camera.speed *= 2.0
			scrollSensitivity *= 2.0
			dragSpeed *= 2.0
		if event.is_action_released("shift"):
			camera.speed /= 2.0
			scrollSensitivity /= 2.0
			dragSpeed /= 2.0
		if event.is_action_pressed("space"):
			world.TogglePause()
		if event.is_action_pressed("r"):
			world.OnResetButtonPress()
		if event.is_action_pressed("reset_camera"):
			camera.ResetCamera()
		if event.is_action_pressed("focus_camera"):
			camera.FocusCamera()
		
	if event is InputEventKey:
		if event.scancode == KEY_PRINT:
			TakeScreenShot()


func TakeScreenShot():
	pass
#	var image
#	if !OS.window_borderless:
#		Screen.Fullscreen()
#		yield(get_tree(), "idle_frame")
#		yield(get_tree(), "idle_frame")
#		image = get_viewport().get_texture().get_data()
#		Screen.Fullscreen()
#	else:
#		image = get_viewport().get_texture().get_data()
#	image.flip_y()
#	var time = OS.get_datetime()
#	var path = OS.get_executable_path().get_base_dir() + "/Screenshots"
#	var dir = Directory.new()
#	if !dir.dir_exists(path):
#		var error = dir.make_dir(path)
#		if error != OK: 
#			print("Cannot create directory: \"" + dir.get_current_dir() + "\"")
#			return
#	dir.change_dir(path)
#	image.save_png(
#		dir.get_current_dir() + "/" +  str(time["day"]) + "_" + str(time["month"]) + "_" + str(time["year"])
#	 + "__" + str(time["hour"]) + "-" + str(time["minute"]) + "-" + str(time["second"]) + ".png")
