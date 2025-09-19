extends KinematicBody2D

# 激光子弹脚本

# 子弹参数
export var speed = 600
export var damage = 15
export var penetration = true  # 激光可以穿透敌人
var direction = Vector2.RIGHT
var hit_targets = []  # 记录已经击中的目标，避免重复伤害

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
    
    # 设置激光动画
    animated_sprite.animation = "laser"
    animated_sprite.playing = true

func _physics_process(delta):
    # 移动子弹
    var collision = move_and_collide(direction * speed * delta)
    if collision:
        # 检查碰撞对象
        if collision.collider.has_method("take_damage") and not hit_targets.has(collision.collider):
            collision.collider.take_damage(damage)
            hit_targets.append(collision.collider)
        
        # 如果不能穿透，则销毁子弹
        if not penetration:
            queue_free()

func _on_hit_body(body):
    # 检查碰撞对象
    if body.has_method("take_damage") and not hit_targets.has(body):
        body.take_damage(damage)
        hit_targets.append(body)
    
    # 如果不能穿透，则销毁子弹
    if not penetration:
        queue_free()

func _on_lifetime_end():
    # 子弹生命周期结束，销毁子弹
    queue_free()

func set_damage(value):
    damage = value