extends Node

var high_score = 0
var unlocked_levels = 1
var player_lives = 3
var current_weapon = "normal"

func save_game():
    var save_data = {
        "high_score": high_score,
        "unlocked_levels": unlocked_levels
    }
    var file = File.new()
    file.open("user://savegame.dat", File.WRITE)
    file.store_var(save_data)
    file.close()
    
func load_game():
    var file = File.new()
    if file.file_exists("user://savegame.dat"):
        file.open("user://savegame.dat", File.READ)
        var save_data = file.get_var()
        file.close()
        high_score = save_data["high_score"]
        unlocked_levels = save_data["unlocked_levels"]
    else:
        # 默认值
        high_score = 0
        unlocked_levels = 1