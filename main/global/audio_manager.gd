extends AudioStreamPlayer

# Musik starten
func play_music(music_stream: AudioStream):
	if stream == music_stream:
		return # Spielt schon, nicht neu starten

	stream = music_stream
	play()

# Musik stoppen
func stop_music():
	stop()
