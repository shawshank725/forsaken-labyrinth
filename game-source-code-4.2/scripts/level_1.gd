extends Node2D
@onready var player = $Player
@onready var health_bar = $UI/HealthBar
@onready var potion_bar = $UI/PotionBar
@onready var dialog = $Player/Dialog

var short_teleportation_timer := Timer.new()
@onready var timer_for_short_teleportation_label = $UI/Short_Teleportation/Timer_for_short_teleportation_Label
@onready var platforms = get_node("Objects_in_BG/Platform_group").get_children()
@onready var tile_map = $TileMap
@onready var location_label = $UI/ColorRect_for_Label/LocationLabel
@onready var ladders = get_node("Objects_in_BG/Ladder_Group").get_children()
@onready var camera_2d = $Player/Camera2D
var torch_preloaded = preload("res://scenes/torch.tscn")
@onready var lever_tilted = $Objects_in_BG/Lever/Lever_tilted
@onready var lever_untilted = $Objects_in_BG/Lever/Lever_untilted
@onready var torch_group = get_node("Objects_in_BG/Torch_Group").get_children()
@onready var inventory_popup_panel = $InventoryPopupPanel
@onready var inventory = get_node("InventoryPopupPanel/VBoxContainer/Inventory").get_children()
@onready var pause_popup_panel = $PausePopupPanel
@onready var exit = $Objects_in_BG/Doors_in_Walls/Exit
@onready var death_popup_panel = $DeathPopupPanel
@onready var MusicPlayer = $MusicPlayer

var life_draining = false
var life_draining_amount = 0.001
var player_is_in_traproom = false
var teleportation_power_left = 10
var empty_slots_list = []
var key_1_collected = false
var key_2_collected = false
var black_monolith_collected = false
var wand_collected = false
var sword_collected = false
var treasure_collected = false
var shield_collected = false
var armor_collected = false

@onready var key_1_node = get_node("Objects_in_BG/Magical_Items/Keys/Key_1")
@onready var key_2_node = get_node("Objects_in_BG/Magical_Items/Keys/Key_2")
@onready var black_monolith_node = get_node("Objects_in_BG/Magical_Items/BlackMonolith")
@onready var sword_node = get_node("Objects_in_BG/Magical_Items/Sword")
@onready var treasure_node = get_node("Objects_in_BG/Magical_Items/Treasure")
@onready var shield_node = get_node("Objects_in_BG/Magical_Items/Shield")
@onready var armor_node = get_node("Objects_in_BG/Magical_Items/Armor")
@onready var wand_node = get_node("Objects_in_BG/Magical_Items/Wand")
@onready var health_potion_node = get_node("Objects_in_BG/Alchemy_Lab/First_Floor/Flasks/Health_Potion")
@onready var health_potion_2_node = get_node("Objects_in_BG/Alchemy_Lab/First_Floor/Flasks/Health_Potion2")
@onready var potion_node = get_node("Objects_in_BG/Alchemy_Lab/Third_Floor/Flasks/Potion")
@onready var potion_2_node = get_node("Objects_in_BG/Alchemy_Lab/Third_Floor/Flasks/Potion2")
@onready var lever_node = get_node("Objects_in_BG/Lever")

const wand = "res://assets/armory/Free RPG asset Pack/PACK/separate files/wand_02.png"
const sword = "res://assets/armory/Free RPG asset Pack/PACK/separate files/sword_02.png"
const black_monolith = "res://assets/Black_Rock/frame0000.png"
const treasure = "res://assets/Objects/chest_closed.png"
const key_1 = "res://assets/useful keys/Key 2/GOLD/Key 2 - GOLD - 0003.png"
const key_2 = "res://assets/useful keys/Key 2/GREY/Key 2 - GREY - 0002.png"
const shield  = "res://assets/armory/RavenmoreIconPack2023/64/ShieldLargeT2.png"
const armor = "res://assets/armory/RavenmoreIconPack2023/64/ArmorT1.png"
const frame = "res://assets/armory/RavenmoreIconPack2023/64/FrameSquare.png"

@export var randomStrength: float = 5.0
@export var shakeFade : float = 5.0
var rng = RandomNumberGenerator.new()
var shake_strength: float = 0.0

func apply_shake():
	shake_strength = randomStrength

func randomOffset():
	return Vector2(rng.randf_range(-shake_strength,shake_strength),rng.randf_range(-shake_strength,shake_strength))

