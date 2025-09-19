extends Node2D

signal level_completed

# 关卡配置
var level_name = "瀑布攀爬"
var level_difficulty = 2
var boss_enabled = true

# 剧情对话
var intro_dialogue = [
    "我们必须沿着瀑布向上攀爬，才能到达敌人的基地。",
    "情报显示这里有敌人的巡逻队，小心行动。",
    "瀑布顶端有一个隐藏的入口，那里守卫着一个精英敌人。"
]

var mid_dialogue = [
    "这些敌人似乎在保护什么重要的东西...",
    "继续向上，我们快到达瀑布顶端了。"
]

var boss_dialogue = [
    "警告：检测到强大的敌人信号！",
    "这是他们的水域守卫者，击败它才能继续前进！"
]

# 游戏状态
var player
var dialogue_box
var current_checkpoint = 0
var enemies_defeated = 0
var secrets_found = 0

func _ready():
    # 初始化玩家引用
    player = $Player
    dialogue_box = $UI/DialogueBox
    
    # 设置关卡边界
    $Player/Camera2D.limit_right = 3000
    
    # 连接信号
    dialogue_box.connect("dialogue_finished", self, "_on_dialogue_finished")
    
    # 显示开场对话
    _show_intro_dialogue()
    
    # 生成敌人和道具
    _spawn_enemies()
    _spawn_pickups()

func _show_intro_dialogue():
    dialogue_box.show_dialogue(intro_dialogue)

func _on_dialogue_finished():
    # 对话结束后开始游戏
    if dialogue_box.visible:
        dialogue_box.visible = false

func _spawn_enemies():
    # 生成第一波敌人
    var enemy_positions = [
        Vector2(500, 600),
        Vector2(800, 550),
        Vector2(1200, 500),
        Vector2(1600, 450),
        Vector2(2000, 400)
    ]
    
    for pos in enemy_positions:
        var enemy = preload("res://src/scenes/enemy.tscn").instance()
        enemy.position = pos
        $Enemies.add_child(enemy)
        enemy.connect("defeated", self, "_on_enemy_defeated")

func _spawn_pickups():
    # 生成武器和生命道具
    var pickup_positions = [
        Vector2(700, 600),  # 散弹枪
        Vector2(1500, 450), # 激光枪
        Vector2(2200, 350)  # 额外生命
    ]
    
    var pickup_types = ["S", "L", "1UP"]
    
    for i in range(pickup_positions.size()):
        var pickup = preload("res://src/scenes/weapon_pickup.tscn").instance()
        pickup.position = pickup_positions[i]
        pickup.pickup_type = pickup_types[i]
        $Pickups.add_child(pickup)

func _on_enemy_defeated():
    enemies_defeated += 1
    
    # 当击败一定数量的敌人时触发中期对话
    if enemies_defeated == 5:
        dialogue_box.show_dialogue(mid_dialogue)
    
    # 当击败所有敌人时触发Boss战
    if enemies_defeated == 10:
        _trigger_boss_battle()

func _trigger_boss_battle():
    dialogue_box.show_dialogue(boss_dialogue)
    yield(dialogue_box, "dialogue_finished")
    
    # 生成Boss
    var boss = preload("res://src/scenes/boss.tscn").instance()
    boss.position = Vector2(2500, 400)
    add_child(boss)
    boss.connect("defeated", self, "_on_boss_defeated")

func _on_boss_defeated():
    # Boss被击败后，完成关卡
    yield(get_tree().create_timer(2.0), "timeout")
    emit_signal("level_completed")
    
    # 转到下一关
    # get_tree().change_scene("res://src/scenes/levels/level_3.tscn")

func _on_checkpoint_reached(checkpoint_id):
    current_checkpoint = checkpoint_id
    # 保存游戏状态
    # GameSave.save_checkpoint(level_name, checkpoint_id)

func _on_secret_found():
    secrets_found += 1
    # 更新UI显示
    # $UI/HUD.update_secrets(secrets_found)