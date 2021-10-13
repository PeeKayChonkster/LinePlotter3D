extends Spatial

onready var plotPoint = $Point
onready var lineX  = $UI/UIPanel/XLabel/LineEditX
onready var lineY  = $UI/UIPanel/YLabel/LineEditY
onready var lineZ  = $UI/UIPanel/ZLabel/LineEditZ
onready var scaleLineX = $UI/UIPanel/ScaleXLabel/ScaleEditX
onready var scaleLineY = $UI/UIPanel/ScaleYLabel/ScaleEditY
onready var scaleLineZ = $UI/UIPanel/ScaleZLabel/ScaleEditZ
onready var numberOfSublinesEdit = $UI/UIPanel/NumberOfSubLines/NumberOfSublinesEdit
onready var axisX = $Axes/AxisX
onready var axisY = $Axes/AxisY
onready var axisZ = $Axes/AxisZ
onready var animateButton = $UI/UIPanel/AnimateButton
onready var resetButton = $UI/UIPanel/ResetButton
onready var timeLabel = $UI/UIPanel/TimeLabel
onready var marks = $Marks
onready var UI = $UI
onready var plotLine = $PlotLine
onready var camera = $Camera

export var scaleVec = Vector3(1.0, 1.0, 1.0)
export var markLength = 0.25
export var markSpacing = 0.5
export var markNumber = 40
export var numberOfSubLines = 50
export var leftPlotLimit = 0
export var rightPlotLimit = 20
export var plotLineColor = Color.yellow
export var plotLineWidth = 3.0

var equasionX: String
var equasionY: String
var equasionZ: String
var toolEquasion: String
var expressionX = Expression.new()
var expressionY = Expression.new()
var expressionZ = Expression.new()
var toolExpression = Expression.new()
var parseErrorX = true
var parseErrorY = true
var parseErrorZ = true
var parseErrorTool = true
var timeDelta = 0.01
var leftTimeLimit = 0.0
var rightTimeLimit = 100.0
var animate = false
var isPlotLineOn = false

func _ready():
	randomize()
	Parameters.connect("parametersChanged", self, "OnParametersChanged")
	UpdateLabels()
	RenderMarking()
	get_node("Axes/AxisX").points = [Vector3(-50, 0.0, 0.0), Vector3(50, 0.0, 0.0)]
	get_node("Axes/AxisY").points = [Vector3(0.0, 0.0, -50), Vector3(0.0, 0.0, 50)]
	get_node("Axes/AxisZ").points = [Vector3(0.0, -50, 0.0), Vector3(0.0, 50, 0.0)]

func _process(_delta):
	if(animate):
		Parameters.IncrementTime(timeDelta, true)
		MovePoint()

func MovePoint():
	var point = ExecuteExpressions(0.0)
	UpdateLabels()
	plotPoint.Move(Math.ScalePoint(point, scaleVec))
	ClampCoordinates()

func ParseExpression(exprID: String):
	match exprID:
		"x":
			if(equasionX == ""): equasionX = "0.0"
			var error = expressionX.parse(equasionX, Parameters.parametersNames)
			if(error != OK):
				lineX.ShowWarning()
				print(expressionX.get_error_text())
				parseErrorX = true
			else:
				lineX.HideWarning()
				parseErrorX = false
		"y":
			if(equasionY == ""): equasionY = "0.0"
			var error = expressionY.parse(equasionY, Parameters.parametersNames)
			if(error != OK):
				lineY.ShowWarning()
				print(expressionY.get_error_text())
				parseErrorY = true
			else:
				lineY.HideWarning()
				parseErrorY = false
		"z":
			if(equasionZ == ""): equasionZ = "0.0"
			var error = expressionZ.parse(equasionZ, Parameters.parametersNames)
			if(error != OK):
				lineZ.ShowWarning()
				print(expressionZ.get_error_text())
				parseErrorZ = true
			else:
				lineZ.HideWarning()
				parseErrorZ = false
		"t":
			if(toolEquasion == ""): toolEquasion = "0.0"
			var error = toolExpression.parse(toolEquasion, Parameters.parametersNames)
			if(error != OK):
				print(toolExpression.get_error_text())
				parseErrorTool = true
			else:
				parseErrorTool = false

