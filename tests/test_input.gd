extends SceneTree
const Game = preload("res://scripts/game.gd")
var checks := 0
var failures := 0
var game

func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: " + description)

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	game._input(event)

func _initialize() -> void:
	run.call_deferred()

func run() -> void:
	game = Game.new()
	game.qa_mode = true
	root.add_child(game)
	await process_frame
	game.start_journey(0)
	key(KEY_ESCAPE)
	check(game.paused, "Escape opens pause")
	var pos: Vector2 = game.j.pos
	game._process(0.05)
	check(game.j.pos == pos, "Pause does not advance gameplay")
	key(KEY_ESCAPE)
	check(not game.paused, "Escape resumes")
	key(KEY_TAB)
	check(game.journal, "Tab opens letter")
	key(KEY_ESCAPE)
	check(not game.journal and not game.paused, "Escape closes letter without opening pause")
	game.j.begin(2, false)
	key(KEY_RIGHT)
	check(game.j.door_choice == 1, "Right chooses next corridor door")
	key(KEY_LEFT)
	key(KEY_E)
	check(game.j.corridor_step == 1, "E enters selected door")
	game.j.begin(3, false)
	key(KEY_2)
	check(game.j.verdict == 0, "Incorrect number-key evidence preserves progress")
	key(KEY_1)
	check(game.j.verdict == 1 and not game.j.dialogue.is_empty(), "Number-key evidence opens correct response")
	key(KEY_E)
	key(KEY_SPACE)
	check(game.j.dialogue.is_empty(), "Both E and Space advance dialogue")
	game.j.begin(4, false)
	key(KEY_H)
	check(game.j.orbit_help, "Assist toggle available for orbital puzzle")
	key(KEY_M)
	check(game.sound.muted, "Sound toggle silences synth")
	game.j.begin(5, false)
	key(KEY_ESCAPE)
	check(game.paused, "Fourth wall uses genuine pause input")
	game.handle_button("outside")
	check(game.j.chapter == 6 and not game.paused, "Pause action opens the outside door")
	game.handle_button("menu")
	game.handle_button("new")
	check(game.confirm_new, "New game requires explicit overwrite choice")
	key(KEY_ESCAPE)
	check(not game.confirm_new and game.checkpoint == 6, "Cancel preserves completion checkpoint")
	game.handle_button("begin")
	check(game.j.chapter == 6, "Continue restores completion for future expansion")
	game._notification(game.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(not game.paused, "QA is isolated from desktop focus")
	game.qa_mode = false
	game._notification(game.NOTIFICATION_APPLICATION_FOCUS_OUT)
	check(game.paused, "Ordinary game pauses when focus is lost")
	game.qa_mode = true
	# Exercise real atomic file replacement in an isolated test-owned path.
	game.save_path = "user://test-checkpoint-%d.json" % Time.get_ticks_usec()
	game.qa_mode = false
	game.checkpoint = 4
	game.sound.muted = true
	game.j.orbit_help = true
	game.save_checkpoint()
	check(FileAccess.file_exists(game.save_path) and game.save_warning == "", "Initial checkpoint writes successfully")
	game.checkpoint = 6
	game.save_checkpoint()
	game.checkpoint = -1
	game.sound.muted = false
	game.j.orbit_help = false
	game.read_save()
	check(game.checkpoint == 6, "Atomic replacement restores the newer checkpoint")
	check(game.sound.muted and game.j.orbit_help, "Sound and assist preferences persist")
	check(not FileAccess.file_exists(game.save_path + ".tmp"), "Successful atomic replacement leaves no temp file")
	var broken := FileAccess.open(game.save_path, FileAccess.WRITE)
	broken.store_string("malformed test checkpoint")
	broken.close()
	game.checkpoint = -1
	game.read_save()
	check(game.checkpoint == -1 and not game.save_warning.is_empty(), "Malformed save allows a clear new-game fallback")
	check(FileAccess.get_file_as_string(game.save_path) == "malformed test checkpoint", "Reading an invalid checkpoint never overwrites it")
	DirAccess.remove_absolute(game.save_path)
	game.qa_mode = true
	print("INPUT TESTS: %d checks, %d failures" % [checks, failures])
	game.queue_free()
	await process_frame
	quit(1 if failures else 0)
