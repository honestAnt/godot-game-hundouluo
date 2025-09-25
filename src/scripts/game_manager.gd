extends Node

# 游戏管理器脚本

# 游戏状态
enum GameState { MENU, PLAYING, PAUSED, GAME_OVER, VICTORY }
var current_state = GameState.MENU

# 玩家数据
var score = 0
var lives = 3
var current_level = 1
var max_level = 5

# 节点引用
@onready var ui_manager = $UIManager
@onready var level_manager = $LevelManager
@onready var audio_manager = $AudioManager
@onready var pause_menu = $PauseMenu
@onready var game_over_screen = $GameOverScreen
@onready var victory_screen = $VictoryScreen

# 信号
signal score_changed(new_score)
signal lives_changed(new_lives)
signal level_changed(new_level)
signal game_state_changed(new_state)
signal player_death

func _ready():
    # 初始化游戏
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED  # 游戏管理器在暂停时仍然运行
    
    # 连接信号
    if level_manager:
        level_manager.level_completed.connect(_on_level_completed)
    
    # 显示主菜单
    show_main_menu()

func _process(delta):
    # 处理暂停输入
    if Input.is_action_just_pressed("pause") and current_state == GameState.PLAYING:
        pause_game()

func start_game():
    # 开始新游戏
    score = 0
    lives = 3
    current_level = 1
    
    # 更新UI
    score_changed.emit(score)
    lives_changed.emit(lives)
    level_changed.emit(current_level)
    
    # 加载第一关
    if level_manager:
        level_manager.load_level(current_level)
    
    # 更新游戏状态
    set_game_state(GameState.PLAYING)
    
    # 播放游戏开始音效
    if audio_manager:
        audio_manager.play_music("game_start")

func pause_game():
    if current_state == GameState.PLAYING:
        get_tree().paused = true
        set_game_state(GameState.PAUSED)
        
        # 显示暂停菜单
        if pause_menu:
            pause_menu.show()
    elif current_state == GameState.PAUSED:
        resume_game()

func resume_game():
    get_tree().paused = false
    set_game_state(GameState.PLAYING)
    
    # 隐藏暂停菜单
    if pause_menu:
        pause_menu.hide()

func game_over():
    set_game_state(GameState.GAME_OVER)
    
    # 显示游戏结束画面
    if game_over_screen:
        game_over_screen.show()
    
    # 播放游戏结束音效
    if audio_manager:
        audio_manager.play_music("game_over")

func victory():
    set_game_state(GameState.VICTORY)
    
    # 显示胜利画面
    if victory_screen:
        victory_screen.show()
    
    # 播放胜利音效
    if audio_manager:
        audio_manager.play_music("victory")

func show_main_menu():
    set_game_state(GameState.MENU)
    
    # 显示主菜单
    if ui_manager:
        ui_manager.show_main_menu()
    
    # 播放菜单音乐
    if audio_manager:
        audio_manager.play_music("menu")

func add_score(points):
    score += points
    score_changed.emit(score)

func on_player_death():
    lives -= 1
    lives_changed.emit(lives)
    
    if lives <= 0:
        game_over()
    else:
        # 重新加载当前关卡
        if level_manager:
            level_manager.reload_current_level()

func _on_level_completed():
    current_level += 1
    level_changed.emit(current_level)
    
    if current_level > max_level:
        # 通关
        victory()
    else:
        # 加载下一关
        if level_manager:
            level_manager.load_level(current_level)

func set_game_state(new_state):
    current_state = new_state
    game_state_changed.emit(new_state)