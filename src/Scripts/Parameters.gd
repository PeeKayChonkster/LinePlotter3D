extends Node

var parametersNames = ["t"]
var parametersValues = [0.0]
var maxParameters = 20
onready var world = get_node("/root/World") 
onready var ui = get_node("/root/World/UI") 
signal parametersChanged

func ResetTime(updateParameters: bool):
	parametersValues[0] = 0.0
	if updateParameters:
		UpdateParameters()

func SetTime(value: float, updateParameters: bool):
	parametersValues[0] = value
	if updateParameters:
		UpdateParameters()

func GetTime() -> float:
	return parametersValues[0]

func IncrementTime(value: float, updateParameters: bool):
	parametersValues[0] += value
	if updateParameters:
		UpdateParameters()

func AddParameter(name: String, value: float):
	if parametersNames.has(name):
		print("Trying to add parameter \"" + name +  "\" that already in the parameterNames!!!")
		return
	if(parametersNames.size() + 1 < maxParameters):
		parametersNames.append(name)
		parametersValues.append(value)
		ReparseParameters()
		emit_signal("parametersChanged")

func ChangeParameterValue(name: String, value: float):
	var index = parametersNames.find(name)
	if index == -1:
		print("Parameter \"" + name +  "\" wasn't found in parametersNames!!!")
		return
	parametersValues[index] = value

func ChangeParameterName(oldName: String, newName: String):
	var index = parametersNames.find(oldName)
	if index == -1:
		print("Parameter \"" + oldName +  "\" wasn't found in parametersNames!!!")
		return
	parametersNames[index] = newName
	ReparseParameters()
	emit_signal("parametersChanged")

func RemoveParameter(name: String):
	var index = parametersNames.find(name)
	if index != -1:
		parametersNames.remove(index)
		parametersValues.remove(index)
		ReparseParameters()
		emit_signal("parametersChanged")

func UpdateParameters():
	for param in ui.parameterUIs:
		if param.active && !param.parameterName.empty():
			param.UpdateParameter()

func ReparseParameters():
	for p in ui.parameterUIs:
		if p.active:
			p.ParseExpression()
