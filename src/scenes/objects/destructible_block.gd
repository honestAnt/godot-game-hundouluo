extends StaticBody2D

# 可破坏方块脚本

export var health = 3
var destroyed = false

func take_damage(amount):
    if destroyed:
        return
    
    health -= amount
    if health <= 0:
        destroy()

func destroy():
    destroyed = true
    $CollisionShape2D.disabled = true
    $AnimatedSprite.play("destroy")
    
    # 播放破坏音效
    if has_node("/root/AudioManager"):
        get_node("/root/AudioManager").play_sound("block_break")
    
    yield($AnimatedSprite, "animation_finished")
    queue_free()