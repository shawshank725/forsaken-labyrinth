extends Node2D
@onready var label = $Label
@onready var label_2 = $Label2
@onready var label_3 = $Label3
@onready var label_4 = $Label4
@onready var level = preload("res://scenes/level_1.tscn")

func _ready():
	var tween_visible = get_tree().create_tween()
	tween_visible.tween_property(label,"visible_ratio",1.0,3)
	tween_visible.tween_property(label_2,"visible_ratio",1.0,3)
	tween_visible.tween_property(label_3,"visible_ratio",1.0,3)
	tween_visible.tween_property(label_4,"visible_ratio",1.0,3)

func _on_skip_button_pressed():
	get_tree().change_scene_to_packed(level)
