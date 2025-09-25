extends Control

# 暂停菜单脚本

# 节点引用
@onready var resume_button = $MenuContainer/ResumeButton
@onready var options_button = $MenuContainer/OptionsButton
@onready var main_menu_button = $MenuContainer/MainMenuButton

# 游戏管理器引用
var game_manager

func _ready():
    # 初始化暂停菜单
    game_manager = get_node("/root/GameManager")
    
    # 连接按钮信号
    resume_button.pressed.connect(_on_resume_button_pressed)
    options_button.pressed.connect(_on_options_button_pressed)
    main_menu_button.pressed.connect(_on_main_menu_button_pressed)

func _on_resume_button_pressed():
    # 播放选择音效
    if has_node("/root/AudioManager"):
        get_node("/root/AudioManager").play_sound("menu_select")
    
    # 继续游戏
    if game_manager:
        game_manager.resume_game()

func _on_options_button_pressed():
    # 播放选择音效
    if has_node("/root/AudioManager"):
        get_node("/root/AudioManager").play_sound("menu_select")
    
    # 显示选项菜单
    # TODO: 实现选项菜单

func _on_main_menu_button_pressed():
    # 播放选择音效
    if has_node("/root/AudioManager"):
        get_node("/root/AudioManager").play_sound("menu_select")
    
    # 返回主菜单
    if game_manager:
        game_manager.show_main_menu()
        
        # 取消暂停游戏
        get_tree().paused = false