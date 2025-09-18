extends CharacterBody2D

const SPEED = 300
const JUMP = 600
const GRAVITY = 1200

func _physics_process(delta):
    var move = Input.get_axis("ui_left", "ui_right")
    velocity.x = move * SPEED
    
    if is_on_floor() and Input.is_action_just_pressed("ui_up"):
        velocity.y = -JUMP
        
    velocity.y += GRAVITY * delta
    move_and_slide()