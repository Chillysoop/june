extends SceneTree
const Journey = preload("res://scripts/journey.gd")
var checks := 0
var failures := 0

func check(value: bool, description: String) -> void:
	checks += 1
	if not value:
		failures += 1
		printerr("FAIL: " + description)

func dismiss_all(j) -> void:
	for i in range(30):
		if j.dialogue.is_empty(): return
		j.dismiss()
	check(false, "Dialogue can finish")

func walk(j, target: float) -> void:
	for i in range(900):
		if absf(j.pos.x - target) < 2 or not j.dialogue.is_empty(): return
		j.step(1.0 / 60.0, Vector2(clampf((target - j.pos.x) / 3.75, -1, 1), 0))
	check(false, "Route reaches x=%s from %s" % [target, j.pos])

func settle(j) -> void:
	for i in range(100): j.step(1.0 / 60.0, Vector2.ZERO)

func _initialize() -> void:
	var j = Journey.new()
	# The old epilogue now has a genuine exit into the new story.
	j.begin(6, false)
	j.action()
	dismiss_all(j)
	check(j.chapter == 7 and not j.finished, "Fresh first-delivery finish can enter The Margins")
	check(j.has_letter and j.stamps.count(true) == 3, "The same letter and three stamps continue")
	check(j.bridge == -1 and j.pieces.count(true) == 0, "Safe first lesson introduces only the unplaced bridge")
	# Deliberate mistake: walk into the gap before placing any word.
	for i in range(140): j.step(1.0 / 60.0, Vector2.RIGHT)
	check(j.rescue_count > 0, "Empty text cannot support June; falling returns safely")
	check(j.chapter == 7 and j.pos.y <= 640, "Recovery stays in this room without game over")
	j.begin(7, false)
	j.pin_word(0)
	check(j.bridge == 0, "Player can make HERE solid on floor")
	walk(j, 950)
	check(j.pieces[0] and not j.pieces[1], "Walking over physical word collects I")
	check(j.safe_pos.x > 915, "Far bank becomes a safe recovery anchor")
	j.action()
	check(j.chapter == 7, "One word cannot open the next room")
	j.pin_word(1)
	j.flip()
	settle(j)
	check(absf(j.pos.y - 203) < 1, "Learned gravity flip reaches ceiling bank")
	walk(j, 625)
	check(j.pieces.count(true) == 2, "Word placement plus gravity collects AM")
	# Move the platform away on purpose: words remain collected.
	j.pin_word(0)
	settle(j)
	check(j.rescue_count == 1 and j.pieces.count(true) == 2, "Removing support preserves words and returns to bank")
	j.pin_word(1)
	walk(j, 1100)
	j.flip()
	settle(j)
	j.action()
	dismiss_all(j)
	check(j.chapter == 8, "I AM opens the living minute")
	check(not j.remember_here(), "Cannot create a useful echo away from plate")
	for i in range(140): j.step(1.0 / 60.0, Vector2.RIGHT)
	check(j.pos.x <= 490.01, "Closed memory gate physically stops June")
	walk(j, 270)
	settle(j)
	check(j.can_remember(), "Grounded moon plate is a valid anchor")
	check(j.remember_here() and j.echo_on_moon(), "Memory holds moon plate")
	var remembered: Vector2 = j.echo_pos
	j.flip()
	settle(j)
	walk(j, 850)
	check(j.echo_pos == remembered, "Memory stays behind while living June moves")
	check(j.gate_latched and j.pos.distance_to(j.EYE_PLATE) < 38, "Past and present cooperate across floor and ceiling")
	dismiss_all(j)
	walk(j, 1100)
	j.flip()
	settle(j)
	j.action()
	dismiss_all(j)
	check(j.chapter == 9 and j.world_view, "WITH leads outside the recursive world")
	j.pin_word()
	check(not j.world_pinned, "World cannot be pinned outside beam")
	var still: Vector2 = j.pos
	for i in range(30): j.step(1.0 / 60.0, Vector2.RIGHT)
	check(j.pos == still, "Turning world from outside doesn't move June")
	for i in range(600):
		var difference := wrapf(-PI / 2 - j.world_angle, -PI, PI)
		if absf(difference) < 0.02: break
		j.step(1.0 / 60.0, Vector2(signf(difference), 0))
	j.pin_word()
	check(j.world_pinned, "Learned orbital alignment plus new pin anchors world")
	dismiss_all(j)
	var angle: float = j.world_angle
	j.step(1.0, Vector2.RIGHT)
	check(j.world_angle == angle, "Pinned world stays still while June crosses")
	j.change_view()
	check(not j.world_view, "Player can step into the world they just turned")
	walk(j, 270)
	settle(j)
	check(j.remember_here(), "Final room accepts learned memory ability")
	j.flip()
	settle(j)
	walk(j, 640)
	check(j.has_you, "Pinned world plus memory plus ceiling walk collects YOU")
	dismiss_all(j)
	walk(j, 1100)
	j.flip()
	settle(j)
	j.action()
	dismiss_all(j)
	check(j.chapter == 10 and j.finished, "Shared sentence completes the next chapter")
	check(j.has_you and j.pieces.count(true) == 2, "Completed sentence reconstructs all earned words")
	# Every old save remains valid; old completion migrates without replaying act one.
	for chapter in range(7):
		var old: Variant = JSON.parse_string(JSON.stringify({"version": 1, "chapter": chapter, "muted": true, "assist": true}))
		var migrated: Dictionary = Journey.migrated_checkpoint(old)
		check(migrated.get("chapter") == (7 if chapter == 6 else chapter), "Version-one chapter %d migrates correctly" % chapter)
		check(migrated.get("version") == 2 and migrated.get("muted", false) and migrated.get("assist", false), "Migration preserves both preferences for chapter %d" % chapter)
	for chapter in range(11):
		var payload: Variant = JSON.parse_string(JSON.stringify({"version": 2, "chapter": chapter}))
		check(Journey.valid_checkpoint(payload) and Journey.migrated_checkpoint(payload).chapter == chapter, "Schema-two checkpoint %d round trips" % chapter)
		j.begin(chapter, false)
		check(j.chapter == chapter and j.finished == (chapter == 10), "Checkpoint %d restores the correct completion state" % chapter)
	for value in [{"version": 2, "chapter": 11}, {"version": 2, "chapter": -1}, {"version": 2, "chapter": 8.25}, {"version": 9, "chapter": 7}, {"version": 1, "chapter": 8}, {"version": 2, "chapter": "8"}]:
		check(not Journey.valid_checkpoint(value), "Reject invalid migration %s" % value)
	j.begin(8, false)
	j.pos = Vector2(270, 510)
	check(not j.can_remember(), "An airborne June cannot stamp an echo onto a plate")
	j.pos = j.MOON_PLATE
	j.velocity.y = 0
	j.say([["JUNE", "Wait."]])
	check(not j.remember_here(), "Dialogue cannot be bypassed with a memory action")
	j.begin(9, false)
	j.pos = j.MOON_PLATE
	check(not j.can_remember(), "Outside perspective cannot place an inside echo")
	j.world_view = false
	j.remember_here()
	check(j.margin_surfaces().size() == 4, "Echo alone cannot produce final bridge without pinning")
	j.world_pinned = true
	check(j.margin_surfaces().size() == 5, "Both independent conditions produce the ceiling bridge")
	j.has_you = true
	j.pos = Vector2(640, 537)
	settle(j)
	check(j.rescue_count > 0 and j.has_you and j.echo_on_moon() and j.world_pinned, "Final-room recovery preserves YOU, memory, and pin")
	j.hint("A previous room")
	j.begin(10, false)
	check(j.feedback.is_empty() and j.feedback_time == 0, "Room transition clears transient feedback completely")
	print("MARGINS TESTS: %d checks, %d failures" % [checks, failures])
	quit(1 if failures else 0)
