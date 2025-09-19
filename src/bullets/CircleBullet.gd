extends "res://bullets/Bullet.gd"

func _ready():
    $LifetimeTimer.wait_time = 5.0
    $LifetimeTimer.start()

func _on_LifetimeTimer_timeout():
    queue_free()