func ExecuteExpressions(defaultValue: float) ->Vector3:
	var outPoint = Vector3()
	if (parseErrorX):
		lineX.ShowWarning()
		outPoint.x = defaultValue
	else:
		var temp = expressionX.execute(Parameters.parametersValues, null, false)
		if (expressionX.has_execute_failed() || temp == null):
			#print("executeX failed")
			lineX.ShowWarning()
			outPoint.x = defaultValue
		else:
			outPoint.x = temp
	
	if(parseErrorY):
		lineY.ShowWarning()
		outPoint.z = defaultValue
	else:
		var temp = expressionY.execute(Parameters.parametersValues, null, false)
		if (expressionY.has_execute_failed() || temp == null):
			#print("executeY failed")
			lineY.ShowWarning()
			outPoint.z = defaultValue
		else:
			outPoint.z = -temp

	if(parseErrorZ):
		lineZ.ShowWarning()
		outPoint.y = defaultValue
	else:
		var temp = expressionZ.execute(Parameters.parametersValues, null, false)
		if (expressionZ.has_execute_failed() || temp == null):
			#print("executeZ failed")
			lineZ.ShowWarning()
			outPoint.y = defaultValue
		else:
			outPoint.y = temp
		
	return outPoint

func ExecuteToolExpression(variable = 0.0, defaultValue = 0.0) -> float:
	var t = variable
	var outValue
	if(parseErrorTool):
		lineZ.ShowWarning()
		outValue = defaultValue
		return outValue
	var temp = toolExpression.execute([t], null, false)
	if (toolExpression.has_execute_failed() || temp == null):
		#print("toolExecute failed")
		outValue = defaultValue
	else:
		outValue  = temp
	return outValue


func _on_AnimateButton_button_up():
	TogglePause()


func OnResetButtonPress():
	plotPoint.Reset()
	animate = false
	Parameters.SetTime(leftTimeLimit, true)
	CorrectPlotPoint()
	lineX.HideWarning()
	lineY.HideWarning()
	lineZ.HideWarning()
	UpdateLabels()


func _on_LineEditX_text_changed(new_text):
	if(new_text != ""):
		equasionX = new_text
	else:
		equasionX = "0"
	ParseExpression("x")
	CorrectPlotPoint()
	if(isPlotLineOn):
		DrawPlotLine()

func _on_LineEditY_text_changed(new_text):
	if(new_text != ""):
		equasionY = new_text
	else:
		equasionY = "0"
	ParseExpression("y")
	CorrectPlotPoint()
	if(isPlotLineOn):
		DrawPlotLine()

func _on_LineEditZ_text_changed(new_text):
	if(new_text != ""):
		equasionZ = new_text
	else:
		equasionZ = "0"
	ParseExpression("z")
	CorrectPlotPoint()
	if(isPlotLineOn):
		DrawPlotLine()


func _on_ScaleEditX_text_changed(new_text):
	if(new_text != ""):
		toolEquasion = new_text
	else:
		toolEquasion = "1.0"
	ParseExpression("t")
	scaleVec.x = ExecuteToolExpression(0, 1)
	RenderMarking()
	CorrectPlotPoint()
	if(isPlotLineOn):
		DrawPlotLine()


func _on_ScaleEditY_text_changed(new_text):
	if(new_text != ""):
		toolEquasion = new_text
	else:
		toolEquasion = "1.0"
	ParseExpression("t")
	scaleVec.z = ExecuteToolExpression(0, 1)
	RenderMarking()
	CorrectPlotPoint()
	if(isPlotLineOn):
		DrawPlotLine()


func _on_ScaleEditZ_text_changed(new_text):
	if(new_text != ""):
		toolEquasion = new_text
	else:
		toolEquasion = "1.0"
	ParseExpression("t")
	scaleVec.y = ExecuteToolExpression(0, 1)
	RenderMarking()
	CorrectPlotPoint()
	if(isPlotLineOn):
		DrawPlotLine()


func RenderMarking():
	marks.RenderMarking(markNumber, markSpacing, markLength, scaleVec)

func DeleteMarking():
	marks.DeleteMarking()

func UpdateLabels():
	var scaledVec = Math.ScalePointBack(plotPoint.transform.origin, scaleVec)
	timeLabel.text = "time = " + str(Parameters.GetTime())
	UI.xCoordinateLabel.text = "x = " + str(stepify(scaledVec.x, 0.001))
	UI.yCoordinateLabel.text = "y = " + str(-stepify(scaledVec.z, 0.001))
	UI.zCoordinateLabel.text = "z = " + str(stepify(scaledVec.y, 0.001))
	

func ClampCoordinates():
	if(Parameters.GetTime() > rightTimeLimit):
		OnResetButtonPress()
		return
	if(abs(plotPoint.transform.origin.x) >= 50000): 
		OnResetButtonPress()
		return
	if(abs(plotPoint.transform.origin.y) >= 50000): 
		OnResetButtonPress()
		return
	if(abs(plotPoint.transform.origin.z) >= 50000): 
		OnResetButtonPress()
		return
	return

