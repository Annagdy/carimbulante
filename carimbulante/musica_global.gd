extends AudioStreamPlayer2D

func play_music():
	if not playing:
		play()

func stop_music():
	stop()
