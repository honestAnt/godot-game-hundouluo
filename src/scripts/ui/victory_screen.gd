extends Control

# 胜利画面脚本

# 节点引用
@onready var score_label = $ScoreLabel
@onready var main_menu_button = $MenuContainer/MainMenuButton

# 游戏管理器引用
var game_manager

func _ready():
    # 初始化胜利画面
    game_manager = get_node("/root/GameManager")
    
    # 连接按钮信号
    main_menu_button.pressed.connect(_on_main_menu_button_pressed)
    
    # 更新分数显示
    if game_manager:
        score_label.text = "最终分数: " + str(game_manager.score)

func _on_main_menu_button_pressed():
    # 播放选择音效
    if has_node("/root/AudioManager"):
        get_node("/root/AudioManager").play_sound("menu_select")
    
    # 返回主菜单
    if game_manager:
        game_manager.show_main_menu()