extends CanvasLayer

# UI管理器脚本

# 节点引用
@onready var main_menu = $MainMenu
@onready var hud = $HUD
@onready var pause_menu = $PauseMenu
@onready var game_over_screen = $GameOverScreen
@onready var victory_screen = $VictoryScreen
@onready var level_transition = $LevelTransition

# 游戏管理器引用
var game_manager

func _ready():
    # 初始化UI管理器
    game_manager = get_node("/root/GameManager")
    
    # 连接信号
    if game_manager:
        game_manager.score_changed.connect(_on_score_changed)
        game_manager.lives_changed.connect(_on_lives_changed)
        game_manager.level_changed.connect(_on_level_changed)
        game_manager.game_state_changed.connect(_on_game_state_changed)
    
    # 初始隐藏所有UI
    hide_all_ui()

func show_main_menu():
    hide_all_ui()
    main_menu.show()

func show_hud():
    hud.show()

func show_pause_menu():
    pause_menu.show()

func show_game_over_screen():
    game_over_screen.show()

func show_victory_screen():
    victory_screen.show()

func show_level_transition(level_number):
    level_transition.set_level(level_number)
    level_transition.show()
    
    # 播放过渡动画
    level_transition.play_transition()

func hide_all_ui():
    main_menu.hide()
    hud.hide()
    pause_menu.hide()
    game_over_screen.hide()
    victory_screen.hide()
    level_transition.hide()

func _on_score_changed(new_score):
    hud.update_score(new_score)

func _on_lives_changed(new_lives):
    hud.update_lives(new_lives)

func _on_level_changed(new_level):
    hud.update_level(new_level)
    show_level_transition(new_level)

func _on_game_state_changed(new_state):
    match new_state:
        game_manager.GameState.MENU:
            show_main_menu()
        game_manager.GameState.PLAYING:
            hide_all_ui()
            show_hud()
        game_manager.GameState.PAUSED:
            show_pause_menu()
        game_manager.GameState.GAME_OVER:
            show_game_over_screen()
        game_manager.GameState.VICTORY:
            show_victory_screen()