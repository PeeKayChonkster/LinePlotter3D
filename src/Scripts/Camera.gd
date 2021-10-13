extends Camera


export var speed = 20.0


onready var cameraModeLabel = get_node("/root/World/UI/UIPanel/CameraMode")
onready var positionXY = get_node("/root/World/Positions/PositionXY")
onready var positionYZ = get_node("/root/World/Positions/PositionYZ")
onready var positionXZ = get_node("/root/World/Positions/PositionXZ")
onready var UI = get_node("/root/World/UI")
onready var plotPoint = get_node("/root/World/Point")
onready var world = get_node("/root/World")
onready var cameraMode = 4
onready var cameraDefaultPosition = global_transform

var following = false

func _ready():
	cameraModeLabel.text = "Free camera"

func _physics_process(delta):
	if following:
		Follow()
	if !UI.inEditMode and Input.is_action_just_pressed("mouse_right"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if Input.is_action_pressed("mouse_right"):
		Move(delta)
	if Input.is_action_just_released("mouse_right"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func Move(delta):
	if(UI.inEditMode): return
	if(Input.is_action_pressed("move_down")): 
		transform.origin += transform.basis.z * speed * delta
		if(cameraMode != 4):
			SetFreeMode()
	if(Input.is_action_pressed("move_up")):
		transform.origin += -transform.basis.z * speed * delta
		if(cameraMode != 4):
			SetFreeMode()
	if(Input.is_action_pressed("move_left")):
		transform.origin += -transform.basis.x * speed * delta
		if(cameraMode != 4):
			SetFreeMode()
	if(Input.is_action_pressed("move_right")): 
		transform.origin += transform.basis.x * speed * delta
		if(cameraMode != 4):
			SetFreeMode()
		

func Follow():
	if(world.animate):
		var position = plotPoint.velocity
		transform.origin += position
	look_at(plotPoint.transform.origin, Vector3.UP)


func Zoom(event):
	var multiplier = -1.0 if event.button_index == BUTTON_WHEEL_UP else 1.0
	if(cameraMode >= 4):
		transform.origin = transform.origin + transform.basis.z * multiplier * Controls.scrollSensitivity
		transform = transform.orthonormalized()
	else:
		# Check if size <= 0
		size += multiplier * Controls.scrollSensitivity

func ChangeView(key):
	match key:
		1:
			var tempPos = positionXY.transform
			if(abs(global_transform.origin.y) > 0.3):
				tempPos.origin.y = abs(global_transform.origin.y)
			global_transform = tempPos
			projection = Camera.PROJECTION_ORTHOGONAL
			size = global_transform.origin.y
			cameraMode = 1
			cameraModeLabel.text = "XY plane"
			world.ToggleIndices(false)
			SetFollow(false)
		2:
			var tempPos = positionYZ.transform
			if(abs(global_transform.origin.x) > 0.3):
				tempPos.origin.x = abs(global_transform.origin.x)
			global_transform = tempPos
			projection = Camera.PROJECTION_ORTHOGONAL
			size = global_transform.origin.x
			cameraMode = 2
			cameraModeLabel.text = "YZ plane"
			world.ToggleIndices(false)
			SetFollow(false)
		3:
			var tempPos = positionXZ.transform
			if(abs(global_transform.origin.z) > 0.3):
				tempPos.origin.z = abs(global_transform.origin.z)
			global_transform = tempPos
			projection = Camera.PROJECTION_ORTHOGONAL
			size = global_transform.origin.z
			cameraMode = 3
			cameraModeLabel.text = "XZ plane"
			world.ToggleIndices(false)
			SetFollow(false)
		4:
			SetFreeMode()
		5:
			SetFreeMode()
			SetFollow(true)
			cameraModeLabel.text = "Follow"
			cameraMode = 5

func SetFreeMode():
	if(cameraMode != 4):
		match cameraMode:
			1:
				global_transform.origin.y = size
			2:
				global_transform.origin.x = size
			3:
				global_transform.origin.z = size
			_: continue
		projection = Camera.PROJECTION_PERSPECTIVE
		cameraMode = 4
		world.ToggleIndices(true)
		SetFollow(false)
		cameraModeLabel.text = "Free camera"

func SetFollow(value):
	following = value

func ResetCamera():
	global_transform = cameraDefaultPosition
	SetFreeMode()

func FocusCamera():
	var offset = 3.0;
	var point = plotPoint.transform.origin
	transform.origin = transform.origin.move_toward(point, transform.origin.distance_to(point) - offset)
	look_at(point, Vector3.UP)

func GetMode():
	return cameraMode
