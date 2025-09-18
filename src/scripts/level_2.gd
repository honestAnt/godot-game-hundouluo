extends Node2D

var enemy_count = 15
var spawned = 0
var boss_spawned = false

func _ready():
    $EnemySpawner.connect("timeout", self, "_on_enemy_spawner_timeout")
    SoundManager.play_music("res://assets/music/boss_battle.ogg")
    
func _exit_tree():
    SoundManager.stop_music()
    
func _on_enemy_spawner_timeout():
    if spawned < enemy_count:
        spawn_enemy()
        spawned += 1
    elif not boss_spawned:
        spawn_boss()
        boss_spawned = true

func spawn_enemy():
    var enemy = preload("res://scenes/flying_enemy.tscn").instance()
    enemy.position = Vector2(rand_range(100, 500), rand_range(50, 200))
    add_child(enemy)
    
    if randf() < 0.15:  # 15%几率生成武器拾取
        spawn_pickup(enemy.position)

func spawn_boss():
    var boss = preload("res://scenes/boss.tscn").instance()
    boss.position = Vector2(300, 100)
    add_child(boss)

func spawn_pickup(pos):
    var pickup = preload("res://scenes/weapon_pickup.tscn").instance()
    pickup.position = pos
    pickup.weapon_type = ["spread", "laser", "fire"][randi() % 3]
    add_child(pickup)

func _process(delta):
    if boss_spawned and get_tree().get_nodes_in_group("boss").size() == 0:
        game_complete()
        
func game_complete():
    get_tree().change_scene("res://scenes/game_complete.tscn")