extends CharacterBody2D

enum BOSS_STATE {
    NORMAL,
    RAGE,
    DESPERATE
}

var current_state = BOSS_STATE.NORMAL
var attack_cooldown := 1.5

@onready var health = $Health
@onready var attack_timer = $AttackTimer
@onready var explosion_timer = $ExplosionTimer

func _ready():
    health.hp_changed.connect(_on_hp_changed)
    attack_timer.wait_time = attack_cooldown

func _on_hp_changed(new_hp):
    var hp_percent = float(new_hp) / health.health_max
    if hp_percent <= 0.5 and current_state == BOSS_STATE.NORMAL:
        enter_state(BOSS_STATE.RAGE)
    elif hp_percent <= 0.25 and current_state == BOSS_STATE.RAGE:
        enter_state(BOSS_STATE.DESPERATE)

func enter_state(new_state):
    current_state = new_state
    match new_state:
        BOSS_STATE.RAGE:
            $AnimationPlayer.play("rage_start")
            attack_cooldown = 1.0
        BOSS_STATE.DESPERATE:
            $AnimationPlayer.play("desperate_loop")
            explosion_timer.start()
    
    attack_timer.wait_time = attack_cooldown

func _on_AttackTimer_timeout():
    match current_state:
        BOSS_STATE.NORMAL:
            spawn_bullet_fan(8)
        BOSS_STATE.RAGE:
            dash_attack()
        BOSS_STATE.DESPERATE:
            spawn_circle_bullets(16)

func spawn_bullet_fan(count):
    for i in range(count):
        var bullet = preload("res://src/bullets/BossBullet.tscn").instantiate()
        bullet.direction = Vector2.RIGHT.rotated(2*PI/count * i)
        bullet.position = global_position
        get_parent().add_child(bullet)
        bullet.set_damage(10)

func dash_attack():
    var target_pos = get_node("/root/Game/Player").global_position
    var tween = create_tween()
    tween.tween_property(self, "position", target_pos, 0.3).set_trans(Tween.TRANS_BACK)
    $DashParticles.emitting = true
    $Hitbox/CollisionShape2D.disabled = false
    await tween.finished
    $Hitbox/CollisionShape2D.disabled = true

func spawn_circle_bullets(count):
    for i in range(count):
        var bullet = preload("res://src/bullets/CircleBullet.tscn").instantiate()
        bullet.direction = Vector2.RIGHT.rotated(2*PI/count * i)
        bullet.position = global_position
        get_parent().add_child(bullet)
        bullet.set_damage(15)