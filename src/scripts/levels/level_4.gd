extends Node2D

signal level_completed

# 关卡配置
var level_name = "基地内部"
var level_difficulty = 4
var boss_enabled = true

# 游戏状态
var player
var dialogue_box
var choice_panel
var current_checkpoint = 0
var enemies_defeated = 0
var hostages_saved = false
var weapons_destroyed = false

# 故事管理器引用
onready var story_manager = get_node("/root/StoryManager")

func _ready():
    # 初始化引用
    player = $Player
    dialogue_box = $UI/DialogueBox
    choice_panel = $UI/ChoicePanel
    
    # 连接信号
    dialogue_box.connect("dialogue_finished", self, "_on_dialogue_finished")
    choice_panel.connect("choice_made", self, "_on_choice_made")
    $HostageArea.connect("body_entered", self, "_on_hostage_area_entered")
    $WeaponCacheArea.connect("body_entered", self, "_on_weapon_cache_area_entered")
    $ControlRoomArea.connect("body_entered", self, "_on_control_room_area_entered")
    
    # 显示开场对话
    _show_intro_dialogue()
    
    # 生成敌人和道具
    _spawn_enemies()
    _spawn_turrets()
    _spawn_pickups()

func _show_intro_dialogue():
    var intro_dialogue = story_manager.get_dialogue("level4_start")
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
        Vector2(1200, 600),
        Vector2(1500, 600),
        Vector2(1800, 600),
        Vector2(2200, 600),
        Vector2(2500, 600)
    ]
    
    for pos in enemy_positions:
        var enemy = preload("res://src/scenes/enemy.tscn").instance()
        enemy.position = pos
        enemy.health = 30  # 更高的生命值
        enemy.speed = 120  # 更快的速度
        $Enemies.add_child(enemy)
        enemy.connect("defeated", self, "_on_enemy_defeated")

func _spawn_turrets():
    # 生成自动炮塔
    var turret_positions = [
        Vector2(600, 500),
        Vector2(1300, 500),
        Vector2(2000, 500),
        Vector2(2700, 500)
    ]
    
    for pos in turret_positions:
        var turret = preload("res://src/scenes/turret.tscn").instance()
        turret.position = pos
        turret.fire_rate = 1.5  # 更快的射击速度
        $Turrets.add_child(turret)
        turret.connect("defeated", self, "_on_enemy_defeated")

func _spawn_pickups():
    # 生成武器和生命道具
    var pickup_positions = [
        Vector2(500, 600),  # 散弹枪
        Vector2(1400, 600), # 激光枪
        Vector2(2300, 600)  # 额外生命
    ]
    
    var pickup_types = ["S", "L", "1UP"]
    
    for i in range(pickup_positions.size()):
        var pickup = preload("res://src/scenes/weapon_pickup.tscn").instance()
        pickup.position = pickup_positions[i]
        pickup.pickup_type = pickup_types[i]
        $Pickups.add_child(pickup)

func _on_enemy_defeated():
    enemies_defeated += 1
    
    # 当击败一定数量的敌人时触发Boss战
    if enemies_defeated == 15:
        _trigger_boss_battle()

func _on_hostage_area_entered(body):
    if body == player and not hostages_saved:
        # 显示人质对话
        var hostage_dialogue = story_manager.get_dialogue("level4_hostages")
        dialogue_box.show_dialogue(hostage_dialogue)
        yield(dialogue_box, "dialogue_finished")
        
        # 显示选择面板
        var choices = ["救出人质 (可能触发警报)", "继续前进 (保持隐蔽)"]
        choice_panel.show_choices("你要怎么做？", choices)
        
        # 等待选择
        var choice_index = yield(choice_panel, "choice_made")
        
        if choice_index == 0:
            # 选择救出人质
            hostages_saved = true
            story_manager.record_choice("save_hostages", true)
            
            # 触发警报，生成额外敌人
            _spawn_alarm_enemies()
        else:
            # 选择继续前进
            pass

func _on_weapon_cache_area_entered(body):
    if body == player and not weapons_destroyed:
        # 显示武器库对话
        var weapon_cache_dialogue = story_manager.get_dialogue("level4_weapon_cache")
        dialogue_box.show_dialogue(weapon_cache_dialogue)
        yield(dialogue_box, "dialogue_finished")
        
        # 显示选择面板
        var choices = ["摧毁武器库 (可能触发警报)", "继续前进 (保持隐蔽)"]
        choice_panel.show_choices("你要怎么做？", choices)
        
        # 等待选择
        var choice_index = yield(choice_panel, "choice_made")
        
        if choice_index == 0:
            # 选择摧毁武器库
            weapons_destroyed = true
            story_manager.record_choice("destroy_weapons", true)
            
            # 触发警报，生成额外敌人
            _spawn_alarm_enemies()
        else:
            # 选择继续前进
            pass

func _spawn_alarm_enemies():
    # 触发警报，生成额外敌人
    var alarm_enemy_positions = [
        Vector2(player.position.x + 300, 600),
        Vector2(player.position.x - 300, 600),
        Vector2(player.position.x + 200, 600)
    ]
    
    for pos in alarm_enemy_positions:
        var enemy = preload("res://src/scenes/enemy.tscn").instance()
        enemy.position = pos
        enemy.health = 40  # 更高的生命值
        enemy.speed = 150  # 更快的速度
        $Enemies.add_child(enemy)
        enemy.connect("defeated", self, "_on_enemy_defeated")

func _on_control_room_area_entered(body):
    if body == player:
        # 显示控制室对话
        var control_room_dialogue = story_manager.get_dialogue("level4_end")
        dialogue_box.show_dialogue(control_room_dialogue)
        yield(dialogue_box, "dialogue_finished")
        
        # 推进剧情阶段
        story_manager.advance_story_phase()
        
        # 完成关卡
        emit_signal("level_completed")
        
        # 转到下一关
        # get_tree().change_scene("res://src/scenes/levels/level_5.tscn")

func _trigger_boss_battle():
    # 显示Boss对话
    var boss_dialogue = story_manager.get_dialogue("level4_boss")
    dialogue_box.show_dialogue(boss_dialogue)
    yield(dialogue_box, "dialogue_finished")
    
    # 生成Boss
    var boss = preload("res://src/scenes/boss.tscn").instance()
    boss.position = Vector2(2000, 600)
    boss.boss_type = "bio_soldier"  # 生化战士类型
    add_child(boss)
    boss.connect("defeated", self, "_on_boss_defeated")

func _on_boss_defeated():
    # Boss被击败后继续游戏
    pass

func _on_checkpoint_reached(checkpoint_id):
    current_checkpoint = checkpoint_id
    # 保存游戏状态
    # GameSave.save_checkpoint(level_name, checkpoint_id)