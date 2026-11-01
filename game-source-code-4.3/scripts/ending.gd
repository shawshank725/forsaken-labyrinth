extends Node2D

@onready var label = $Label
@onready var label_2 = $Label2
@onready var label_3 = $Label3
@onready var label_4 = $Label4
var take_input = false

func _ready():
	#var tween_visible = get_tree().create_tween()
	#tween_visible.tween_property(label,"visible_ratio",1.0,3)
	#tween_visible.tween_property(label_2,"visible_ratio",1.0,3)
	#tween_visible.tween_property(label_3,"visible_ratio",1.0,3)
	#await get_tree().create_timer(10).timeout
	#var tween_modulate = get_tree().create_tween()
	#tween_modulate.tween_property(label_4,"modulate:a",1,1)
	var timer_node = get_tree().create_timer(3)
	await timer_node.timeout
	if timer_node.time_left == 0:
		take_input = true
		var tween_modulate = get_tree().create_tween()
		tween_modulate.tween_property(label_4,"modulate:a",1,1)

func _process(delta):
	if take_input == true:
		if Input.is_anything_pressed():
			get_tree().change_scene_to_file("res://scenes/main.tscn")
