extends AudioStreamPlayer

var music_enabled := true
var current_music: AudioStream = null

var current_stream: AudioStream = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	bus = "Music"
	autoplay = false

func play_music(new_music: AudioStream, fade := true):
	if not music_enabled:
		return

	# Same music already playing → do nothing
	if current_music == new_music and playing:
		return

	# Fade out current music
	if fade and playing:
		await fade_out()

	# Switch track
	current_music = new_music
	stream = new_music
	play()

	# Fade in
	if fade:
		await fade_in()


# =========================
# STOP MUSIC
# =========================
func stop_music(fade := true):
	if fade and playing:
		await fade_out()
	stop()
	current_music = null


# =========================
# FADE HELPERS
# =========================
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


# =========================
# TOGGLE MUSIC
# =========================
func set_music_enabled(enabled: bool):
	music_enabled = enabled

	if not enabled:
		stop()
	elif current_music:
		play_music(current_music, false)
