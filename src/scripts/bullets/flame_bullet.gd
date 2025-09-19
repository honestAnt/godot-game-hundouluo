extends KinematicBody2D

# 火焰子弹脚本

# 子弹参数
export var speed = 250
export var damage = 5  # 每帧伤害
export var damage_interval = 0.2  # 伤害间隔
var direction = Vector2.RIGHT
var hit_targets = {}  # 记录已经击中的目标和上次伤害时间

# 节点引用
onready var hit_area = $HitArea
onready var life_timer = $LifeTimer
onready var animated_sprite = $AnimatedSprite
onready var damage_timer = $DamageTimer

func _ready():
    # 连接信号
    hit_area.connect("body_entered", self, "_on_hit_body")
    hit_area.connect("body_exited", self, "_on_body_exit")
    life_timer.connect("timeout", self, "_on_lifetime_end")
    damage_timer.connect("timeout", self, "_on_damage_tick")
    
    # 启动生命周期计时器
    life_timer.start()
    damage_timer.start(damage_interval)
    
    # 设置火焰动画
    animated_sprite.animation = "flame"
    animated_sprite.playing = true

func _physics_process(delta):
    # 移动子弹
    var collision = move_and_collide(direction * speed * delta)
    if collision:
        # 火焰碰到墙壁会停止移动，但不会立即消失
        speed = 0

func _on_hit_body(body):
    # 检查碰撞对象
    if body.has_method("take_damage"):
        # 记录目标
        hit_targets[body] = OS.get_ticks_msec()
        body.take_damage(damage)

func _on_body_exit(body):
    # 移除目标记录
    if hit_targets.has(body):
        hit_targets.erase(body)

func _on_damage_tick():
    # 对范围内的目标造成持续伤害
    var current_time = OS.get_ticks_msec()
    for body in hit_targets.keys():
        if current_time - hit_targets[body] >= damage_interval * 1000:
            body.take_damage(damage)
            hit_targets[body] = current_time

func _on_lifetime_end():
    # 子弹生命周期结束，销毁子弹
    queue_free()

func set_damage(value):
    damage = value