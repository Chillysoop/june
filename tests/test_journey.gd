extends SceneTree
const Journey = preload("res://scripts/journey.gd")
const Game = preload("res://scripts/game.gd")
var checks := 0
var failures := 0

func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: " + description)

func dismiss_all(j) -> void:
	var guard := 0
	while not j.dialogue.is_empty() and guard < 20:
		j.dismiss()
		guard += 1

func walk_x(j, target: float) -> void:
	for i in range(900):
		if absf(j.pos.x - target) < 2: return
		j.step(1.0 / 60.0, Vector2(clampf((target - j.pos.x) / 3.91, -1, 1), 0))
	check(false, "Route can reach x=%s from %s" % [target, j.pos])

func settle(j) -> void:
	for i in range(100): j.step(1.0 / 60.0, Vector2.ZERO)

func _initialize() -> void:
	var j = Journey.new()
	j.begin(0, false)
	check(not j.has_letter and not j.moved, "Gentle start: only walking introduced")
	j.action()
	check(j.chapter == 0 and not j.has_letter, "Cannot remotely collect letter")
	for i in range(40): j.step(1.0 / 60.0, Vector2(1, -0.4))
	j.action()
	check(j.has_letter, "Reach post office through normal movement")
	var still: Vector2 = j.pos
	j.step(1.0, Vector2.RIGHT)
	check(j.pos == still, "Dialogue pauses movement")
	dismiss_all(j)
	walk_x(j, 1080)
	j.action()
	dismiss_all(j)
	check(j.chapter == 1 and j.has_letter, "Letter carries across first genre change")
	# Play the entire gravity route using movement and flips, never teleporting.
	j.flip()
	walk_x(j, 330)
	settle(j)
	check(j.stamps[0], "First ceiling stamp reachable in safe practice area")
	walk_x(j, 610)
	j.flip()
	settle(j)
	check(j.stamps[1], "Ground stamp reachable past first pillar")
	walk_x(j, 900)
	j.flip()
	settle(j)
	check(j.stamps[2], "Third stamp reachable past ceiling obstruction")
	walk_x(j, 1090)
	j.flip()
	settle(j)
	j.action()
	dismiss_all(j)
	check(j.chapter == 2 and j.stamps.count(true) == 3, "All stamps carry into first person")
	j.door_choice = 1
	j.choose_door()
	check(j.corridor_step == 0 and not j.feedback.is_empty(), "Wrong door offers a hint without penalty")
	for correct in [0, 2, 1]:
		j.door_choice = correct
		j.choose_door()
	dismiss_all(j)
	check(j.chapter == 3, "Moon-eye-door route enters courtroom")
	j.evidence(2)
	check(j.verdict == 0, "Wrong evidence gives guidance without losing progress")
	for correct in range(3):
		j.evidence(correct)
		dismiss_all(j)
	check(j.chapter == 4, "Accumulated evidence wins hearing")
	j.align_memory(1, true)
	check(j.orbit_step == 0, "Cannot remember outside alignment beam")
	for memory in range(3):
		var target: float = fposmod(-PI / 2 - j.ORBIT_TARGETS[memory], TAU)
		for i in range(600):
			var difference := wrapf(target - j.orbit_angle, -PI, PI)
			if absf(difference) < 0.02: break
			j.step(1.0 / 60.0, Vector2(signf(difference), 0))
		for i in range(45): j.align_memory(1.0 / 60.0, true)
		dismiss_all(j)
	check(j.chapter == 5, "Three aligned memories reach fourth-wall scene")
	j.action()
	check(j.chapter == 5, "Ordinary interact cannot bypass the interface puzzle")
	j.open_outside_door()
	check(j.chapter == 6 and j.finished, "Player's pause-menu door completes the first delivery")
	dismiss_all(j)
	check(j.dialogue.is_empty(), "Ending dialogue completes without a soft lock")
	for chapter in range(7):
		var save: Variant = JSON.parse_string(JSON.stringify({"version": 1, "chapter": chapter}))
		check(Journey.valid_checkpoint(save), "Checkpoint %d round trips through JSON" % chapter)
		j.begin(chapter, false)
		check(j.chapter == chapter and j.dialogue.is_empty(), "Checkpoint %d restores cleanly" % chapter)
	for payload in ["null", "[]", "{}", '{"version":2,"chapter":1}', '{"version":1,"chapter":-1}', '{"version":1,"chapter":7}', '{"version":1,"chapter":1.5}', '{"version":1,"chapter":"1"}']:
		check(not Journey.valid_checkpoint(JSON.parse_string(payload)), "Reject unsafe checkpoint: " + payload)
	# Collision and input edge protection.
	j.begin(1, false)
	j.flip()
	var gravity: float = j.gravity
	j.flip()
	check(j.gravity == gravity, "Held/repeated flip cannot double-trigger")
	for i in range(500): j.step(1.0 / 60.0, Vector2.LEFT)
	check(j.pos.x >= 110 and j.pos.y >= 203, "Gravity arena remains bounded")
	j.begin(0, false)
	for i in range(500): j.step(1.0 / 60.0, Vector2(-1, -1))
	check(j.pos.x >= 95 and j.pos.y >= 390, "Town remains in walkable area")
	print("JOURNEY TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
