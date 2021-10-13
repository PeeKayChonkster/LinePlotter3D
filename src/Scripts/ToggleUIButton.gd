extends Button

export var visibilityRaduis = 0.3

onready var sreenSize = get_viewport().size

func _is_pos_in(checkpos:Vector2):
	var gr = get_global_rect()
	return checkpos.x>=gr.position.x and checkpos.y>=gr.position.y and checkpos.x<gr.end.x and checkpos.y<gr.end.y


func _input(event):
	if event is InputEventMouseMotion:
		if(event.position.x < sreenSize.x * visibilityRaduis && event.position.y > sreenSize.y * (1.0 - visibilityRaduis)):
			visible = true
		elif(!pressed):
			visible = false
	if event is InputEvent:
		if event.is_action_pressed("q") && !get_parent().inEditMode && !get_parent().animationPlayer.is_playing(): 
			visible = true
			pressed = !pressed
	if event is InputEventMouseButton and not _is_pos_in(event.position) and event.is_pressed():
		release_focus()
