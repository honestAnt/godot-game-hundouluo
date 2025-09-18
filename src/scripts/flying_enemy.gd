extends KinematicBody2D

var health = 2
var speed = 80
var direction = Vector2(-1, 0)
var gravity = 0
var velocity = Vector2.ZERO

func _physics_process(delta):
    velocity.x = speed * direction.x
    velocity.y += gravity * delta
    velocity = move_and_slide(velocity)
    
    if is_on_wall():
        direction.x *= -1
        $Sprite.flip_h = not $Sprite.flip_h
        
    if randf() < 0.01:  # 1%几率改变垂直方向
        direction.y = rand_range(-0.5, 0.5)

func take_damage(amount):
    health -= amount
    if health <= 0:
        SoundManager.play("explosion")
        Game.add_score(150)
        queue_free()