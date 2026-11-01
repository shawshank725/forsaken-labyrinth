extends Control

# Called when an input event is received.
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventMouseMotion:
		# Allow the event to pass through
		get_tree().set_input_as_handled()
	else:
		# Handle other input events as needed
		pass
