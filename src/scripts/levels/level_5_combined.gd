extends Node2D

signal level_completed

# 关卡配置
var level_name = "主实验室"
var level_difficulty = 5
var boss_enabled = true

# 游戏状态
var player
var dialogue_box
var choice_panel
var current_checkpoint = 0
var boss_defeated = false
var escape_sequence_started = false
var secret_ending_available = false

# 故事管理器引用
onready var story_manager = get_node("/root/StoryManager")
onready var self_destruct_timer = $SelfDestructTimer

func _ready():
    # 初始化引用
    player = $Player
    dialogue_box = $UI/DialogueBox
    choice_panel = $UI/ChoicePanel
    
    # 连接信号
    dialogue_box.connect("dialogue_finished", self, "_on_dialogue_finished")
    choice_panel.connect("choice_made", self, "_on_choice_made")
    $BossArea.connect("body_entered", self, "_on_boss_area_entered")
    $EscapeArea.connect("body_entered", self, "_on_escape_area_entered")
    $SecretPortalArea.connect("body_entered", self, "_on_secret_portal_area_entered")
    self_destruct_timer.connect("timeout", self, "_on_self_destruct_timeout")
    
    # 显示开场对话
    _show_intro_dialogue()
    
    # 检查是否可以触发秘密结局
    secret_ending_available = story_manager.discovered_alien_tech and story_manager.saved_hostages
    
    # 生成敌人和道具
    _spawn_enemies()
    _spawn_turrets()
    _spawn_pickups()

func _show_intro_dialogue():
    var intro_dialogue = story_manager.get_dialogue("level5_start")
    dialogue_box.show_dialogue(intro_dialogue)

func _on_dialogue_finished():
    # 对话结束后开始游戏
    if dialogue_box.visible:
        dialogue_box.visible = false

func _spawn_enemies():
    # 生成敌人
    var enemy_positions = [
        Vector2(400, 600),
        Vector2(700, 600),
        Vector2(1000, 600),
        Vector2(1300, 600)
    ]
    
    for pos in enemy_positions:
        var enemy = preload("res://src/scenes/enemy.tscn").instance()
        enemy.position = pos
        enemy.health = 50  # 更高的生命值
        enemy.speed = 150  # 更快的速度
        $Enemies.add_child(enemy)

func _spawn_turrets():
    # 生成自动炮塔
    var turret_positions = [
        Vector2(500, 500),
        Vector2(900, 500),
        Vector2(1300, 500)
    ]
    
    for pos in turret_positions:
        var turret = preload("res://src/scenes/turret.tscn").instance()
        turret.position = pos
        turret.fire_rate = 1.0  # 更快的射击速度
        $Turrets.add_child(turret)

func _spawn_pickups():
    # 生成武器和生命道具
    var pickup_positions = [
        Vector2(600, 600),  # 散弹枪
        Vector2(1200, 600), # 激光枪
        Vector2(800, 600)   # 额外生命
    ]
    
    var pickup_types = ["S", "L", "1UP"]
    
    for i in range(pickup_positions.size()):
        var pickup = preload("res://src/scenes/weapon_pickup.tscn").instance()
        pickup.position = pickup_positions[i]
        pickup.pickup_type = pickup_types[i]
        $Pickups.add_child(pickup)

func _on_boss_area_entered(body):
    if body == player and not boss_defeated:
        # 显示Boss对话
        var boss_intro_dialogue = story_manager.get_dialogue("level5_boss_intro")
        dialogue_box.show_dialogue(boss_intro_dialogue)
        yield(dialogue_box, "dialogue_finished")
        
        # 生成最终Boss
        var boss = preload("res://src/scenes/boss.tscn").instance()
        boss.position = Vector2(1500, 600)
        boss.boss_type = "alien_leader"  # 外星领袖类型
        boss.health = 200  # 更高的生命值
        add_child(boss)
        boss.connect("health_changed", self, "_on_boss_health_changed")
        boss.connect("defeated", self, "_on_boss_defeated")

func _on_boss_health_changed(current_health, max_health):
    # 当Boss生命值降至一半时触发对话
    if current_health <= max_health / 2 and not boss_defeated:
        var boss_mid_dialogue = story_manager.get_dialogue("level5_boss_mid")
        dialogue_box.show_dialogue(boss_mid_dialogue)

func _on_boss_defeated():
    boss_defeated = true
    
    # 显示Boss被击败对话
    var boss_end_dialogue = story_manager.get_dialogue("level5_boss_end")
    dialogue_box.show_dialogue(boss_end_dialogue)
    yield(dialogue_box, "dialogue_finished")
    
    # 开始自毁序列
    _start_self_destruct_sequence()

func _start_self_destruct_sequence():
    escape_sequence_started = true
    
    # 显示逃脱对话
    var escape_dialogue = story_manager.get_dialogue("ending_escape")
    dialogue_box.show_dialogue(escape_dialogue)
    yield(dialogue_box, "dialogue_finished")
    
    # 启动自毁计时器
    self_destruct_timer.start()
    
    # 如果玩家发现了秘密，显示秘密传送门
    if secret_ending_available:
        $SecretPortalArea/CollisionShape2D.disabled = false
    else:
        $SecretPortalArea/CollisionShape2D.disabled = true

func _on_escape_area_entered(body):
    if body == player and escape_sequence_started:
        # 停止自毁计时器
        self_destruct_timer.stop()
        
        # 显示标准结局对话
        var ending_dialogue = story_manager.get_dialogue("ending_good")
        dialogue_box.show_dialogue(ending_dialogue)
        yield(dialogue_box, "dialogue_finished")
        
        # 推进剧情阶段
        story_manager.advance_story_phase()
        
        # 完成关卡
        emit_signal("level_completed")
        
        # 转到结束画面
        # get_tree().change_scene("res://src/scenes/ui/credits.tscn")

func _on_secret_portal_area_entered(body):
    if body == player and escape_sequence_started and secret_ending_available:
        # 停止自毁计时器
        self_destruct_timer.stop()
        
        # 显示秘密结局对话
        var secret_ending_dialogue = story_manager.get_dialogue("ending_secret")
        dialogue_box.show_dialogue(secret_ending_dialogue)
        yield(dialogue_box, "dialogue_finished")
        
        # 推进剧情阶段
        story_manager.advance_story_phase()
        
        # 完成关卡
        emit_signal("level_completed")
        
        # 转到秘密结局画面
        # get_tree().change_scene("res://src/scenes/ui/secret_ending.tscn")

func _on_self_destruct_timeout():
    # 自毁计时器超时，玩家未能逃脱
    # 游戏结束
    # get_tree().change_scene("res://src/scenes/ui/game_over.tscn")
    pass

func _on_choice_made(choice_index):
    # 处理选择结果
    pass

func _on_checkpoint_reached(checkpoint_id):
    current_checkpoint = checkpoint_id
    # 保存游戏状态
    # GameSave.save_checkpoint(level_name, checkpoint_id)

func _process(delta):
    # 如果自毁序列已启动，更新UI显示剩余时间
    if escape_sequence_started and self_destruct_timer.time_left > 0:
        var time_left = int(self_destruct_timer.time_left)
        $UI/HUD.update_timer(time_left)