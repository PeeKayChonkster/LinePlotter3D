extends Control

onready var xCoordinateLabel = $UIPanel/XCoordinateLabel
onready var yCoordinateLabel = $UIPanel/YCoordinateLabel
onready var zCoordinateLabel = $UIPanel/ZCoordinateLabel
onready var animationPlayer = $AnimationPlayer
onready var toggleUIButton = $ToggleUIButton
onready var colorFilter = $ColorFilter
onready var parametersContainer = $ParametersPanel/VBoxContainer
onready var parameterUIPrefab = preload("res://src/Objects/ParameterUI.tscn")

var inEditMode = false
var parameterUIs = []
var editFlags = 0

func _ready():
	parameterUIs.append(parameterUIPrefab.instance())
	parametersContainer.add_child(parameterUIs[0])


func OnParameterCreation():
	if parameterUIs.size() >= Parameters.maxParameters:
		return
	var temp = parameterUIPrefab.instance()
	self.parameterUIs.append(temp)
	parametersContainer.add_child(temp)

func OnParameterRemoval(value):
	if parameterUIs.size() > 1:
		parameterUIs.erase(value)
		value.queue_free()
		if parameterUIs.size() == Parameters.maxParameters - 1 && parameterUIs[Parameters.maxParameters - 2].active:
			OnParameterCreation()

func CreateParameter(parameterName, value = "0.0"):
	if parameterUIs.size() >= Parameters.maxParameters:
		return
	parameterUIs[parameterUIs.size() - 1].RegisterParameterImplicitly(parameterName, value)

func CheckFlags():
	if editFlags > 0:
		return
	else:
		inEditMode = false
		release_focus()


func _on_AnimationPlayer_animation_finished(_anim_name):
	toggleUIButton.disabled = false




func _on_ToggleUIButton_toggled(button_pressed):
	if(animationPlayer.is_playing()): 
		return
	if(button_pressed):
		toggleUIButton.disabled = true
		animationPlayer.play("Open")
	else:
		toggleUIButton.disabled = true
		animationPlayer.play("Close")
