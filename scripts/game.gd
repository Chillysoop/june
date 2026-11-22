extends "res://scripts/art.gd"
const Journey = preload("res://scripts/journey.gd")
const Sound = preload("res://scripts/sound.gd")
const SAVE_PATH := "user://journey.json"
var save_path := SAVE_PATH
var sound: Node
var menu := true
var paused := false
var journal := false
var confirm_new := false
var checkpoint := -1
var save_warning := ""
var buttons: Array = []
var focus_index := 0
var chapter_fade := 0.0
var qa_mode := false
var last_chapter := -1

func _ready() -> void:
	prepare_art()
	j = Journey.new()
	sound = Sound.new()
	add_child(sound)
	j.chapter_changed.connect(on_chapter_changed)
	j.cue.connect(sound.play_cue)
	for arg in OS.get_cmdline_user_args():
		if arg.begins_with("--capture="):
			qa_mode = true
			capture_all.call_deferred(arg.trim_prefix("--capture="))
		elif arg == "--qa": qa_mode = true
	read_save()
	sound.set_chapter(0)
	queue_redraw()

func _exit_tree() -> void:
	if is_instance_valid(sound):
		sound.music.stop()
		sound.effect.stop()
	if j != null:
		j.chapter_changed.disconnect(on_chapter_changed)
		j.cue.disconnect(sound.play_cue)
	j = null
	body_font = null
	title_font = null
	mono_font = null

func read_save() -> void:
	if qa_mode or not FileAccess.file_exists(save_path): return
	var file := FileAccess.open(save_path, FileAccess.READ)
	if file == null:
		save_warning = "Could not read the checkpoint. You can still play."
		return
	var parser := JSON.new()
	if parser.parse(file.get_as_text()) != OK:
		save_warning = "The checkpoint could not be read. A new journey is available."
		return
	var parsed: Variant = parser.data
	if Journey.valid_checkpoint(parsed):
		checkpoint = int(parsed.chapter)
		sound.muted = parsed.get("muted", false) == true
		j.orbit_help = parsed.get("assist", false) == true
	else:
		save_warning = "The checkpoint could not be read. A new journey is available."

func save_checkpoint() -> void:
	if qa_mode: return
	var file := FileAccess.open(save_path + ".tmp", FileAccess.WRITE)
	if file == null:
		save_warning = "Checkpoint could not be saved. Keep this window open to continue."
		return
	file.store_string(JSON.stringify({"version": 1, "chapter": checkpoint, "muted": sound.muted, "assist": j.orbit_help}))
	file.close()
	var error := DirAccess.rename_absolute(save_path + ".tmp", save_path)
	if error != OK: save_warning = "Checkpoint could not be replaced. Your previous save is intact."

func on_chapter_changed() -> void:
	checkpoint = j.chapter
	chapter_fade = 0.7
	last_chapter = j.chapter
	journal = false
	focus_index = 0
	save_checkpoint()
	sound.set_chapter(j.chapter)
	DisplayServer.window_set_title("June can hear you now — Return to Sender" if j.chapter == 6 else "June: Return to Sender")

func start_journey(index: int) -> void:
	menu = false
	paused = false
	confirm_new = false
	focus_index = 0
	j.begin(index)

func axis_input() -> Vector2:
	var x := float(Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT)) - float(Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT))
	var y := float(Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN)) - float(Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP))
	return Vector2(x, y)

func _process(delta: float) -> void:
	clock += minf(delta, 0.05)
	chapter_fade = maxf(0.0, chapter_fade - delta)
	mouse = get_global_mouse_position()
	if not menu and not paused and not journal:
		j.step(minf(delta, 0.05), axis_input())
		j.align_memory(minf(delta, 0.05), Input.is_physical_key_pressed(KEY_SPACE))
	queue_redraw()

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and not menu and not qa_mode:
		paused = true
		focus_index = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		for button in buttons:
			if button.rect.has_point(get_global_mouse_position()):
				handle_button(button.action)
				get_viewport().set_input_as_handled()
				return
	if not event is InputEventKey or not event.pressed or event.echo: return
	var key: Key = event.physical_keycode
	if key == KEY_F11:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN else DisplayServer.WINDOW_MODE_FULLSCREEN)
		return
	if key == KEY_M:
		sound.toggle()
		if checkpoint >= 0: save_checkpoint()
		return
	if key == KEY_ESCAPE:
		if journal:
			journal = false
		elif confirm_new:
			confirm_new = false
		elif not menu:
			paused = not paused
			focus_index = 0
		return
	if menu or paused or confirm_new:
		if key in [KEY_DOWN, KEY_S, KEY_TAB]: focus_index = (focus_index + 1) % maxi(1, buttons.size())
		elif key in [KEY_UP, KEY_W]: focus_index = posmod(focus_index - 1, maxi(1, buttons.size()))
		elif key in [KEY_ENTER, KEY_SPACE, KEY_E] and not buttons.is_empty(): handle_button(buttons[mini(focus_index, buttons.size() - 1)].action)
		return
	if key == KEY_TAB:
		journal = not journal
		return
	if journal: return
	if key == KEY_H and j.chapter == 4:
		j.orbit_help = not j.orbit_help
		j.hint("A wider light and slower rotation. Take your time." if j.orbit_help else "Original alignment restored.")
		save_checkpoint()
		return
	if key in [KEY_E, KEY_ENTER]: j.action()
	elif key == KEY_SPACE: j.flip()
	elif j.chapter == 2 and j.dialogue.is_empty():
		if key in [KEY_A, KEY_LEFT]: j.door_choice = posmod(j.door_choice - 1, 3)
		elif key in [KEY_D, KEY_RIGHT]: j.door_choice = (j.door_choice + 1) % 3
	elif j.chapter == 3:
		if key in [KEY_1, KEY_2, KEY_3]: j.evidence(key - KEY_1)

