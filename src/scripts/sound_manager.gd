extends Node

var sounds = {
    "shoot": preload("res://assets/sounds/shoot.wav"),
    "explosion": preload("res://assets/sounds/explosion.wav"),
    "powerup": preload("res://assets/sounds/powerup.wav"),
    "boss_explosion": preload("res://assets/sounds/boss_explosion.wav"),
    "boss_attack": preload("res://assets/sounds/boss_attack.wav"),
    "level_complete": preload("res://assets/sounds/level_complete.wav")
}

var current_music = null
var music_player = AudioStreamPlayer.new()

func _ready():
    add_child(music_player)
    
func play_music(music_path):
    if current_music != music_path:
        current_music = music_path
        music_player.stream = load(music_path)
        music_player.play()
        
func stop_music():
    music_player.stop()
    current_music = null

func play(sound_name):
    if sounds.has(sound_name):
        var player = AudioStreamPlayer.new()
        player.stream = sounds[sound_name]
        add_child(player)
        player.play()
        player.connect("finished", player, "queue_free")