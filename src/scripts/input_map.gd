extends Node

# 这个脚本用于设置输入映射

func _ready():
	# 确保射击按键映射正确
	if not InputMap.has_action("shoot"):
		InputMap.add_action("shoot")
		var event = InputEventKey.new()
		event.keycode = KEY_CONTROL
		InputMap.action_add_event("shoot", event)
	
	# 确保切换武器按键映射正确
	if not InputMap.has_action("switch_weapon"):
		InputMap.add_action("switch_weapon")
		var event = InputEventKey.new()
		event.keycode = KEY_TAB
		InputMap.action_add_event("switch_weapon", event)