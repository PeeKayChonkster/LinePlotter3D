extends ColorPickerButton

onready var ui = get_node("/root/World/UI")

func _ready():
	get_popup().connect("about_to_show", self, "OnPickerCreated")
	connect("popup_closed", self, "OnPopupClosed")

func OnPickerCreated():
	ui.inEditMode = true
	ui.editFlags += 1

func OnPopupClosed():
	ui.editFlags -= 1
	ui.CheckFlags()

func _is_pos_in(checkpos:Vector2):
	var gr = get_global_rect()
	return checkpos.x>=gr.position.x and checkpos.y>=gr.position.y and checkpos.x<gr.end.x and checkpos.y<gr.end.y

func _input(event):
	if event is InputEventMouseButton and not _is_pos_in(event.position) and event.is_pressed():
		release_focus()
