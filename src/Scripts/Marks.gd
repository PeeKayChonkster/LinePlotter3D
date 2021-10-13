extends Node

onready var markLines = $MarkLines


func RenderMarking(markNumber, markSpacing, markLength, scale: Vector3):
	DeleteMarking()
	var width = 3.0
	for i in range(-markNumber, markNumber):
		### X-axis
		var distance = Math.ScaleFloat(i * markSpacing, scale.x)
		var point1 = Vector3(distance, 0.0, markLength / 2.0)
		var point2 = Vector3(distance, 0.0, -markLength / 2.0)
		markLines.RegisterMark(point1, point2, Color.red, width)
		### Y-axis
		distance = Math.ScaleFloat(i * markSpacing, scale.y)
		point1 = Vector3(markLength / 2.0, distance, 0.0)
		point2 = Vector3(-markLength / 2.0, distance, 0.0)
		markLines.RegisterMark(point1, point2, Color.blue, width)
		### Z-axis
		distance = Math.ScaleFloat(i * markSpacing, scale.z)
		point1 = Vector3(markLength / 2.0, 0.0, distance)
		point2 = Vector3(-markLength / 2.0, 0.0, distance)
		markLines.RegisterMark(point1, point2, Color.green, width)

func DeleteMarking():
	markLines.DeleteMarks()
