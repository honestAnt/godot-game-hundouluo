extends Node2D

# 获取GameManager单例
@onready var game_manager = get_node("/root/GameManager")

func _ready():
    # 检查是否已经有Player节点
    if not has_node("Player"):
        # 初始化玩家
        var player = preload("res://src/scenes/player.tscn").instantiate()
        player.position = Vector2(100, 300)
        add_child(player)
    
    # 生成敌人
    for i in range(3):
        var enemy = preload("res://src/scenes/enemy.tscn").instantiate()
        enemy.position = Vector2(200 + i * 150, 300)
        add_child(enemy)
    
    # 设置关卡完成信号
    # 使用GameManager而不是LevelSystem
    if game_manager:
        # 如果需要，可以在这里连接信号
        pass

# 关卡完成时调用
func complete_level():
    if game_manager:
        # 通知GameManager关卡已完成
        game_manager.emit_signal("level_completed")