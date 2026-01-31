extends AudioStreamPlayer

var music_enabled := true
var current_stream: AudioStream = null

func _ready():
	bus = "Music"
	autoplay = false

#func play_music(stream: AudioStream, fade := true):
	#if not music_enabled:
		#return
#
	#if self.stream == stream and playing:
		#return
#
	#if fade and playing:
		#await fade_out()
#
	#self.stream = stream
	#play()
	#if fade:
		#await fade_in()
func play_music(stream: AudioStream, fade := true):
	current_stream = stream   # ⭐ STORE IT

	if not music_enabled:
		return

	if self.stream == stream and playing:
		return

	if fade and playing:
		await fade_out()

	self.stream = stream
	play()

	if fade:
		await fade_in()

func stop_music(fade := true):
	if fade and playing:
		await fade_out()
	stop()

func fade_in(duration := 0.5):
	volume_db = -40
	play()
	var tween := create_tween()
	tween.tween_property(self, "volume_db", 0, duration)
	await tween.finished

func fade_out(duration := 0.5):
	var tween := create_tween()
	tween.tween_property(self, "volume_db", -40, duration)
	await tween.finished

#func set_music_enabled(enabled: bool):
	#music_enabled = enabled
	#if not enabled:
		#stop()
func set_music_enabled(enabled: bool):
	music_enabled = enabled

	if not enabled:
		stop()
	else:
		if current_stream:
			play_music(current_stream)