func _ready():
	player.position = Vector2(100,250)
	health_bar.value = 100
	potion_bar.value = 100
	add_child(short_teleportation_timer)
	short_teleportation_timer.wait_time = 20
	short_teleportation_timer.one_shot = true

func _process(delta):
	if (key_1_collected and key_2_collected and wand_collected and black_monolith_collected and treasure_collected and sword_collected and shield_collected and armor_collected):
		exit.get_child(1).set_deferred("visible",true)
		if potion_bar.value >0:
			potion_bar.value -=1
		#for i in torch_group:
			#i.get_child(0).set_deferred("visible",false)
			#i.get_child(1).set_deferred("visible",false)
			#i.get_child(2).set_deferred("visible",true)
		#change_all_cells_in_tilemap()
		apply_shake()
		camera_2d.offset = randomOffset()
		life_draining_amount = 0.01

	if health_bar.value <=0:
		player.anim.play("death")
		await get_tree().create_timer(0.9).timeout
		var tween_modulate = get_tree().create_tween()
		tween_modulate.tween_property(player,"modulate:a",0,0.3)
		await get_tree().create_timer(2).timeout
		death_popup_panel.set_deferred("visible",true)
	
	if life_draining:
		health_bar.value -=(life_draining_amount*10)
	health_bar.value -= life_draining_amount
	
	if Input.is_action_just_pressed("ui_down"):
		for i in platforms:
			for j in i.get_children(false):
				if j.name == "StaticBody2D":
					var collision_shape_2d = j.get_child(0)
					collision_shape_2d.set_deferred("disabled",true)
		for q in ladders:
			for w in q.get_children(false):
				if w.name == "StaticBody2D":
					for e in w.get_children():
						e.set_deferred("disabled",true)

	elif Input.is_action_just_released("ui_down"):
		for i in platforms:
			for j in i.get_children(false):
				if j.name == "StaticBody2D":
					var collision_shape_2d = j.get_child(0)
					collision_shape_2d.set_deferred("disabled",false)
		for q in ladders:
			for w in q.get_children(false):
				if w.name == "StaticBody2D":
					for e in w.get_children():
						e.set_deferred("disabled",false)

	if short_teleportation_timer.time_left == 0:
		timer_for_short_teleportation_label.text = ""
		if Input.is_action_just_pressed("right_mouse"):
			if potion_bar.value == 0:
				dialog.text = "No teleportation potion available."
				await get_tree().create_timer(1).timeout
				dialog.text = ""
			else:
				if player_is_in_traproom == true:
					dialog.text = "Teleportation blocked in trap room."
					await get_tree().create_timer(1).timeout
					dialog.text = ""
				else:
					if (get_global_mouse_position() - player.position).length() <=450:
						if get_tile_at_mouse_pointer(get_global_mouse_position()):
							player.position = get_global_mouse_position()
							short_teleportation_timer.start()
							teleportation_power_left -= 1
							potion_bar.value -=10
					else:
						dialog.text = "Distance is too much."
						await get_tree().create_timer(1).timeout
						dialog.text = ""
						
	else:
		timer_for_short_teleportation_label.text = str(snapped(short_teleportation_timer.time_left,0))+"s"
		

func _on_short_teleportation_timer_timeout():
	timer_for_short_teleportation_label.text = ""

func get_tile_at_mouse_pointer(mouse_pointer):
	var clicked_cell = tile_map.local_to_map(mouse_pointer)
	var data = tile_map.get_cell_tile_data(0,clicked_cell)
	if data :
		return false   #there is a tile we dont have to teleport there
	else:
		return true  #there is no tile we can teleport there

#functions of location player has entered
func _on_kitchen_area_2d_body_entered(body):
	if body.name == "Player":
		location_label.visible_ratio = 0
		location_label.text = "You are in the Kitchen."
		var tween_visible = get_tree().create_tween()
		tween_visible.tween_property(location_label,"visible_ratio",1.0,1)

func _on_entrance_hall_area_2d_body_entered(body):
	if body.name == "Player":
		location_label.visible_ratio = 0
		location_label.text = "You are in the Entrance Hall."
		var tween_visible = get_tree().create_tween()
		tween_visible.tween_property(location_label,"visible_ratio",1.0,1)

func _on_catacomb_area_2d_body_entered(body):
	if body.name == "Player":
		location_label.visible_ratio = 0
		location_label.text = "You are in the Catacombs."
		var tween_visible = get_tree().create_tween()
		tween_visible.tween_property(location_label,"visible_ratio",1.0,1)

