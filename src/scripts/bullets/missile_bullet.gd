extends KinematicBody2D

# 导弹子弹脚本

# 子弹参数
export var speed = 300
export var damage = 20
export var tracking_speed = 3.0  # 追踪速度
export var explosion_radius = 50.0  # 爆炸半径
var direction = Vector2.RIGHT
var target = null

# 节点引用
onready var hit_area = $HitArea
onready var life_timer = $LifeTimer
onready var animated_sprite = $AnimatedSprite
onready var detection_area = $DetectionArea

func _ready():
    # 连接信号
    hit_area.connect("body_entered", self, "_on_hit_body")
    life_timer.connect("timeout", self, "_on_lifetime_end")
    detection_area.connect("body_entered", self, "_on_detection_body_entered")
    detection_area.connect("body_exited", self, "_on_detection_body_exited")
    
    # 启动生命周期计时器
    life_timer.start()
    
    # 设置导弹动画
    animated_sprite.animation = "missile"
    animated_sprite.playing = true

func _physics_process(delta):
    # 如果有目标，则追踪目标
    if target and is_instance_valid(target):
        var target_direction = (target.global_position - global_position).normalized()
        direction = direction.linear_interpolate(target_direction, tracking_speed * delta)
    
    # 移动子弹
    var collision = move_and_collide(direction * speed * delta)
    if collision:
        # 爆炸效果
        explode()

func _on_hit_body(body):
    # 检查碰撞对象
    if body.has_method("take_damage"):
        body.take_damage(damage)
    
    # 爆炸效果
    explode()

func _on_detection_body_entered(body):
    # 检测到敌人，设置为追踪目标
    if body.is_in_group("enemies") and not target:
        target = body

func _on_detection_body_exited(body):
    # 目标离开检测范围
    if body == target:
        target = null

func _on_lifetime_end():
    # 子弹生命周期结束，爆炸
    explode()

func explode():
    # 对爆炸范围内的敌人造成伤害
    var space_state = get_world_2d().direct_space_state
    var results = space_state.intersect_point(global_position, 32, [], 2147483647, true, true)
    
    for result in results:
        var collider = result.collider
        if collider.has_method("take_damage") and collider.global_position.distance_to(global_position) <= explosion_radius:
            # 根据距离计算伤害衰减
            var distance = collider.global_position.distance_to(global_position)
            var damage_factor = 1.0 - (distance / explosion_radius)
            collider.take_damage(damage * damage_factor)
    
    # 创建爆炸效果
    var explosion = load("res://src/scenes/effects/explosion.tscn").instance()
    explosion.global_position = global_position
    get_parent().add_child(explosion)
    
    # 销毁导弹
    queue_free()

func set_damage(value):
    damage = value