extends "res://src/scripts/boss.gd"

# Boss攻击实现模块

func _ready():
    # 确保基类的_ready也被调用
    ._ready()

func _special_attack():
    can_special_attack = false
    special_attack_timer.start(special_attack_cooldown)
    
    # 获取当前阶段的攻击模式
    var patterns = attack_patterns[current_phase]
    var attack_type = patterns[current_attack_pattern]
    
    # 更新下一个攻击模式
    current_attack_pattern = (current_attack_pattern + 1) % patterns.size()
    
    # 执行特殊攻击
    call("_special_attack_" + attack_type)

func _on_special_attack_timer_timeout():
    can_special_attack = true

func _phase1_attack():
    # 第一阶段的普通攻击
    # 发射3发子弹
    for i in range(3):
        var bullet = bullet_scene.instance()
        bullet.global_position = shoot_position.global_position
        
        # 设置子弹方向，稍微散开
        var direction = (player.global_position - global_position).normalized()
        var spread = 0.1 * (i - 1)  # -0.1, 0, 0.1
        direction = direction.rotated(spread)
        bullet.direction = direction
        
        # 添加到场景
        get_parent().add_child(bullet)
        
        # 短暂延迟
        yield(get_tree().create_timer(0.1), "timeout")
    
    audio_player.play("shoot")

func _phase2_attack():
    # 第二阶段的普通攻击
    # 发射5发子弹
    for i in range(5):
        var bullet = bullet_scene.instance()
        bullet.global_position = shoot_position.global_position
        
        # 设置子弹方向，更大散开
        var direction = (player.global_position - global_position).normalized()
        var spread = 0.15 * (i - 2)  # -0.3, -0.15, 0, 0.15, 0.3
        direction = direction.rotated(spread)
        bullet.direction = direction
        
        # 添加到场景
        get_parent().add_child(bullet)
        
        # 短暂延迟
        yield(get_tree().create_timer(0.08), "timeout")
    
    audio_player.play("shoot")

func _phase3_attack():
    # 第三阶段的普通攻击
    # 发射7发子弹
    for i in range(7):
        var bullet = bullet_scene.instance()
        bullet.global_position = shoot_position.global_position
        
        # 设置子弹方向，更大散开
        var direction = (player.global_position - global_position).normalized()
        var spread = 0.2 * (i - 3)  # -0.6, -0.4, -0.2, 0, 0.2, 0.4, 0.6
        direction = direction.rotated(spread)
        bullet.direction = direction
        bullet.speed *= 1.2  # 更快的子弹
        
        # 添加到场景
        get_parent().add_child(bullet)
        
        # 短暂延迟
        yield(get_tree().create_timer(0.05), "timeout")
    
    audio_player.play("shoot")

# 特殊攻击实现
func _special_attack_bullet_spray():
    # 子弹喷射攻击
    animation_player.play("special_attack")
    audio_player.play("special_attack")
    
    # 360度喷射子弹
    var bullet_count = 12
    for i in range(bullet_count):
        var bullet = bullet_scene.instance()
        bullet.global_position = global_position
        
        # 设置子弹方向，均匀分布在圆周上
        var angle = 2 * PI * i / bullet_count
        var direction = Vector2(cos(angle), sin(angle))
        bullet.direction = direction
        
        # 添加到场景
        get_parent().add_child(bullet)
    
    yield(animation_player, "animation_finished")

func _special_attack_jump_attack():
    # 跳跃攻击
    animation_player.play("jump")
    audio_player.play("jump")
    
    # 向玩家方向跳跃
    var jump_direction = 1 if facing_right else -1
    velocity.x = jump_direction * speed * 2
    velocity.y = -600  # 跳跃力度
    
    # 等待到达最高点
    yield(get_tree().create_timer(0.5), "timeout")
    
    # 下落时的攻击
    animation_player.play("ground_pound")
    audio_player.play("ground_pound")
    
    # 等待落地
    yield(get_tree().create_timer(0.5), "timeout")
    
    # 落地冲击波
    _create_shockwave()

func _special_attack_ground_pound():
    # 地面猛击
    animation_player.play("ground_pound")
    audio_player.play("ground_pound")
    
    # 跳跃
    velocity.y = -300
    
    # 等待到达最高点
    yield(get_tree().create_timer(0.3), "timeout")
    
    # 快速下落
    velocity.y = 1000
    
    # 等待落地
    yield(get_tree().create_timer(0.3), "timeout")
    
    # 落地冲击波
    _create_shockwave()

func _special_attack_homing_missiles():
    # 追踪导弹攻击
    animation_player.play("special_attack")
    audio_player.play("missile_launch")
    
    # 发射3枚追踪导弹
    var missile_scene = load("res://src/scenes/bullets/missile_bullet.tscn")
    
    for i in range(3):
        var missile = missile_scene.instance()
        missile.global_position = shoot_position.global_position
        
        # 设置导弹参数
        missile.target = player
        
        # 添加到场景
        get_parent().add_child(missile)
        
        # 短暂延迟
        yield(get_tree().create_timer(0.3), "timeout")

func _special_attack_laser_beam():
    # 激光束攻击
    animation_player.play("laser_charge")
    audio_player.play("laser_charge")
    
    # 充能时间
    yield(get_tree().create_timer(1.0), "timeout")
    
    # 发射激光
    animation_player.play("laser_fire")
    audio_player.play("laser_fire")
    
    # 创建激光效果
    var laser_scene = load("res://src/scenes/bullets/laser_bullet.tscn")
    var laser = laser_scene.instance()
    laser.global_position = shoot_position.global_position
    
    # 设置激光参数
    var direction = (player.global_position - global_position).normalized()
    laser.direction = direction
    laser.damage = damage * 2
    laser.penetration = true
    
    # 添加到场景
    get_parent().add_child(laser)
    
    # 激光持续时间
    yield(get_tree().create_timer(2.0), "timeout")

func _create_shockwave():
    # 创建地面冲击波
    var shockwave_scene = load("res://src/scenes/effects/shockwave.tscn")
    var shockwave = shockwave_scene.instance()
    shockwave.global_position = Vector2(global_position.x, global_position.y + 20)
    get_parent().add_child(shockwave)
    
    # 对附近的玩家造成伤害
    if player and global_position.distance_to(player.global_position) < 150:
        player.take_damage(damage)