func _on_prison_area_2d_body_entered(body):
	if body.name == "Player":
		location_label.visible_ratio = 0
		location_label.text = "You are in the Prison."
		var tween_visible = get_tree().create_tween()
		tween_visible.tween_property(location_label,"visible_ratio",1.0,1)

func _on_alchemy_area_2d_body_entered(body):
	if body.name == "Player":
		life_draining = true
		location_label.visible_ratio = 0
		location_label.text = "You are in the Alchemy Laboratory."
		var tween_visible = get_tree().create_tween()
		tween_visible.tween_property(location_label,"visible_ratio",1.0,1)

func _on_alchemy_area_2d_body_exited(body):
	if body.name == "Player":
		life_draining = false

func _on_trap_room_area_2d_body_entered(body):
	if body.name == "Player":
		player_is_in_traproom = true
		location_label.visible_ratio = 0
		location_label.text = "You are in the Trap room."
		var tween_visible = get_tree().create_tween()
		tween_visible.tween_property(location_label,"visible_ratio",1.0,1)

func _on_trap_room_area_2d_body_exited(body):
	if body.name == "Player":
		player_is_in_traproom = false

func _on_trap_room_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			player_is_in_traproom = true
	
func _on_guard_hall_area_2d_body_entered(body):
	if body.name == "Player":
		location_label.visible_ratio = 0
		location_label.text = "You are in the Guard Hall."
		var tween_visible = get_tree().create_tween()
		tween_visible.tween_property(location_label,"visible_ratio",1.0,1)

func _on_armory_area_2d_body_entered(body):
	if body.name == "Player":
		location_label.visible_ratio = 0
		location_label.text = "You are in the Armory."
		var tween_visible = get_tree().create_tween()
		tween_visible.tween_property(location_label,"visible_ratio",1.0,1)

func _on_throne_hall_area_2d_body_entered(body):
	if body.name == "Player":
		location_label.visible_ratio = 0
		location_label.text = "You are in the Throne Room."
		var tween_visible = get_tree().create_tween()
		tween_visible.tween_property(location_label,"visible_ratio",1.0,1)

#functions of door
func _on_prison_to_guard_hall_area_2d_body_entered(body):
	if body.name == "Player" :
		player.position = Vector2(-75,500)

func _on_guard_hall_to_prison_area_2d_body_entered(body):
	if body.name == "Player":
		player.position = Vector2(100,500)

func _on_door_in_guard_hall_front_area_2d_body_entered(body):
	if body.name == "Player":
		player.position = Vector2(-100,800)

func _on_door_in_armory_area_2d_body_entered(body):
	if body.name == "Player":
		player.position = Vector2(-1150,500)

func _on_door_in_entrance_hall_area_2d_body_entered(body):
	if body.name == "Player":
		player.position = Vector2(-1100,5)

func _on_door_in_guard_hall_front_to_entrance_area_2d_body_entered(body):
	if body.name == "Player":
		player.position = Vector2(-1200,-200)

func _on_door_to_trap_room_area_2d_body_entered(body):
	if body.name == "Player":
		player.position = Vector2(25,-450)

func _on_door_in_trap_room_connected_to_alchemy_area_2d_body_entered(body):
	if body.name == "Player":
		player.position = Vector2(-250,-450)

func _on_door_in_alchemy_connected_to_trap_room_area_2d_body_entered(body):
	if body.name == "Player":
		player.position = Vector2(1000,-675)

func _on_door_in_kitchen_to_alchemy_area_2d_body_entered(body):
	if body.name == "Player":
		player.position = Vector2(-200,-1100)

func _on_door_in_alchemy_to_kitchen_area_2d_body_entered(body):
	if body.name == "Player":
		player.position = Vector2(2500,-450)

func _on_door_to_throne_room_area_2d_body_entered(body):
	if body.name == "Player":
		player.position = Vector2(2550,-1050)

func _on_door_to_entrance_hall_area_2d_body_entered(body):
	if body.name == "Player":
		player.position = Vector2(955,-300)

func _on_saw_hurt_area_2d_body_entered(body):
	if body.name == "Player":
		health_bar.value -= 4
		player_hurt_tweens()

func _on_spikes_hurt_area_2d_body_entered(body):
	if body.name == "Player":
		health_bar.value -= 4
		player_hurt_tweens()

func _on_cutter_area_2d_body_entered(body):
	if body.name == "Player":
		health_bar.value -= 4
		player_hurt_tweens()

