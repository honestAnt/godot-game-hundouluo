extends Node2D

func _ready():
    # 初始化玩家
    var player = preload("res://src/scenes/player.tscn").instantiate()
    add_child(player)
    
    # 生成敌人
    for i in range(3):
        var enemy = preload("res://src/scenes/enemies/enemy_basic.tscn").instantiate()
        enemy.position = Vector2(randi_range(200, 600), 300)
        add_child(enemy)
    
    # 连接关卡完成信号
    LevelSystem.connect("level_completed", _on_level_completed)

func _on_level_completed():
    LevelSystem.next_level()