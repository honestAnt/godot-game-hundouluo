extends KinematicBody2D

# 玩家脚本

# 移动参数
export var speed = 200
export var jump_force = 400
export var gravity = 800
export var climb_speed = 150

# 生命值参数
export var max_health = 3
var health = max_health
var invincible = false
var invincible_time = 2.0

# 武器参数
enum WeaponType { NORMAL, MACHINE_GUN, SPREAD, LASER, FLAME, MISSILE }
var current_weapon = WeaponType.NORMAL
var weapon_ammo = {
    WeaponType.NORMAL: -1,  # 无限
    WeaponType.MACHINE_GUN: 30,
    WeaponType.SPREAD: 20,
    WeaponType.LASER: 15,
    WeaponType.FLAME: 25,
    WeaponType.MISSILE: 10
}

# 状态变量
var velocity = Vector2.ZERO
var is_jumping = false
var is_shooting = false
var is_climbing = false
var is_dead = false
var facing_right = true
var can_shoot = true
var shoot_cooldown = 0.2
var machine_gun_cooldown = 0.1

# 节点引用
@onready var sprite = $AnimatedSprite
@onready var shoot_timer = $ShootTimer
@onready var invincible_timer = $InvincibleTimer
@onready var shoot_position = $ShootPosition
@onready var collision_shape = $CollisionShape2D
@onready var animation_player = $AnimationPlayer
@onready var audio_player = $AudioPlayer

# 预加载资源
var bullet_scenes = {
    WeaponType.NORMAL: preload("res://src/scenes/bullets/normal_bullet.tscn"),
    WeaponType.MACHINE_GUN: preload("res://src/scenes/bullets/normal_bullet.tscn"),
    WeaponType.SPREAD: preload("res://src/scenes/bullets/spread_bullet.tscn"),
    WeaponType.LASER: preload("res://src/scenes/bullets/laser_bullet.tscn"),
    WeaponType.FLAME: preload("res://src/scenes/bullets/flame_bullet.tscn"),
    WeaponType.MISSILE: preload("res://src/scenes/bullets/missile_bullet.tscn")
}

func _ready():
    # 初始化玩家
    health = max_health
    
    # 连接信号
    shoot_timer.connect("timeout", self, "_on_shoot_timer_timeout")
    invincible_timer.connect("timeout", self, "_on_invincible_timer_timeout")
    
    # 添加到玩家组
    add_to_group("player")

func _physics_process(delta):
    if is_dead:
        return
    
    # 处理重力
    if not is_climbing:
        velocity.y += gravity * delta
    
    # 处理输入
    _handle_input()
    
    # 处理动画
    _update_animation()
    
    # 应用移动
    velocity = move_and_slide(velocity, Vector2.UP)
    
    # 检查是否在地面上
    if is_on_floor():
        is_jumping = false

func _handle_input():
    # 水平移动
    var move_direction = 0
    if Input.is_action_pressed("move_left"):
        move_direction -= 1
        facing_right = false
    if Input.is_action_pressed("move_right"):
        move_direction += 1
        facing_right = true
    
    velocity.x = move_direction * speed
    
    # 跳跃
    if Input.is_action_just_pressed("jump") and is_on_floor():
        velocity.y = -jump_force
        is_jumping = true
        audio_player.play("jump")
    
    # 攀爬
    if is_climbing:
        var climb_direction = 0
        if Input.is_action_pressed("move_up"):
            climb_direction -= 1
        if Input.is_action_pressed("move_down"):
            climb_direction += 1
        
        velocity.y = climb_direction * climb_speed
    
    # 射击
    if Input.is_action_pressed("shoot") and can_shoot:
        shoot()
    
    # 切换武器
    if Input.is_action_just_pressed("weapon_next"):
        cycle_weapon(1)
    if Input.is_action_just_pressed("weapon_prev"):
        cycle_weapon(-1)

