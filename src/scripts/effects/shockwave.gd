extends Area2D

# 冲击波效果脚本

export var damage = 15
export var knockback_force = 300

func _ready():
    # 连接信号
    connect("body_entered", self, "_on_body_entered")
    $LifeTimer.connect("timeout", self, "_on_lifetime_end")
    
    # 播放动画
    $AnimatedSprite.play()
    
    # 播放音效
    if has_node("/root/AudioManager"):
        get_node("/root/AudioManager").play_sound("shockwave")

func _on_body_entered(body):
    # 检查是否击中玩家
    if body.is_in_group("player"):
        # 造成伤害
        body.take_damage(damage)
        
        # 击退效果
        var knockback_direction = (body.global_position - global_position).normalized()
        body.velocity = knockback_direction * knockback_force

func _on_lifetime_end():
    # 生命周期结束，销毁冲击波
    queue_free()