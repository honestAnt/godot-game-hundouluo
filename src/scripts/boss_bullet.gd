extends Area2D

var speed = 300
var direction = Vector2.RIGHT
var damage = 2

func _ready():
    connect("body_entered", self, "_on_body_entered")
    
func _physics_process(delta):
    position += direction * speed * delta
    
func _on_body_entered(body):
    if body.is_in_group("player"):
        body.take_damage(damage)
    queue_free()