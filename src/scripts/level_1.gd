extends Node2D

var enemy_count = 10
var spawned = 0

func _ready():
    $EnemySpawner.connect("timeout", self, "_on_enemy_spawner_timeout")
    SoundManager.play_music("res://assets/music/level1.ogg")
    
func _exit_tree():
    SoundManager.stop_music()
    
func _on_enemy_spawner_timeout():
    if spawned < enemy_count:
        spawn_enemy()
        spawned += 1
        
func spawn_enemy():
    var enemy = preload("res://scenes/enemy.tscn").instance()
    enemy.position = Vector2(rand_range(100, 500), -50)
    add_child(enemy)
    
    # 10%几率生成武器拾取
    if randf() < 0.1:
        var pickup = preload("res://scenes/weapon_pickup.tscn").instance()
        pickup.position = Vector2(rand_range(100, 500), -50)
        pickup.weapon_type = ["spread", "laser", "fire"][randi() % 3]
        add_child(pickup)

func _process(delta):
    if $EnemySpawner.spawned >= enemy_count and get_tree().get_nodes_in_group("enemies").size() == 0:
        level_complete()
        
func level_complete():
    get_tree().change_scene("res://scenes/levels/level_2.tscn")