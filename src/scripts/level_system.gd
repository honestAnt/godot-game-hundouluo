extends Node

# 关卡进度
var current_level = 1
var difficulty = "normal"  # easy/normal/hard
var max_levels = 3
var level_completed = false

func _ready():
	# 尝试加载保存的进度
	if FileAccess.file_exists("user://save.dat"):
		load_game()
	else:
		load_level(current_level)
		
func save_game():
	var save_data = {
		"current_level": current_level,
		"max_levels": max_levels,
		"player_weapons": [],  # 待实现武器保存
		"player_health": 100  # 待实现生命保存
	}
	
	var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
	if file:
		file.store_var(save_data)
		return true
	return false
	
func load_game():
	var file = FileAccess.open("user://save.dat", FileAccess.READ)
	var data = file.get_var()
	current_level = data["current_level"]
	max_levels = data["max_levels"]
	load_level(current_level)

func load_level(level_num):
	print("加载关卡: ", level_num)
	# 这里添加实际的关卡加载逻辑
	match level_num:
		1:
			load_jungle_level()
		2: 
			load_base_level()
		3:
			load_boss_level()

func complete_level():
	level_completed = true
	current_level += 1
	if current_level <= max_levels:
		load_level(current_level)
	else:
		game_complete()

func load_jungle_level():
	print("加载丛林关卡...")

func load_base_level():
	print("加载基地关卡...")

func load_boss_level():
	print("加载Boss关卡...")
	var boss = load("res://src/scenes/boss.tscn").instantiate()
	get_tree().current_scene.add_child(boss)

func game_complete():
	print("游戏通关!")