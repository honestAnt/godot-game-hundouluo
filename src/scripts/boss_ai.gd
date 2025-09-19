extends "res://src/scripts/boss.gd"

# Boss AI实现模块

func _ready():
    # 确保基类的_ready也被调用
    ._ready()

func _handle_boss_ai_impl(delta):
    match ai_state:
        "idle":
            velocity.x = 0
            
            # 一段时间后切换到移动状态
            if randf() < 0.01:  # 1%几率每帧
                ai_state = "move"
        
        "move":
            # 随机移动
            if randf() < 0.02:  # 2%几率每帧改变方向
                facing_right = !facing_right
            
            var direction = 1 if facing_right else -1
            velocity.x = direction * speed
            
            # 检查是否发现玩家
            if player and _can_see_player():
                ai_state = "attack"
            
            # 一段时间后切换回空闲状态
            if randf() < 0.01:  # 1%几率每帧
                ai_state = "idle"
        
        "attack":
            if player and _can_see_player():
                # 朝向玩家
                facing_right = player.global_position.x > global_position.x
                
                # 根据距离决定行为
                var distance = global_position.distance_to(player.global_position)
                
                if distance > attack_range * 1.5:
                    # 太远，移动接近
                    var direction = 1 if facing_right else -1
                    velocity.x = direction * speed
                elif distance < attack_range * 0.5:
                    # 太近，后退
                    var direction = -1 if facing_right else 1
                    velocity.x = direction * speed * 0.5
                else:
                    # 适当距离，停止移动
                    velocity.x = 0
                    
                    # 普通攻击
                    if can_attack:
                        _attack()
                    
                    # 特殊攻击
                    if can_special_attack:
                        _special_attack()
            else:
                ai_state = "move"
        
        "phase_transition":
            # 阶段转换中，停止所有行动
            velocity = Vector2.ZERO

func _check_phase_transition():
    # 检查是否需要转换阶段
    var health_percent = float(health) / max_health
    
    if current_phase == BossPhase.PHASE1 and health_percent <= phase_health_thresholds[0]:
        _start_phase_transition(BossPhase.PHASE2)
    elif current_phase == BossPhase.PHASE2 and health_percent <= phase_health_thresholds[1]:
        _start_phase_transition(BossPhase.PHASE3)

func _start_phase_transition(new_phase):
    # 开始阶段转换
    current_phase = new_phase
    ai_state = "phase_transition"
    
    # 播放阶段转换动画
    animation_player.play("phase_transition")
    
    # 短暂无敌
    invincible = true
    
    # 设置转换计时器
    phase_transition_timer.start(3.0)
    
    # 播放阶段转换音效
    audio_player.play("phase_transition")

func _on_phase_transition_timer_timeout():
    # 阶段转换结束
    ai_state = "move"
    invincible = false
    
    # 根据新阶段调整参数
    match current_phase:
        BossPhase.PHASE2:
            speed *= 1.2
            attack_cooldown *= 0.8
            special_attack_cooldown *= 0.8
        BossPhase.PHASE3:
            speed *= 1.5
            attack_cooldown *= 0.6
            special_attack_cooldown *= 0.6