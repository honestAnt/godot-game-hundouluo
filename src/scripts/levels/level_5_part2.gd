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