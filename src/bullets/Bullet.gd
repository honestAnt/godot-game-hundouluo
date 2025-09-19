extends KinematicBody2D

export var speed := 300.0
export var damage := 10
var direction := Vector2.RIGHT

func _physics_process(delta):
    var collision = move_and_collide(direction * speed * delta)
    if collision:
        if collision.collider.has_method("take_damage"):
            collision.collider.take_damage(damage)
        queue_free()

func set_direction(new_dir: Vector2):
    direction = new_dir.normalized()
    rotation = direction.angle()