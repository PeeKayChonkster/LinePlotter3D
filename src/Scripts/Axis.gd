extends Control

export var point1 = Vector3.ZERO
export var point2 = Vector3.ZERO
export var arrowSideLenght = 20
export var arrowNarrownessAngle = 150
export var arrowThickness = 10.0
export var color = Color.yellow
export var width = 0.01

onready var camera = get_viewport().get_camera()

func _ready():
	pass

func _physics_process(delta):
	update()

func _draw():
	var point2D1 = camera.unproject_position(point1)
	var point2D2 = camera.unproject_position(point2)
	
#	var leftSide = (point2D2 - point2D1).rotated(arrowNarrownessAngle * (PI/180)).normalized() * arrowSideLenght
#	var rightSide = (point2D2 - point2D1).rotated(-arrowNarrownessAngle * (PI/180)).normalized() * arrowSideLenght
#	var arrowLeftPoint = point2D2 + leftSide
#	var arrowRightPoint = point2D2 + rightSide
#	var arrowTopPoint = point2D2
#	var arrowBottomPoint = point2D2 - point2D2.normalized() * arrowThickness
#
#	var trianglePoints = PoolVector2Array()
#	trianglePoints.append(arrowLeftPoint)
#	trianglePoints.append(arrowTopPoint)
#	trianglePoints.append(arrowRightPoint)
#	trianglePoints.append(arrowBottomPoint)
#	self.draw_colored_polygon(trianglePoints, color)
	
	self.draw_line(point2D1, point2D2, color, width, false)

