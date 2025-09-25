extends CharacterBody2D

@export var speed := 300.0
@export var damage := 1
@export var direction := Vector2.RIGHT
@export var burn_duration := 2.0
@export var burn_dps := 0.5

func _physics_process(delta):
    velocity = direction * speed
    move_and_slide()
    
    if not get_viewport_rect().has_point(global_position):
        queue_free()

func _on_body_entered(body):
    if body.is_in_group("enemy"):
        body.take_damage(damage)
        # 应用燃烧效果
        if body.has_method("apply_burn"):
            body.apply_burn(burn_duration, burn_dps)
    queue_free()