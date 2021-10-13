extends Spatial

export(float) var radius = 0.5 setget OnChangeRadius

onready var sphereMesh: SphereMesh = $Sphere.mesh
onready var sphere = $Sphere
var color: Color setget OnChangeColor
var velocity = Vector3.ZERO

func _ready():
	sphereMesh.radius = radius / 2.0
	sphereMesh.height = radius

func Move(point: Vector3) -> Vector3:
	velocity = point - transform.origin
	global_transform.origin.x = point.x
	global_transform.origin.y = point.y
	global_transform.origin.z = point.z
	return global_transform.origin

func Reset(startPoint = Vector3.ZERO):
	global_transform.origin = startPoint
	velocity = Vector3.ZERO

func OnChangeColor(value):
	color = value
	var newMaterial = sphere.get_surface_material(0)
	newMaterial.albedo_color = color

func OnChangeRadius(value):
	if is_inside_tree():
		sphereMesh.radius = value / 2.0
		sphereMesh.height = value


func _on_PointColorPickerButton_color_changed(color):
	self.color = color
