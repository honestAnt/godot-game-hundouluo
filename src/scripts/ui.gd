extends CanvasLayer

onready var score_label = $ScoreLabel
onready var lives_container = $LivesContainer
onready var life_icon = preload("res://assets/sprites/life_icon.png")

func _ready():
    update_score(0)
    update_lives(3)
    
func update_score(value):
    score_label.text = "SCORE: %06d" % value
    
func update_lives(count):
    for child in lives_container.get_children():
        child.queue_free()
        
    for i in range(count):
        var icon = TextureRect.new()
        icon.texture = life_icon
        lives_container.add_child(icon)

func show_game_over():
    $GameOverPanel.visible = true
    
func _on_RestartButton_pressed():
    get_tree().reload_current_scene()