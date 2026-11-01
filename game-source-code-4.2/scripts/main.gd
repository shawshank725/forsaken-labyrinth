extends Node2D
@onready var sound_button = $Sound_Button

var play_scene = preload("res://scenes/starting_story.tscn")
var help_scene = preload("res://scenes/help_scene.tscn")
var credit_scene = preload("res://scenes/credits_scene.tscn")

const SPEAKER_0 = preload("res://assets/others/UI Icons/PNG/Flat/32/Speaker-0.png")
const SPEAKER_CROSSED = preload("res://assets/others/UI Icons/PNG/Flat/32/Speaker-Crossed.png")

func _on_play_button_pressed():
	get_tree().change_scene_to_packed(play_scene)

func _on_help_button_pressed():
	get_tree().change_scene_to_packed(help_scene)

func _on_credits_button_pressed():
	get_tree().change_scene_to_packed(credit_scene)
#
#func _on_sound_button_pressed():
	#if MusicPlayer.playing:
		#MusicPlayer.stop()
		#sound_button.icon = SPEAKER_CROSSED
	#else:
		#MusicPlayer.play()
		#sound_button.icon = SPEAKER_0

