extends AudioStreamPlayer

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

func play_music():
	if not playing:
		play()

func stop_music():
	stop()
