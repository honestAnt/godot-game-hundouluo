extends CharacterBody2D

@export var speed := 200.0
@export var damage := 3
@export var direction := Vector2.RIGHT
@export var turn_rate := 2.0
@export var explosion_radius := 64.0
var target = null

func _ready():
    # 寻找最近的敌人作为目标
    var enemies = get_tree().get_nodes_in_group("enemies")
    if enemies.size() > 0:
        target = enemies[0]
        for enemy in enemies:
            if global_position.distance_to(enemy.global_position) < global_position.distance_to(target.global_position):
                target = enemy

func _physics_process(delta):
    if target and is_instance_valid(target):
        # 计算转向
        var desired_direction = (target.global_position - global_position).normalized()
        direction = direction.lerp(desired_direction, turn_rate * delta).normalized()
    
    velocity = direction * speed
    move_and_slide()
    
    if not get_viewport_rect().has_point(global_position):
        queue_free()

func _on_body_entered(body):
    if body.is_in_group("enemy"):
        explode()
    queue_free()

func _on_area_entered(area):
    explode()

func explode():
    # 创建爆炸效果
    var explosion = preload("res://src/scenes/effects/explosion.tscn").instantiate()
    explosion.global_position = global_position
    explosion.damage = damage
    explosion.radius = explosion_radius
    get_parent().add_child(explosion)
    queue_free()