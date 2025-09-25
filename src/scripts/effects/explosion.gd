extends Area2D

@export var damage := 2
@export var radius := 64.0

func _ready():
    # 设置碰撞形状大小
    $CollisionShape2D.shape.radius = radius
    
    # 播放爆炸动画
    $AnimationPlayer.play("explode")
    
    # 检测范围内的敌人
    for body in get_overlapping_bodies():
        if body.is_in_group("enemy"):
            body.take_damage(damage)
    
    # 1秒后自动移除
    await get_tree().create_timer(1.0).timeout
    queue_free()