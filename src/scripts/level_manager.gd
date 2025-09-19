extends Node

# 关卡管理器脚本

# 关卡场景路径
var level_scenes = {
    1: "res://src/scenes/levels/level_1.tscn",
    2: "res://src/scenes/levels/level_2.tscn",
    3: "res://src/scenes/levels/level_3.tscn",
    4: "res://src/scenes/levels/level_4.tscn",
    5: "res://src/scenes/levels/level_5.tscn"
}

# 当前加载的关卡
var current_level_node = null
var current_level_number = 0

# 信号
signal level_loaded(level_number)
signal level_completed()

func _ready():
    # 初始化关卡管理器
    pass

func load_level(level_number):
    # 检查关卡是否存在
    if not level_number in level_scenes:
        push_error("关卡 " + str(level_number) + " 不存在!")
        return
    
    # 卸载当前关卡
    unload_current_level()
    
    # 加载新关卡
    var level_scene = load(level_scenes[level_number])
    if level_scene:
        current_level_node = level_scene.instance()
        add_child(current_level_node)
        current_level_number = level_number
        
        # 连接关卡信号
        if current_level_node.has_signal("level_completed"):
            current_level_node.connect("level_completed", self, "_on_level_completed")
        
        # 发送关卡加载信号
        emit_signal("level_loaded", level_number)
    else:
        push_error("无法加载关卡 " + str(level_number) + "!")

func reload_current_level():
    if current_level_number > 0:
        load_level(current_level_number)

func unload_current_level():
    if current_level_node:
        # 断开信号连接
        if current_level_node.has_signal("level_completed") and current_level_node.is_connected("level_completed", self, "_on_level_completed"):
            current_level_node.disconnect("level_completed", self, "_on_level_completed")
        
        # 移除关卡节点
        current_level_node.queue_free()
        current_level_node = null

func _on_level_completed():
    # 转发信号
    emit_signal("level_completed")

func get_current_level_number():
    return current_level_number