extends Area2D

# Boss竞技场危险物脚本

export var damage = 15
export var active_duration = 5.0
export var inactive_duration = 8.0

var is_active = false
var timer = 0.0

func _ready():
    set_active(false)

func _process(delta):
    timer += delta
    if is_active and timer >= active_duration:
        set_active(false)
        timer = 0.0
    elif not is_active and timer >= inactive_duration:
        set_active(true)
        timer = 0.0

func set_active(active):
    is_active = active
    $Sprite.visible = active
    $CollisionShape2D.disabled = not active

func activate():
    set_active(true)
    timer = 0.0

func deactivate():
    set_active(false)
    timer = 0.0

func _on_body_entered(body):
    if is_active and body.is_in_group("player"):
        body.take_damage(damage)