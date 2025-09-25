extends "res://src/scripts/enemy.gd"

# Boss脚本，继承自敌人基类

# Boss阶段
enum BossPhase { PHASE1, PHASE2, PHASE3 }
var current_phase = BossPhase.PHASE1
var phase_health_thresholds = [0.7, 0.4, 0.1]  # 70%, 40%, 10%的血量进入下一阶段

# Boss特殊攻击参数
@export var special_attack_cooldown = 5.0
var can_special_attack = true
var attack_patterns = []
var current_attack_pattern = 0

# 节点引用
@onready var special_attack_timer = $SpecialAttackTimer
@onready var phase_transition_timer = $PhaseTransitionTimer

func _ready():
    # 设置为Boss类型
    enemy_type = EnemyType.BOSS
    
    # 连接信号
    special_attack_timer.timeout.connect(_on_special_attack_timer_timeout)
    phase_transition_timer.timeout.connect(_on_phase_transition_timer_timeout)
    
    # 初始化攻击模式
    _setup_attack_patterns()

func _physics_process(delta):
    if is_dead:
        return
    
    # 处理Boss AI
    _handle_boss_ai(delta)
    
    # 更新动画
    _update_animation()
    
    # 应用移动
    velocity.y += gravity * delta
    set_velocity(velocity)
    set_up_direction(Vector2.UP)
    move_and_slide()
    velocity = velocity
    
    # 检查阶段转换
    _check_phase_transition()

# 重写父类的攻击方法
func _attack():
    can_attack = false
    attack_timer.start(attack_cooldown)
    
    # 根据当前阶段选择不同的攻击方式
    match current_phase:
        BossPhase.PHASE1:
            _phase1_attack()
        BossPhase.PHASE2:
            _phase2_attack()
        BossPhase.PHASE3:
            _phase3_attack()

# 重写父类的受伤方法
func take_damage(amount):
    if is_dead or ai_state == "phase_transition":
        return
    
    health -= amount
    
    # 检查是否需要转换阶段
    if health <= 0:
        die()
    else:
        # 受伤动画
        animation_player.play("hit")
        audio_player.play("hit")

# 导入其他Boss功能模块
func _setup_attack_patterns():
    # 第一阶段攻击模式
    attack_patterns.append([
        "bullet_spray",
        "jump_attack",
        "ground_pound"
    ])
    
    # 第二阶段攻击模式
    attack_patterns.append([
        "bullet_spray",
        "homing_missiles",
        "jump_attack",
        "ground_pound"
    ])
    
    # 第三阶段攻击模式
    attack_patterns.append([
        "bullet_spray",
        "homing_missiles",
        "laser_beam",
        "jump_attack",
        "ground_pound"
    ])

# 导入Boss AI处理模块
func _handle_boss_ai(delta):
    # 在boss_ai.gd中实现
    if has_method("_handle_boss_ai_impl"):
        call("_handle_boss_ai_impl", delta)