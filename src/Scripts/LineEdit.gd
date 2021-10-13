extends LineEdit

onready var warning = $Warning
onready var ui = get_node("/root/World/UI")

func _ready():
	connect("focus_entered", self, "OnFocusEntered")
	connect("focus_exited", self, "OnFocusExited")
	HideWarning()
	release_focus()

func OnFocusEntered():
	ui.inEditMode = true
	ui.editFlags += 1

func OnFocusExited():
	ui.editFlags -= 1
	ui.CheckFlags()

func _is_pos_in(checkpos:Vector2):
	var gr = get_global_rect()
	return checkpos.x>=gr.position.x and checkpos.y>=gr.position.y and checkpos.x<gr.end.x and checkpos.y<gr.end.y

func _input(event):
	if event is InputEventMouseButton and not _is_pos_in(event.position) and event.is_pressed():
		release_focus()
		select(0, 0)
	if event is InputEvent and event.is_action_pressed("ui_accept") && get_focus_owner() == self:
		emit_signal("text_entered", text)
		select(0, 0)
		release_focus()

func ShowWarning():
	warning.visible = true

func HideWarning():
	warning.visible = false

