extends Node2D

# 基础关卡脚本

# 信号
signal level_completed

# 节点引用
@onready var player = $Player
@onready var enemy_spawner = $EnemySpawner

func _ready():
	# 初始化关卡
	pass

func _process(delta):
	# 检查关卡是否完成
	if enemy_spawner.get_child_count() == 0:
		emit_signal("level_completed")
