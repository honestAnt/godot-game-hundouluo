extends Node

# 音频管理器脚本

# 音频类型
enum AudioType { MUSIC, SOUND_EFFECT }

# 音频设置
var music_volume = 0.8
var sfx_volume = 1.0
var master_volume = 1.0

# 音频路径
var music_paths = {
    "menu": "res://src/assets/music/menu.ogg",
    "game_start": "res://src/assets/music/game_start.ogg",
    "level_1": "res://src/assets/music/level_1.ogg",
    "level_2": "res://src/assets/music/level_2.ogg",
    "level_3": "res://src/assets/music/level_3.ogg",
    "level_4": "res://src/assets/music/level_4.ogg",
    "level_5": "res://src/assets/music/level_5.ogg",
    "boss": "res://src/assets/music/boss.ogg",
    "game_over": "res://src/assets/music/game_over.ogg",
    "victory": "res://src/assets/music/victory.ogg"
}

var sound_paths = {
    "jump": "res://src/assets/sounds/jump.wav",
    "shoot": "res://src/assets/sounds/shoot.wav",
    "hit": "res://src/assets/sounds/hit.wav",
    "explosion": "res://src/assets/sounds/explosion.wav",
    "pickup": "res://src/assets/sounds/pickup.wav",
    "die": "res://src/assets/sounds/die.wav",
    "menu_select": "res://src/assets/sounds/menu_select.wav",
    "menu_move": "res://src/assets/sounds/menu_move.wav",
    "level_complete": "res://src/assets/sounds/level_complete.wav"
}

# 节点引用
@onready var music_player = $MusicPlayer
@onready var sound_players = $SoundPlayers.get_children()
var current_sound_player = 0

func _ready():
    # 初始化音频管理器
    pass

func play_music(music_name):
    if not music_name in music_paths:
        push_error("音乐 " + music_name + " 不存在!")
        return
    
    # 加载音乐
    var music_path = music_paths[music_name]
    var music = load(music_path)
    
    if music:
        # 停止当前音乐
        music_player.stop()
        
        # 设置新音乐
        music_player.stream = music
        music_player.volume_db = linear_to_db(music_volume * master_volume)
        music_player.play()
    else:
        push_error("无法加载音乐 " + music_path + "!")

func play_sound(sound_name):
    if not sound_name in sound_paths:
        push_error("音效 " + sound_name + " 不存在!")
        return
    
    # 加载音效
    var sound_path = sound_paths[sound_name]
    var sound = load(sound_path)
    
    if sound:
        # 获取可用的音效播放器
        var sound_player = sound_players[current_sound_player]
        current_sound_player = (current_sound_player + 1) % sound_players.size()
        
        # 设置音效
        sound_player.stream = sound
        sound_player.volume_db = linear_to_db(sfx_volume * master_volume)
        sound_player.play()
    else:
        push_error("无法加载音效 " + sound_path + "!")

func stop_music():
    music_player.stop()

func set_volume(audio_type, volume):
    match audio_type:
        AudioType.MUSIC:
            music_volume = clamp(volume, 0.0, 1.0)
            if music_player.playing:
                music_player.volume_db = linear_to_db(music_volume * master_volume)
        AudioType.SOUND_EFFECT:
            sfx_volume = clamp(volume, 0.0, 1.0)

func set_master_volume(volume):
    master_volume = clamp(volume, 0.0, 1.0)
    
    # 更新音乐音量
    if music_player.playing:
        music_player.volume_db = linear_to_db(music_volume * master_volume)

func mute_audio(mute):
    AudioServer.set_bus_mute(0, mute)