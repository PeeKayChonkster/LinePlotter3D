extends Control

onready var createButton = $CreateButton
onready var deleteButton = $DeleteButton
onready var popup = $Popup
onready var parameterLabel = $ParameterLabel
onready var parameterValueLineEdit = $ParameterValueLineEdit

var parameterName = "" setget OnParameterNameChanged
var parameterValue = 0.0
var expression = Expression.new()
var parseError = false
var active = false
signal onCreation
signal onRemoval

func _ready():
	connect("onCreation", get_node("/root/World/UI"), "OnParameterCreation")
	connect("onRemoval", get_node("/root/World/UI"), "OnParameterRemoval")
	parameterLabel.text = ""
	parameterValueLineEdit.visible = false
	parameterLabel.visible = false
	deleteButton.visible = false
	createButton.visible = true

func OnParameterNameChanged(value):
	parameterName = value
	parameterLabel.text = value + " = "

func ParseExpression():
	var text = parameterValueLineEdit.text
	if(text == ""): text = "0.0"
	var error = expression.parse(text, Parameters.parametersNames)
	if(error != OK):
		parameterValueLineEdit.ShowWarning()
		print(expression.get_error_text())
		parseError = true
	else:
		parameterValueLineEdit.HideWarning()
		parseError = false

func ExecuteExpression(defaultValue = 0.0) -> float:
	var outValue
	if(parseError):
		parameterValueLineEdit.ShowWarning()
		outValue = defaultValue
		return outValue
	var temp = expression.execute(Parameters.parametersValues, null, false)
	if (expression.has_execute_failed() || temp == null):
		#print("toolExecute failed")
		outValue = defaultValue
	else:
		outValue = temp
	return outValue

func _on_ParameterValueLineEdit_text_changed(_new_text):
	ParseExpression()
	UpdateParameter()
	Parameters.emit_signal("parametersChanged")

func UpdateParameter():
	parameterValue = ExecuteExpression()
	Parameters.ChangeParameterValue(parameterName, parameterValue)

func _on_CreateButton_pressed():
	$Popup/Panel/EnterParameterLabel/ParameterNameLineEdit.text = ""
	popup.popup_centered()
	parameterLabel.visible = true
	parameterValueLineEdit.visible = true
	parameterValueLineEdit.text = "0.0"
	createButton.visible = false
	deleteButton.visible = true
	active = true
	ParseExpression()

func _on_DeleteButton_pressed():
	parameterValueLineEdit.text = ""
	parameterValueLineEdit.visible = false
	parameterLabel.visible = false
	deleteButton.visible = false
	createButton.visible = true
	emit_signal("onRemoval", self)
	Parameters.RemoveParameter(parameterName)
	self.parameterName = ""
	active = false

func Reset(name = ""):
	parameterValueLineEdit.text = ""
	parameterValueLineEdit.visible = false
	parameterLabel.visible = false
	deleteButton.visible = false
	createButton.visible = true
	parameterName = name

func _on_ParameterNameLineEdit_text_entered(new_text):
	popup.hide()
	#if user entered forbidden symbol or "time"
	if HasForbiddenSymbols(new_text):
		#new parameter, not a rename
		if parameterName == "":
			Reset()
		parameterValueLineEdit.ShowWarning()
	#if parameter already has a name, then rename it
	elif parameterName != "":
		var oldName = parameterName
		parameterName = new_text
		Parameters.ChangeParameterName(oldName, new_text)
		self.parameterName = new_text
	# add new parameter
	else:
		RegisterParameter(new_text)

func  RegisterParameter(paramName = parameterName, value = "0.0") -> bool:
	if !paramName.is_valid_identifier(): return false;
	parameterValueLineEdit.HideWarning()
	self.parameterName = paramName
	parameterValueLineEdit.text = value
	ParseExpression()
	Parameters.AddParameter(parameterName, parameterValue)
	emit_signal("onCreation")
	return true

func RegisterParameterImplicitly(paramName = parameterName, value = "0.0") -> bool:
	if !paramName.is_valid_identifier(): return false;
	parameterValueLineEdit.HideWarning()
	self.parameterName = paramName
	parameterValueLineEdit.text = value
	ParseExpression()
	Parameters.AddParameter(parameterName, parameterValue)
	parameterLabel.visible = true
	parameterValueLineEdit.visible = true
	createButton.visible = false
	deleteButton.visible = true
	active = true
	
	emit_signal("onCreation")
	return true

func _on_ParameterLabel_gui_input(event):
	if event is InputEventMouseButton && event.doubleclick:
		popup.popup_centered()

func HasForbiddenSymbols(line: String) -> bool:
	if !line.is_valid_identifier(): return true
	if line == "t": return true
	if Parameters.parametersNames.has(line): return true
	return false

func _input(event):
	# if Esc was pressed and name wasn't entered
	if popup.visible and event is InputEventAction and event.action == "ui_cancel" and name == "":
		_on_DeleteButton_pressed()
