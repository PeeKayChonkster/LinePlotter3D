extends Panel

class Line:
	var Start
	var End
	
	func _init(st, en):
		self.Start = st
		self.End = en

onready var Cam = get_viewport().get_camera()
var Lines = []
var color: Color setget OnColorChanged
var width: float setget OnWidthChanged
var pointsTexture = ImageTexture.new()
var pointsImage = Image.new()


func _process(delta):
	if !Lines.empty():
		Draw()


func Draw():
		pointsImage.create(1, Lines.size(), false, 15)
		var viewportSize = get_viewport_rect().size
		
		for i in range(0, Lines.size()):
			var ScreenPointStart = Cam.unproject_position(Lines[i].Start)
			var ScreenPointEnd = Cam.unproject_position(Lines[i].End)

			if(Cam.is_position_behind(Lines[i].Start) ||
				Cam.is_position_behind(Lines[i].End)):
				continue
			
			pointsImage.lock()
			pointsImage.set_pixel(0, i, Color(ScreenPointStart.x / viewportSize.x, 1.0 - ScreenPointStart.y / viewportSize.y, 
				ScreenPointEnd.x / viewportSize.x, 1.0 - ScreenPointEnd.y / viewportSize.y))
			pointsImage.unlock()
			
		var pixSize = 1.0 / float(viewportSize.x)
		pointsTexture.create_from_image(pointsImage, 0)
		material.set_shader_param("points", pointsTexture)
		material.set_shader_param("pixelSize", pixSize)


func RegisterLine(Start, End):
	Lines.append(Line.new(Start, End))

func RegisterLines(points):
	var i = 0
	for point in points:
		if(i + 1 == len(points)): return
		RegisterLine(points[i], points[i + 1])
		i += 1

func DeleteLines():
	Lines.clear()

func OnColorChanged(value):
	color = value;
	material.set_shader_param("lineColor", color)

func OnWidthChanged(value):
	width = width
	material.set_shader_param("lineWidth", width)