func handle_button(action: String) -> void:
	sound.play_cue("talk")
	match action:
		"begin": start_journey(maxi(0, checkpoint))
		"new":
			confirm_new = true
			focus_index = 0
		"confirm": start_journey(0)
		"cancel":
			confirm_new = false
			focus_index = 0
		"resume": paused = false
		"quit": get_tree().quit()
		"menu":
			menu = true
			paused = false
			focus_index = 0
		"outside":
			paused = false
			j.open_outside_door()
		"next": j.dismiss()
		"journal": journal = not journal
		"evidence0": j.evidence(0)
		"evidence1": j.evidence(1)
		"evidence2": j.evidence(2)
		"door0", "door1", "door2":
			j.door_choice = int(action.right(1))
			j.choose_door()

func button(label: String, rect: Rect2, action: String, primary := false) -> void:
	var index := buttons.size()
	var hover := rect.has_point(mouse)
	var focused := index == focus_index and (menu or paused or confirm_new)
	buttons.append({"rect": rect, "action": action})
	var fill: Color = ORANGE if primary else INK
	if hover or focused: fill = GOLD if primary else Color("31565a")
	draw_rect(rect, fill)
	draw_rect(rect, ORANGE if focused and not primary else Color(MINT, 0.4), false, 1)
	centered(label, rect.get_center().x, rect.get_center().y + 7, 19, INK if primary else CREAM)
	if focused: draw_circle(Vector2(rect.position.x + 17, rect.get_center().y), 3, INK if primary else ORANGE)

func draw_hud() -> void:
	box(0, 0, 1280, 120, DARK)
	text_at("RETURN TO SENDER", 35, 35, 15, MINT, mono_font)
	text_at("JUNE", 1143, 35, 15, MINT, mono_font)
	text_at(j.TITLES[j.chapter], 34, 86, 31, CREAM, title_font)
	text_at(j.MODES[j.chapter], 35, 111, 13, MUTED, mono_font)
	for i in range(6):
		box(1060 + i * 25, 72, 16, 3, ORANGE if i <= j.chapter else Color("37504e"))
	line(Vector2(0, 120), Vector2(1280, 120), Color(MINT, 0.3), 1)
	box(0, 660, 1280, 140, DARK)
	line(Vector2(35, 660), Vector2(1245, 660), Color(MINT, 0.3), 1)
	text_at("NEXT", 35, 694, 13, ORANGE, mono_font)
	wrapped(j.objective(), 102, 696, 1125, 20, CREAM)
	var controls := "WASD / ARROWS  Move      E  Interact"
	match j.chapter:
		1: controls = "A / D  Move      SPACE  Flip gravity      E  Enter door"
		2: controls = "LEFT / RIGHT  Choose      E  Enter      Or click a door"
		3: controls = "1 / 2 / 3  Present evidence      Or click a card"
		4: controls = "LEFT / RIGHT  Rotate sky      HOLD SPACE  Remember      H  Assist"
		5: controls = "ESC  The door on your side"
		6: controls = "ESC  Pause      The next chapter will continue this save"
	text_at(controls, 35, 750, 16, MINT, mono_font)
	text_at("TAB  Letter    M  Sound %s    ESC  Pause" % ("off" if sound.muted else "on"), 35, 781, 13, MUTED, mono_font)
	text_at("CHECKPOINT SAVED" if save_warning == "" else "SAVE UNAVAILABLE", 1065, 781, 13, MUTED if save_warning == "" else ORANGE, mono_font)
	if save_warning != "": wrapped(save_warning, 650, 745, 585, 15, ORANGE)

func draw_dialogue() -> void:
	if j.dialogue.is_empty(): return
	box(72, 518, 1136, 130, DARK)
	line(Vector2(72, 518), Vector2(1208, 518), ORANGE, 2)
	text_at(j.dialogue[0][0], 98, 546, 14, ORANGE, mono_font)
	wrapped(j.dialogue[0][1], 98, 580, 895, 23, CREAM, title_font)
	button("E  Continue", Rect2(1020, 583, 163, 43), "next", true)

