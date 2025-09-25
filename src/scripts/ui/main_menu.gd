extends Control

# 主菜单脚本

# 节点引用
@onready var start_button = $MenuContainer/StartButton
@onready var options_button = $MenuContainer/OptionsButton
@onready var quit_button = $MenuContainer/QuitButton

# 游戏管理器引用
var game_manager

func _ready():
	# 初始化主菜单
	game_manager = get_node("/root/GameManager")
	
	# 连接按钮信号
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _on_start_button_pressed():
	# 播放选择音效
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sound("menu_select")
	
	# 开始游戏
	if game_manager:
		game_manager.start_game()

func _on_options_button_pressed():
	# 播放选择音效
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sound("menu_select")
	
	# 显示选项菜单
	# TODO: 实现选项菜单

func _on_quit_button_pressed():
	# 播放选择音效
	if has_node("/root/AudioManager"):
		get_node("/root/AudioManager").play_sound("menu_select")
	
	# 退出游戏
	get_tree().quit()