func player_hurt_tweens():
	var tween_position = get_tree().create_tween()
	var tween_modulate = get_tree().create_tween()
	var direction = Input.get_axis("ui_left","ui_right")
	if direction == 1:
		tween_position.tween_property(player,"position",player.global_position-Vector2(50,0),0.4)
	elif direction == -1:
		tween_position.tween_property(player,"position",player.global_position+Vector2(50,0),0.4)
	for i in range(3):
		tween_modulate.tween_property(player,"modulate:a",0,0.3)
		tween_modulate.tween_property(player,"modulate:a",1,0.3)

func _on_check_lever_is_pushed_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (lever_node.position - player.position).length() <=100:
				lever_tilted.set_deferred("visible",true)
				lever_untilted.set_deferred("visible",false)
				for i in torch_group:
					i.get_child(0).set_deferred("visible",true)
					i.get_child(1).set_deferred("visible",true)
					i.get_child(2).set_deferred("visible",false)
			else:
				dialog.text = "Go closer to activate it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")

#magical items functions
func _on_key_1_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (key_1_node.position - player.position).length() <=100:
				key_1_collected = true
				tween_methods_for_collectibles(get_node("Objects_in_BG/Magical_Items/Keys/Key_1"))
				dialog.text = "Key collected."
				MusicPlayer.stream = preload("res://assets/Sounds/treasure.wav")
				MusicPlayer.play()
				await get_tree().create_timer(1).timeout
				inventory[0].get_child(0).set_deferred("texture",preload(key_1))
				dialog.set_deferred("text","")
			else:
				dialog.text = "Go closer to collect it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")
		
func _on_key_2_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (key_2_node.position - player.position).length() <=100:
				key_2_collected = true
				tween_methods_for_collectibles(get_node("Objects_in_BG/Magical_Items/Keys/Key_2"))
				dialog.text = "Key collected."
				MusicPlayer.stream = preload("res://assets/Sounds/treasure.wav")
				MusicPlayer.play()
				await get_tree().create_timer(1).timeout
				inventory[1].get_child(0).set_deferred("texture",preload(key_2))
				dialog.set_deferred("text","")
			else:
				dialog.text = "Go closer to collect it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")

func _on_blackmonolith_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (black_monolith_node.position - player.position).length() <=100:
				black_monolith_collected = true
				tween_methods_for_collectibles(get_node("Objects_in_BG/Magical_Items/BlackMonolith"))
				dialog.text = "Black Monolith collected."
				MusicPlayer.stream = preload("res://assets/Sounds/treasure.wav")
				MusicPlayer.play()
				await get_tree().create_timer(1).timeout
				inventory[2].get_child(0).set_deferred("texture",preload(black_monolith))
				dialog.set_deferred("text","")
			else:
				dialog.text = "Go closer to collect it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")

func _on_wand_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (wand_node.position - player.position).length() <=100:
				wand_collected = true
				tween_methods_for_collectibles(get_node("Objects_in_BG/Magical_Items/Wand"))
				dialog.text = "Wand collected."
				MusicPlayer.stream = preload("res://assets/Sounds/treasure.wav")
				MusicPlayer.play()
				await get_tree().create_timer(1).timeout
				inventory[3].get_child(0).set_deferred("texture",preload(wand))
				dialog.set_deferred("text","")
			else:
				dialog.text = "Go closer to collect it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")

func _on_sword_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (sword_node.position - player.position).length() <=100:
				sword_collected = true
				tween_methods_for_collectibles(get_node("Objects_in_BG/Magical_Items/Sword"))
				dialog.text = "Sword collected."
				MusicPlayer.stream = preload("res://assets/Sounds/treasure.wav")
				MusicPlayer.play()
				await get_tree().create_timer(1).timeout
				inventory[4].get_child(0).set_deferred("texture",preload(sword))
				dialog.set_deferred("text","")
			else:
				dialog.text = "Go closer to collect it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")

func _on_treasure_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (treasure_node.position - player.position).length() <=100:
				treasure_collected = true
				tween_methods_for_collectibles(get_node("Objects_in_BG/Magical_Items/Treasure"))
				dialog.text = "Treasure collected."
				MusicPlayer.stream = preload("res://assets/Sounds/treasure.wav")
				MusicPlayer.play()
				await get_tree().create_timer(1).timeout
				inventory[5].get_child(0).set_deferred("texture",preload(treasure))
				dialog.set_deferred("text","")
			else:
				dialog.text = "Go closer to collect it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")

