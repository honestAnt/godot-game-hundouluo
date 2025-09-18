extends Node

const SOUNDS = {
    "shoot": "res://assets/sounds/shoot.wav",
    "explosion": "res://assets/sounds/explosion.wav",
    "pickup": "res://assets/sounds/pickup.wav"
}

var players = {}

func _ready():
    for key in SOUNDS.keys():
        var player = AudioStreamPlayer.new()
        player.stream = load(SOUNDS[key])
        add_child(player)
        players[key] = player
        
func play(sound_name):
    if players.has(sound_name):
        players[sound_name].play()