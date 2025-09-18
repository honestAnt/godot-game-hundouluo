extends Panel

func _ready():
	$VolumeSlider.value = AudioServer.get_bus_volume_db(0)

func _on_VolumeSlider_value_changed(value):
	AudioServer.set_bus_volume_db(0, value)

func _on_BackButton_pressed():
	queue_free()