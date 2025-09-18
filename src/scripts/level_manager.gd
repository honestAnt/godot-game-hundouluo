extends Node

# 关卡管理
enum LEVEL {JUNGLE, BASE, FINAL_BOSS}
var current_level = LEVEL.JUNGLE
var level_completed = false

func _ready():
	load_level(current_level)

func load_level(level):
	match level:
		LEVEL.JUNGLE:
			load_jungle_level()
		LEVEL.BASE:
			load_base_level()
		LEVEL.FINAL_BOSS:
			load_final_boss_level()

func load_jungle_level():
	# 加载丛林关卡资源
	print("加载丛林关卡...")
	# 这里添加实际的关卡加载逻辑

func load_base_level():
	# 加载基地关卡资源
	print("加载基地关卡...")
	# 这里添加实际的关卡加载逻辑

func load_final_boss_level():
	# 加载最终Boss关卡
	print("加载最终Boss关卡...")
	var boss_scene = load("res://src/scenes/boss.tscn")
	var boss = boss_scene.instantiate()
	get_tree().current_scene.add_child(boss)

func complete_level():
	level_completed = true
	print("关卡完成!")
	
	# 解锁下一关
	match current_level:
		LEVEL.JUNGLE:
			current_level = LEVEL.BASE
		LEVEL.BASE:
			current_level = LEVEL.FINAL_BOSS
		LEVEL.FINAL_BOSS:
			print("游戏通关!")
	
	# 加载下一关
	if current_level != LEVEL.FINAL_BOSS or not level_completed:
		load_level(current_level)

func boss_defeated():
	print("Boss被击败!")
	complete_level()