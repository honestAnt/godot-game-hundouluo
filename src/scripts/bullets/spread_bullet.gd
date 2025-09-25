extends CharacterBody2D

@export var speed := 500.0
@export var damage := 1
@export var direction := Vector2.RIGHT
@export var spread_angle := 15.0

func _physics_process(delta):
    velocity = direction * speed
    move_and_slide()
    
    if not get_viewport_rect().has_point(global_position):
        queue_free()

func _on_body_entered(body):
    if body.is_in_group("enemy"):
        body.take_damage(damage)
    queue_free()