extends Node

var current_level = 1
var player_lives = 3
var player_score = 0
var game_state = preload("res://scripts/game_state.gd").new()

func _ready():
    add_child(game_state)
    game_state.load_game()

func _ready():
    load_level(current_level)
    
func load_level(level_num):
    var level = load("res://scenes/levels/level_%d.tscn" % level_num).instance()
    add_child(level)
    
func player_died():
    player_lives -= 1
    if player_lives <= 0:
        game_over()
    else:
        get_tree().reload_current_scene()
        
func game_over():
    # 显示游戏结束画面
    pass
    
func add_score(points):
    player_score += points