func _on_shield_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (shield_node.position - player.position).length() <=100:
				shield_collected = true
				tween_methods_for_collectibles(get_node("Objects_in_BG/Magical_Items/Shield"))
				dialog.text = "Shield collected."
				MusicPlayer.stream = preload("res://assets/Sounds/treasure.wav")
				MusicPlayer.play()
				inventory[6].get_child(0).set_deferred("texture",preload(shield))
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")
			else:
				dialog.text = "Go closer to collect it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")

func _on_armor_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (armor_node.position - player.position).length() <=100:
				armor_collected = true
				tween_methods_for_collectibles(get_node("Objects_in_BG/Magical_Items/Armor"))
				dialog.text = "Armor collected."
				MusicPlayer.stream = preload("res://assets/Sounds/treasure.wav")
				MusicPlayer.play()
				await get_tree().create_timer(1).timeout
				inventory[7].get_child(0).set_deferred("texture",preload(armor))
				dialog.set_deferred("text","")
			else:
				dialog.text = "Go closer to collect it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")

func _on_potion_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (potion_node.global_position - player.position).length() <=100:
				dialog.text = "+40% potion."
				tween_methods_for_collectibles(get_node("Objects_in_BG/Alchemy_Lab/Third_Floor/Flasks/Potion"))
				MusicPlayer.stream = preload("res://assets/Sounds/health.wav")
				MusicPlayer.play()
				await get_tree().create_timer(1).timeout
				teleportation_power_left += 4
				potion_bar.value +=40
				dialog.text = ""
			else:
				dialog.text = "Go closer to collect it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")
			
func _on_potion_2_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (potion_2_node.global_position - player.position).length() <=100:
				dialog.text = "+40% potion."
				tween_methods_for_collectibles(get_node("Objects_in_BG/Alchemy_Lab/Third_Floor/Flasks/Potion2"))
				MusicPlayer.stream = preload("res://assets/Sounds/health.wav")
				MusicPlayer.play()
				await get_tree().create_timer(1).timeout
				teleportation_power_left += 4
				potion_bar.value +=40 	
				dialog.text = ""
			else:
				dialog.text = "Go closer to collect it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")

func _on_inventory_button_pressed():
	inventory_popup_panel.visible = true

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level_1.tscn")
	
func _on_menu_button_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_pause_button_pressed():
	get_tree().paused = true
	pause_popup_panel.visible = true

func _on_resume_button_pressed():
	get_tree().paused = false
	pause_popup_panel.visible = false

func _on_exit_area_2d_body_entered(body):
	if body.name == "Player":
		if (key_1_collected and key_2_collected and wand_collected and black_monolith_collected and treasure_collected and sword_collected and shield_collected and armor_collected):
			var tween_modulate = get_tree().create_tween()
			tween_modulate.tween_property(body,"modulate:a",0,0.4)
			await get_tree().create_timer(1).timeout
			get_tree().change_scene_to_file("res://scenes/ending.tscn")

func _on_health_potion_2_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (health_potion_2_node.global_position - player.position).length() <=100:
				dialog.text = "+25% health."
				tween_methods_for_collectibles(get_node("Objects_in_BG/Alchemy_Lab/First_Floor/Flasks/Health_Potion2"))
				MusicPlayer.stream = preload("res://assets/Sounds/health.wav")
				MusicPlayer.play()
				await get_tree().create_timer(1).timeout
				health_bar.value +=25
				dialog.text = ""
			else:
				dialog.text = "Go closer to collect it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")

func _on_health_potion_area_2d_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if  (health_potion_node.global_position - player.position).length() <=100:
				dialog.text = "+25% health."
				tween_methods_for_collectibles(get_node("Objects_in_BG/Alchemy_Lab/First_Floor/Flasks/Health_Potion"))
				MusicPlayer.stream = preload("res://assets/Sounds/health.wav")
				MusicPlayer.play()
				await get_tree().create_timer(1).timeout
				health_bar.value +=25
				dialog.text = ""
			else:
				dialog.text = "Go closer to collect it."
				await get_tree().create_timer(1).timeout
				dialog.set_deferred("text","")

func tween_methods_for_collectibles(object):
	var tween_position = get_tree().create_tween()
	var tween_modulate = get_tree().create_tween()
	tween_position.tween_property(object,"position",object.position-Vector2(0,10),0.5)
	tween_modulate.tween_property(object,"modulate:a",0,0.5)
	tween_position.tween_callback(object.queue_free)
