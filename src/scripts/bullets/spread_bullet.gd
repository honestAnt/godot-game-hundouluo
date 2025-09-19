extends KinematicBody2D

# 散弹枪子弹脚本

# 子弹参数
export var speed = 350
export var damage = 8  # 每颗散弹伤害较低
var direction = Vector2.RIGHT

# 节点引用
onready var hit_area = $HitArea
onready var life_timer = $LifeTimer
onready var animated_sprite = $AnimatedSprite

func _ready():
    # 连接信号
    hit_area.connect("body_entered", self, "_on_hit_body")
    life_timer.connect("timeout", self, "_on_lifetime_end")
    
    # 启动生命周期计时器
    life_timer.start()
    
    # 设置散弹动画
    animated_sprite.animation = "shotgun"
    animated_sprite.playing = true

func _physics_process(delta):
    # 移动子弹
    var collision = move_and_collide(direction * speed * delta)
    if collision:
        # 检查碰撞对象
        if collision.collider.has_method("take_damage"):
            collision.collider.take_damage(damage)
        
        # 销毁子弹
        queue_free()

func _on_hit_body(body):
    # 检查碰撞对象
    if body.has_method("take_damage"):
        body.take_damage(damage)
    
    # 销毁子弹
    queue_free()

func _on_lifetime_end():
    # 子弹生命周期结束，销毁子弹
    queue_free()

func set_damage(value):
    damage = value