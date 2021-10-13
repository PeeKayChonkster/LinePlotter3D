extends Node2D

class Line:
	var Start
	var End
	var LineColor
	
	func _init(st, en, col):
		self.Start = st
		self.End = en
		self.LineColor = col

var Lines = []
var Points = []
var Marks = []
var antiAliasing = false
var multithreading = false
var lineWidth = 3.0
var lineColor = Color.yellow
var marksWidth = 5.0
onready var Cam = get_viewport().get_camera()

func _ready():
	multithreading =  OS.can_use_threads()

func _process(_delta):
		update() #Calls _draw

func _draw():
	var thread
	if multithreading:
		thread = Thread.new()
		thread.start(self, "DrawMarks")
	else:
		var JustForThreadingToWorkParameter
		DrawMarks(JustForThreadingToWorkParameter)
	DrawLines()
	if multithreading:
		thread.wait_to_finish()

func RegisterMark(Start, End, LineColor, width):
	Marks.append(Line.new(Start, End, LineColor))
	marksWidth = width

func DrawMarks(JustForThreadingToWorkParameter):
	for i in range(len(Marks)):
		var ScreenPointStart = Cam.unproject_position(Marks[i].Start)
		var ScreenPointEnd = Cam.unproject_position(Marks[i].End)
		#Dont draw line if either start or end is considered behind the camera
		#this causes the line to not be drawn sometimes but avoids a bug where the
		#line is drawn incorrectly
		if(Cam.is_position_behind(Marks[i].Start) ||
			Cam.is_position_behind(Marks[i].End)):
			continue
		draw_line(ScreenPointStart, ScreenPointEnd, Marks[i].LineColor, marksWidth)

func RegisterLine(Start, End, LineColor):
	Lines.append(Line.new(Start, End, LineColor))

func RegisterLines(points, color, width):
	var i = 0
	lineWidth = width
	lineColor = color
	for point in points:
		Points.append(point)

func DrawLines():
	var arrayOfPoints1 = PoolVector2Array()
	var arrayOfPoints2 = PoolVector2Array()
	var arrayOfPoints3 = PoolVector2Array()
	var array
	for i in range(len(Points)):
		var screenPoint = Cam.unproject_position(Points[i])
	
		if(Cam.is_position_behind(Points[i])):
			continue
		
		if(i < 8000):
			arrayOfPoints1.append(screenPoint)
		elif(i >= 8000 && i < 16000):
			arrayOfPoints2.append(screenPoint)
		else:
			arrayOfPoints3.append(screenPoint)
	if len(arrayOfPoints1) > 2:
		draw_polyline(arrayOfPoints1, lineColor, lineWidth, antiAliasing)
	if len(arrayOfPoints2) > 2:
		draw_polyline(arrayOfPoints2, lineColor, lineWidth, antiAliasing)
	if len(arrayOfPoints3) > 2:
		draw_polyline(arrayOfPoints3, lineColor, lineWidth, antiAliasing)

func DeleteLines():
	Lines.clear()
	Points.clear()

func DeleteMarks():
	Marks.clear()

func DrawRay(Start, Ray, LineColor, width):
	Lines.append(Line.new(Start, Start + Ray, LineColor))

func DrawCube(Center, HalfExtents, LineColor, width):
	#Start at the 'top left'
	var LinePointStart = Center
	LinePointStart.x -= HalfExtents
	LinePointStart.y += HalfExtents
	LinePointStart.z -= HalfExtents
	
	#Draw top square
	var LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents * 2.0)
	RegisterLine(LinePointStart, LinePointEnd, LineColor);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(HalfExtents * 2.0, 0, 0)
	RegisterLine(LinePointStart, LinePointEnd, LineColor);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, -HalfExtents * 2.0)
	RegisterLine(LinePointStart, LinePointEnd, LineColor);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(-HalfExtents * 2.0, 0, 0)
	RegisterLine(LinePointStart, LinePointEnd, LineColor);
	
	#Draw bottom square
	LinePointStart = LinePointEnd + Vector3(0, -HalfExtents * 2.0, 0)
	LinePointEnd = LinePointStart + Vector3(0, 0, HalfExtents * 2.0)
	RegisterLine(LinePointStart, LinePointEnd, LineColor);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(HalfExtents * 2.0, 0, 0)
	RegisterLine(LinePointStart, LinePointEnd, LineColor);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(0, 0, -HalfExtents * 2.0)
	RegisterLine(LinePointStart, LinePointEnd, LineColor);
	LinePointStart = LinePointEnd
	LinePointEnd = LinePointStart + Vector3(-HalfExtents * 2.0, 0, 0)
	RegisterLine(LinePointStart, LinePointEnd, LineColor);
	
	#Draw vertical lines
	LinePointStart = LinePointEnd
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, width)
	LinePointStart += Vector3(0, 0, HalfExtents * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, width)
	LinePointStart += Vector3(HalfExtents * 2.0, 0, 0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, width)
	LinePointStart += Vector3(0, 0, -HalfExtents * 2.0)
	DrawRay(LinePointStart, Vector3(0, HalfExtents * 2.0, 0), LineColor, width)


func _on_AntiAliasingButton_toggled(button_pressed):
	antiAliasing = !antiAliasing
