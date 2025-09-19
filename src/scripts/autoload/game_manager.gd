extends Node

# 游戏管理器
# 负责管理游戏的全局状态、关卡加载和游戏进度

# 游戏状态
enum GAME_STATE {
    MAIN_MENU,
    PLAYING,
    PAUSED,
    GAME_OVER,
    VICTORY
}

# 当前游戏状态
var current_state = GAME_STATE.MAIN_MENU

# 玩家数据
var player_lives = 3
var player_score = 0
var current_weapon = "普通枪"
var collected_secrets = 0

# 关卡数据
var current_level = 1
var max_level = 5
var level_scenes = {
    1: "res://src/scenes/levels/level_1.tscn",
    2: "res://src/scenes/levels/level_2.tscn",
    3: "res://src/scenes/levels/level_3.tscn",
    4: "res://src/scenes/levels/level_4.tscn",
    5: "res://src/scenes/levels/level_5.tscn"
}

# 游戏设置
var music_volume = 1.0
var sfx_volume = 1.0
var fullscreen = false

# 信号
signal game_state_changed(new_state)
signal player_death
signal level_completed
signal game_over
signal game_victory

func _ready():
    # 初始化游戏
    process_mode = Node.PROCESS_MODE_WHEN_PAUSED  # 允许在暂停时继续处理
    
    # 加载游戏设置
    _load_settings()

# 开始新游戏
func start_new_game():
    # 重置玩家数据
    player_lives = 3
    player_score = 0
    current_weapon = "普通枪"
    collected_secrets = 0
    current_level = 1
    
    # 加载第一关
    load_level(current_level)
    
    # 更新游戏状态
    change_game_state(GAME_STATE.PLAYING)

# 加载指定关卡
func load_level(level_number):
    if level_scenes.has(level_number):
        # 更新当前关卡
        current_level = level_number
        
        # 加载关卡场景
        get_tree().change_scene(level_scenes[level_number])
        
        # 连接关卡信号
        var level_node = get_tree().current_scene
        if level_node.has_signal("level_completed"):
            if not level_node.level_completed.is_connected(_on_level_completed):
                level_node.level_completed.connect(_on_level_completed)
    else:
        print("错误：关卡 %d 不存在" % level_number)

# 关卡完成处理
func _on_level_completed():
    if current_level < max_level:
        # 加载下一关
        load_level(current_level + 1)
    else:
        # 游戏胜利
        change_game_state(GAME_STATE.VICTORY)
        emit_signal("game_victory")

# 玩家死亡处理
func on_player_death():
    player_lives -= 1
    emit_signal("player_death")
    
    if player_lives <= 0:
        # 游戏结束
        change_game_state(GAME_STATE.GAME_OVER)
        emit_signal("game_over")
    else:
        # 重新加载当前关卡
        load_level(current_level)

# 更新游戏状态
func change_game_state(new_state):
    current_state = new_state
    
    match new_state:
        GAME_STATE.PAUSED:
            get_tree().paused = true
        GAME_STATE.PLAYING:
            get_tree().paused = false
        GAME_STATE.GAME_OVER:
            get_tree().paused = false
        GAME_STATE.VICTORY:
            get_tree().paused = false
        GAME_STATE.MAIN_MENU:
            get_tree().paused = false
    
    emit_signal("game_state_changed", new_state)

# 暂停/继续游戏
func toggle_pause():
    if current_state == GAME_STATE.PLAYING:
        change_game_state(GAME_STATE.PAUSED)
    elif current_state == GAME_STATE.PAUSED:
        change_game_state(GAME_STATE.PLAYING)

# 返回主菜单
func return_to_main_menu():
    change_game_state(GAME_STATE.MAIN_MENU)
    get_tree().change_scene("res://src/scenes/ui/main_menu.tscn")

# 退出游戏
func quit_game():
    # 保存游戏设置
    _save_settings()
    
    # 退出游戏
    get_tree().quit()

# 加载游戏设置
func _load_settings():
    var config = ConfigFile.new()
    var err = config.load("user://settings.cfg")
    
    if err == OK:
        # 加载音频设置
        music_volume = config.get_value("audio", "music_volume", 1.0)
        sfx_volume = config.get_value("audio", "sfx_volume", 1.0)
        
        # 加载显示设置
        fullscreen = config.get_value("video", "fullscreen", false)
        
        # 应用设置
        _apply_settings()
    else:
        # 使用默认设置
        _save_settings()

# 保存游戏设置
func _save_settings():
    var config = ConfigFile.new()
    
    # 保存音频设置
    config.set_value("audio", "music_volume", music_volume)
    config.set_value("audio", "sfx_volume", sfx_volume)
    
    # 保存显示设置
    config.set_value("video", "fullscreen", fullscreen)
    
    # 保存配置文件
    config.save("user://settings.cfg")

# 应用游戏设置
func _apply_settings():
    # 应用音频设置
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_volume))
    AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(sfx_volume))
    
    # 应用显示设置
    if fullscreen:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
    else:
        DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# 更新分数
func add_score(points):
    player_score += points

# 更新收集的秘密
func add_secret():
    collected_secrets += 1

# 输入处理
func _input(event):
    # 按ESC键暂停/继续游戏
    if event is InputEventKey and event.pressed:
        if event.scancode == KEY_ESCAPE and (current_state == GAME_STATE.PLAYING or current_state == GAME_STATE.PAUSED):
            toggle_pause()