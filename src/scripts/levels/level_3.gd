extends Node2D

signal level_completed

# 关卡配置
var level_name = "基地外围"
var level_difficulty = 3
var boss_enabled = true

# 游戏状态
var player
var dialogue_box
var choice_panel
var current_checkpoint = 0
var enemies_defeated = 0
var secrets_found = 0
var path_chosen = ""

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
    $PathChoice/LeftPath.connect("body_entered", self, "_on_left_path_entered")
    $PathChoice/RightPath.connect("body_entered", self, "_on_right_path_entered")
    $SecretArea.connect("body_entered", self, "_on_secret_area_entered")
    
    # 显示开场对话
    _show_intro_dialogue()
    
    # 生成敌人和道具
    _spawn_enemies()
    _spawn_turrets()
    _spawn_pickups()

func _show_intro_dialogue():
    var intro_dialogue = story_manager.get_dialogue("level3_start")
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
    
    # 当击败一定数量的敌人时触发路径选择
    if enemies_defeated == 5 and path_chosen == "":
        _show_path_choice()
    
    # 当击败所有敌人时触发Boss战
    if enemies_defeated == 15:
        _trigger_boss_battle()

func _show_path_choice():
    # 显示路径选择对话
    var choice_dialogue = story_manager.get_dialogue("level3_choice")
    dialogue_box.show_dialogue(choice_dialogue)
    yield(dialogue_box, "dialogue_finished")
    
    # 显示选择面板
    var choices = ["左边 - 直接突破", "右边 - 迂回路线"]
    choice_panel.show_choices("选择你的路径", choices)

func _on_choice_made(choice_index):
    if choice_index == 0:
        # 选择左路
        path_chosen = "left"
        var left_dialogue = story_manager.get_dialogue("level3_left_path")
        dialogue_box.show_dialogue(left_dialogue)
    else:
        # 选择右路
        path_chosen = "right"
        var right_dialogue = story_manager.get_dialogue("level3_right_path")
        dialogue_box.show_dialogue(right_dialogue)

func _on_left_path_entered(body):
    if body == player and path_chosen == "":
        path_chosen = "left"
        var left_dialogue = story_manager.get_dialogue("level3_left_path")
        dialogue_box.show_dialogue(left_dialogue)

func _on_right_path_entered(body):
    if body == player and path_chosen == "":
        path_chosen = "right"
        var right_dialogue = story_manager.get_dialogue("level3_right_path")
        dialogue_box.show_dialogue(right_dialogue)

func _on_secret_area_entered(body):
    if body == player and secrets_found == 0:
        secrets_found += 1
        
        # 显示秘密区域对话
        var secret_dialogue = story_manager.get_dialogue("level3_secret")
        dialogue_box.show_dialogue(secret_dialogue)
        
        # 记录发现外星技术
        story_manager.record_choice("discover_alien_tech", true)
        
        # 更新UI
        $UI/HUD.update_secrets(secrets_found)

func _trigger_boss_battle():
    # 生成Boss
    var boss = preload("res://src/scenes/boss.tscn").instance()
    boss.position = Vector2(2800, 600)
    add_child(boss)
    boss.connect("defeated", self, "_on_boss_defeated")

func _on_boss_defeated():
    # Boss被击败后，显示结束对话
    var end_dialogue = story_manager.get_dialogue("level3_end")
    dialogue_box.show_dialogue(end_dialogue)
    yield(dialogue_box, "dialogue_finished")
    
    # 推进剧情阶段
    story_manager.advance_story_phase()
    
    # 完成关卡
    emit_signal("level_completed")
    
    # 转到下一关
    # get_tree().change_scene("res://src/scenes/levels/level_4.tscn")

func _on_checkpoint_reached(checkpoint_id):
    current_checkpoint = checkpoint_id
    # 保存游戏状态
    # GameSave.save_checkpoint(level_name, checkpoint_id)