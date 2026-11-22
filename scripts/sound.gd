extends Node
## A tiny, entirely local synthesizer. No recordings or remote services.
var music: AudioStreamPlayer
var effect: AudioStreamPlayer
var muted := false

func _ready() -> void:
	music = AudioStreamPlayer.new()
	music.volume_db = -24
	add_child(music)
	effect = AudioStreamPlayer.new()
	effect.volume_db = -18
	add_child(effect)

func make_tone(frequencies: Array, duration: float, ambient := false) -> AudioStreamWAV:
	var rate := 22050
	var frames := int(duration * rate)
	var data := PackedByteArray()
	data.resize(frames * 2)
	for i in range(frames):
		var t := float(i) / rate
		var sample := 0.0
		for k in range(frequencies.size()):
			var frequency: float = frequencies[k]
			var env := 0.7 + 0.3 * sin(TAU * t / duration + k) if ambient else exp(-t * 20)
			sample += sin(TAU * frequency * t + (sin(TAU * t / duration) * 0.4 if ambient else 0.0)) * env
		var edge := minf(1, minf(t * 12, (duration - t) * 12))
		data.encode_s16(i * 2, int(clampf(sample / frequencies.size() * edge * 0.65, -1, 1) * 32767))
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = rate
	stream.data = data
	if ambient:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_end = frames
	return stream

func set_chapter(chapter: int) -> void:
	var chords := [[130.8, 196.0, 261.6, 329.6], [110.0, 164.8, 220.0, 293.6], [98.0, 146.8, 196.0, 277.2], [87.3, 130.8, 174.6, 233.0], [65.4, 98.0, 164.8, 246.9], [82.4, 123.5, 185.0, 247.0], [130.8, 196.0, 261.6, 392.0]]
	music.stream = make_tone(chords[clampi(chapter, 0, 6)], 6, true)
	if not muted: music.play()

func play_cue(kind: String) -> void:
	if muted: return
	var notes := [440.0, 660.0]
	match kind:
		"collect": notes = [523.25, 659.25, 783.99]
		"flip": notes = [146.83, 293.66]
		"talk": notes = [330.0]
		"soft": notes = [220.0, 330.0]
	effect.stream = make_tone(notes, 0.18)
	effect.play()

func toggle() -> void:
	muted = not muted
	if muted:
		music.stop()
		effect.stop()
	elif music.stream != null: music.play()
