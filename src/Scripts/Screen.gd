extends Node

var windowSize = Vector2(1600, 900)
onready var windowPos = Vector2(OS.get_screen_size().x / 2 - 800, OS.get_screen_size().y / 2 - 450)

func _ready():
	OS.set_window_size(windowSize)
	OS.set_window_position(windowPos)
	
func _input(event):
	if event is InputEvent:
		if event.is_action_pressed("f3"):
			Fullscreen()
		if OS.window_borderless and event.is_action_pressed("esc"):
			Fullscreen()


func Fullscreen():
	if OS.window_borderless:
		OS.set_borderless_window(false)
		OS.set_window_size(windowSize)
		OS.set_window_position(windowPos)
	else:
		OS.set_borderless_window(true)
		windowSize = OS.get_window_size() 
		OS.set_window_size(OS.get_screen_size())
		windowPos = OS.get_window_position()
		OS.set_window_position(Vector2.ZERO)

func ChangeWindowSize(size: Vector2):
	OS.set_window_size(size)
	windowSize = size

func GetWindowSize():
	return OS.get_window_size()
