extends CharacterBody2D

@export var speed := 800.0
@export var damage := 2
@export var direction := Vector2.RIGHT
@export var max_pierce := 3
var pierced_enemies = []

func _physics_process(delta):
    velocity = direction * speed
    move_and_slide()
    
    if not get_viewport_rect().has_point(global_position):
        queue_free()

func _on_body_entered(body):
    if body.is_in_group("enemy") and not body in pierced_enemies:
        body.take_damage(damage)
        pierced_enemies.append(body)
        if pierced_enemies.size() >= max_pierce:
            queue_free()