func DrawPlotLine():
	DeletePlotLine()
	var points = []
	if(numberOfSubLines == 0): numberOfSubLines = 50
	var increment = abs(rightPlotLimit - leftPlotLimit) / float(numberOfSubLines)
	var myRange = numberOfSubLines + 1
	ParseExpression("x")
	ParseExpression("y")
	ParseExpression("z")
	var oldTime = Parameters.GetTime()
	for t in range(myRange):
		var point = Vector3()
		# variate patameters too
		Parameters.SetTime(leftPlotLimit + t * increment, true)
		point = ExecuteExpressions(0.0)
		points.append(Math.ScalePoint(point, scaleVec))
	plotLine.RegisterLines(points, plotLineColor, plotLineWidth)
	# set back old parameter's values
	Parameters.SetTime(oldTime, true)
	isPlotLineOn = true

func DeletePlotLine():
	plotLine.DeleteLines()
	isPlotLineOn = false

func ToggleIndices(value):
	$XIndex.visible = value
	$YIndex.visible = value
	$ZIndex.visible = value

func TogglePause():
	animate = !animate

func CorrectPlotPoint():
	plotPoint.Reset(Math.ScalePoint(ExecuteExpressions(0.0), scaleVec))

func _on_DrawPlotLineButton_pressed():
	DrawPlotLine()


func _on_DeletePlotLineButton_pressed():
	DeletePlotLine()


func _on_NumberOfSublinesEdit_text_changed(new_text):
	if(new_text != ""):
		toolEquasion = new_text
		ParseExpression("t")
		numberOfSubLines = clamp(ExecuteToolExpression(0.0, 50), 50, 24000)
		if(isPlotLineOn):
			DrawPlotLine()


func _on_LeftLimitEdit_text_changed(new_text):
	if(new_text != ""):
		toolEquasion = new_text
		ParseExpression("t")
		leftPlotLimit = ExecuteToolExpression(0.0, -10.0)
		if(isPlotLineOn):
			DrawPlotLine()


func _on_RightLimitEdit_text_changed(new_text):
	if(new_text != ""):
		toolEquasion = new_text
		ParseExpression("t")
		rightPlotLimit = ExecuteToolExpression(0.0, 10.0)
		if(isPlotLineOn):
			DrawPlotLine()


func _on_LeftTLimitEdit_text_changed(new_text):
	if(new_text != ""):
		toolEquasion = new_text
		ParseExpression("t")
		leftTimeLimit = ExecuteToolExpression()
		if(!animate): 
			Parameters.SetTime(leftTimeLimit, true)
			CorrectPlotPoint()


func _on_RightTLimitEdit_text_changed(new_text):
	if(new_text != ""):
		toolEquasion = new_text
		ParseExpression("t")
		rightTimeLimit = ExecuteToolExpression(0.0, 100.0)


func _on_tIncrementEdit_text_changed(new_text):
	if(new_text != ""):
		toolEquasion = new_text
		ParseExpression("t")
		timeDelta = ExecuteToolExpression(0.0, 0.1)


func _on_PointRadiusEdit_text_changed(new_text):
	if(new_text != ""):
		toolEquasion = new_text
		ParseExpression("t")
		plotPoint.radius = ExecuteToolExpression(0.0, 0.05)


func _on_LineColorPickerButton_color_changed(color):
	plotLineColor = color
	DrawPlotLine()


func _on_GrayScaleButton_toggled(button_pressed):
	UI.colorFilter.set_process(button_pressed)
	UI.colorFilter.visible = button_pressed



func _on_ResetButton_pressed():
	OnResetButtonPress()



func _on_BackgroungColorPick_color_changed(color):
	camera.environment.background_color = color
	
func OnParametersChanged():
	ParseExpression("x")
	ParseExpression("y")
	ParseExpression("z")
	CorrectPlotPoint()
	if(isPlotLineOn):
		DrawPlotLine()



func _on_LineWidthEdit_text_changed(new_text):
	if(new_text != ""):
		toolEquasion = new_text
		ParseExpression("t")
		plotLineWidth = ExecuteToolExpression(0.0, 3.0)
		DrawPlotLine()

func LoadEquasions(equasions):
	lineX.text = equasions[0]
	lineY.text = equasions[1]
	lineZ.text = equasions[2]
	_on_LineEditX_text_changed(equasions[0])
	_on_LineEditY_text_changed(equasions[1])
	_on_LineEditZ_text_changed(equasions[2])
	

func _enter_tree():
	yield(get_tree().create_timer(1), "timeout")
	SaveController.Load()
func _exit_tree():
	SaveController.Save()



