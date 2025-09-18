extends Area2D

var speed = 1000
var damage = 2
var direction = 1

func _physics_process(delta):
    position.x += speed * direction * delta

func _on_LifeTimer_timeout():
    queue_free()

func _on_Laser_body_entered(body):
    if body.has_method("take_damage"):
        body.take_damage(damage)
    queue_free()