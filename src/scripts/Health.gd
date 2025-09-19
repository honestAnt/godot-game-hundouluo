extends Node

signal hp_changed(new_hp)

@export var health_max := 100
@export var current_health := 100

func _ready():
    current_health = health_max

func take_damage(amount):
    current_health -= amount
    if current_health < 0:
        current_health = 0
    hp_changed.emit(current_health)

func heal(amount):
    current_health += amount
    if current_health > health_max:
        current_health = health_max
    hp_changed.emit(current_health)