func draw_journal() -> void:
	box(0, 0, 1280, 800, Color(0.02, 0.08, 0.1, 0.82))
	box(290, 137, 700, 521, CREAM)
	text_at("A LETTER FOR YOU", 340, 198, 17, INK, mono_font)
	line(Vector2(340, 220), Vector2(940, 220), INK, 1)
	text_at("June", 340, 294, 48, INK, title_font)
	text_at("Number Zero, Elsewhere Lane", 340, 337, 26, INK, title_font)
	text_at("To be delivered before it is written.", 340, 379, 21, INK)
	wrapped("When the way is uncertain: first the MOON, then the EYE, then the DOOR.", 340, 459, 570, 24, INK, title_font)
	text_at("The handwriting is yours.", 340, 566, 19, INK)
	for i in range(3):
		box(804 + i * 46, 260, 35, 43, ORANGE if j.stamps[i] else Color("d7c8ab"))
		if j.stamps[i]: star(Vector2(821 + i * 46, 281), 10, CREAM)
	button("TAB / ESC  Close letter", Rect2(485, 589, 310, 45), "journal")

func draw_pause() -> void:
	box(0, 0, 1280, 800, Color(0.02, 0.08, 0.1, 0.90))
	var outside: bool = j.chapter == 5 and j.dialogue.is_empty()
	centered("You can still move." if outside else "Take your time.", 640, 241, 48, CREAM, title_font)
	centered("June is looking at the pause menu." if outside else "The universe will wait. Your chapter is saved.", 640, 288, 22, MINT)
	if outside:
		button("Open the door for June", Rect2(455, 334, 370, 60), "outside", true)
		button("Not quite yet", Rect2(455, 412, 370, 52), "resume")
	else:
		button("Resume", Rect2(455, 334, 370, 60), "resume", true)
		button("Return to title", Rect2(455, 412, 370, 52), "menu")
	button("Quit", Rect2(455, 482, 370, 52), "quit")
	centered("M  Toggle sound     F11  Fullscreen     ESC  Resume", 640, 596, 16, MUTED, mono_font)
	if outside: hero(Vector2(866, 379), 1.3, -1)

func _draw() -> void:
	if j == null: return
	buttons.clear()
	if menu:
		draw_title()
		button("Begin delivery" if checkpoint < 0 else ("Return to June" if checkpoint == 6 else "Continue delivery"), Rect2(80, 529, 325, 61), "begin", true)
		if checkpoint >= 0: button("New journey", Rect2(80, 607, 194, 45), "new")
		button("Quit", Rect2(292 if checkpoint >= 0 else 80, 607, 113, 45), "quit")
		text_at("ARROWS + ENTER  or  MOUSE", 80, 690, 14, MUTED, mono_font)
		if save_warning != "": text_at(save_warning, 80, 770, 14, ORANGE)
	else:
		draw_world()
		draw_hud()
		if j.dialogue.is_empty() and not paused and not journal:
			if j.chapter == 2:
				for i in range(3): buttons.append({"rect": Rect2(335 + i * 240, 274, 130, 256), "action": "door%d" % i})
			elif j.chapter == 3:
				for i in range(3): button("%d  %s" % [i + 1, j.EVIDENCE[i]], Rect2(82 + i * 378, 592, 360, 48), "evidence%d" % i)
		if j.feedback_time > 0 and j.dialogue.is_empty():
			box(72, 609 if j.chapter != 3 else 537, 1136, 42, DARK)
			centered(j.feedback, 640, 637 if j.chapter != 3 else 565, 18, GOLD)
		draw_dialogue()
		if journal:
			buttons.clear()
			draw_journal()
		if paused:
			buttons.clear()
			draw_pause()
		if chapter_fade > 0: box(0, 120, 1280, 540, Color(DARK, chapter_fade * 0.65))
	if confirm_new:
		buttons.clear()
		box(0, 0, 1280, 800, Color(DARK, 0.96))
		centered("Start the delivery again?", 640, 290, 43, CREAM, title_font)
		centered("This replaces your chapter checkpoint.", 640, 343, 23, MINT)
		button("Keep my journey", Rect2(440, 403, 400, 55), "cancel", true)
		button("Start again", Rect2(440, 478, 400, 55), "confirm")

func capture_all(folder: String) -> void:
	DirAccess.make_dir_recursive_absolute(folder)
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(folder.path_join("00-title.png"))
	menu = false
	for index in range(7):
		j.begin(index, false)
		chapter_fade = 0
		if index == 0: j.has_letter = true
		await get_tree().process_frame
		await RenderingServer.frame_post_draw
		get_viewport().get_texture().get_image().save_png(folder.path_join("%02d-chapter.png" % (index + 1)))
	j.begin(5, false)
	paused = true
	chapter_fade = 0
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(folder.path_join("08-pause-door.png"))
	paused = false
	j.begin(4)
	chapter_fade = 0
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(folder.path_join("09-dialogue.png"))
	journal = true
	await get_tree().process_frame
	await RenderingServer.frame_post_draw
	get_viewport().get_texture().get_image().save_png(folder.path_join("10-letter.png"))
	print("NATIVE_CAPTURE_OK: 11 screens")
	sound.music.stop()
	sound.effect.stop()
	await get_tree().create_timer(0.15).timeout
	get_tree().quit()
