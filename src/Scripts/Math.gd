extends Node

var linearA: float
var linearB: float

func ScalePoint(point: Vector3, scale: Vector3) -> Vector3:
	return Vector3(point.x * scale.x, point.y * scale.y, point.z * scale.z)
	
func ScalePointBack(point: Vector3, scale: Vector3) -> Vector3:
	return Vector3(point.x / scale.x, point.y / scale.y, point.z / scale.z)

func ScaleFloat(value: float, scaleFactor:float) -> float:
	return value * scaleFactor

func Y(x):
	return (linearA * x + linearB)