func _update_animation():
    # 更新精灵朝向
    sprite.flip_h = !facing_right
    
    # 更新射击位置
    if facing_right:
        shoot_position.position.x = abs(shoot_position.position.x)
    else:
        shoot_position.position.x = -abs(shoot_position.position.x)
    
    # 设置动画
    if is_dead:
        sprite.animation = "die"
    elif is_climbing:
        sprite.animation = "climb"
        if velocity.y != 0:
            sprite.playing = true
        else:
            sprite.playing = false
    elif is_jumping:
        sprite.animation = "jump"
    elif velocity.x != 0:
        sprite.animation = "run"
    else:
        sprite.animation = "idle"
    
    # 如果正在射击，混合射击动画
    if is_shooting:
        if sprite.animation == "idle":
            sprite.animation = "shoot"
        elif sprite.animation == "run":
            sprite.animation = "run_shoot"
        elif sprite.animation == "jump":
            sprite.animation = "jump_shoot"

func shoot():
    # 检查弹药
    if weapon_ammo[current_weapon] == 0:
        # 切换回普通武器
        current_weapon = WeaponType.NORMAL
        return
    
    # 减少弹药
    if weapon_ammo[current_weapon] > 0:
        weapon_ammo[current_weapon] -= 1
    
    # 设置射击状态
    is_shooting = true
    can_shoot = false
    
    # 创建子弹
    var bullet_scene = bullet_scenes[current_weapon]
    
    # 根据武器类型处理射击逻辑
    match current_weapon:
        WeaponType.NORMAL, WeaponType.MACHINE_GUN:
            _spawn_single_bullet(bullet_scene)
            
        WeaponType.SPREAD:
            _spawn_spread_bullets(bullet_scene)
            
        WeaponType.LASER:
            _spawn_single_bullet(bullet_scene)
            
        WeaponType.FLAME:
            _spawn_single_bullet(bullet_scene)
            
        WeaponType.MISSILE:
            _spawn_single_bullet(bullet_scene)
    
    # 播放射击音效
    audio_player.play("shoot_" + str(current_weapon))
    
    # 设置冷却时间
    var cooldown = shoot_cooldown
    if current_weapon == WeaponType.MACHINE_GUN:
        cooldown = machine_gun_cooldown
    
    shoot_timer.start(cooldown)

func _spawn_single_bullet(bullet_scene):
    var bullet = bullet_scene.instance()
    bullet.global_position = shoot_position.global_position
    
    # 设置子弹方向
    if facing_right:
        bullet.direction = Vector2.RIGHT
    else:
        bullet.direction = Vector2.LEFT
    
    # 添加到场景
    get_parent().add_child(bullet)

func _spawn_spread_bullets(bullet_scene):
    # 散弹枪发射多个子弹
    var directions = [
        Vector2(1, -0.2).normalized(),
        Vector2(1, 0).normalized(),
        Vector2(1, 0.2).normalized()
    ]
    
    for dir in directions:
        var bullet = bullet_scene.instance()
        bullet.global_position = shoot_position.global_position
        
        # 设置子弹方向
        if facing_right:
            bullet.direction = dir
        else:
            bullet.direction = Vector2(-dir.x, dir.y)
        
        # 添加到场景
        get_parent().add_child(bullet)

func _on_shoot_timer_timeout():
    can_shoot = true
    is_shooting = false

func take_damage(amount):
    if invincible or is_dead:
        return
    
    health -= amount
    
    if health <= 0:
        die()
    else:
        # 受伤动画和无敌时间
        invincible = true
        animation_player.play("hit")
        invincible_timer.start(invincible_time)
        audio_player.play("hit")

func _on_invincible_timer_timeout():
    invincible = false
    animation_player.play("RESET")

func die():
    is_dead = true
    velocity = Vector2.ZERO
    collision_shape.disabled = true
    sprite.animation = "die"
    audio_player.play("die")
    
    # 通知游戏管理器
    if has_node("/root/GameManager"):
        get_node("/root/GameManager").on_player_death()

func cycle_weapon(direction):
    # 循环切换武器
    var weapons = WeaponType.values()
    var current_index = current_weapon
    var new_index = (current_index + direction) % weapons.size()
    
    if new_index < 0:
        new_index = weapons.size() - 1
    
    current_weapon = new_index
    
    # 播放武器切换音效
    audio_player.play("weapon_switch")

func add_ammo(weapon_type, amount):
    if weapon_type in weapon_ammo:
        weapon_ammo[weapon_type] += amount

func set_climbing(climbing):
    is_climbing = climbing
    
    if climbing:
        # 停止重力影响
        velocity.y = 0