
extends Node2D

var level_system  # 移除非@onready声明

func _ready():
	# 获取自动加载的LevelSystem实例
	level_system = get_node("user://save.dat") if has_node("user://save.dat") else null
	print("LevelSystem状态: ", "已加载" if level_system else "未找到")
		
func _on_SaveButton_pressed():
	print("保存游戏请求")
	if level_system != null and level_system.save_game():
		print("游戏保存成功")
	else:
		print("保存失败")

func _on_LoadButton_pressed():
	print("读取存档请求")
	if level_system != null and level_system.has_method("load_game"):
		level_system.load_game()
	else:
		print("存档系统不可用")

func _on_SettingsButton_pressed():
	var settings = load("res://src/scenes/settings.tscn").instantiate()
	add_child(settings)


func _on_save_button_pressed() -> void:
	pass # Replace with function body.


func _on_load_button_pressed() -> void:
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.
