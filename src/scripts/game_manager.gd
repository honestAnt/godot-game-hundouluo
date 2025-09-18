extends Node

var score = 0
var lives = 3
var current_level = 1

onready var ui = $UI
onready var audio = $AudioManager

func _ready():
    randomize()
    ui.update_score(score)
    ui.update_lives(lives)
    
func add_score(points):
    score += points
    ui.update_score(score)
    audio.play("pickup")
    
func lose_life():
    lives -= 1
    ui.update_lives(lives)
    audio.play("explosion")
    if lives <= 0:
        game_over()
        
func game_over():
    get_tree().change_scene("res://src/scenes/game_over.tscn")
    
func next_level():
    current_level += 1
    get_tree().change_scene("res://src/scenes/level%s.tscn" % current_level)