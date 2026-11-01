extends TileMap


func _ready():
	set_process_input(true)

func _input(event):
	if event is InputEventMouse:
		event.handled = true
