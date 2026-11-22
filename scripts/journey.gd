extends RefCounted
## Pure journey state. Rendering and audio never decide progress.
signal chapter_changed
signal cue(kind: String)

const TITLES = ["A perfectly ordinary Tuesday", "The stairs have resigned", "A matter of perspective", "The Department of Depth", "You are not the center", "Outside the story", "Someone is listening"]
const MODES = ["WALKING SIMULATOR", "GRAVITY PLATFORMER", "FIRST-PERSON LABYRINTH", "TURN-BASED TESTIMONY", "ORBITAL PUZZLE", "THE FOURTH WALL", "END OF THE FIRST DELIVERY"]
const STAMP_POSITIONS = [Vector2(330, 211), Vector2(610, 520), Vector2(900, 211)]
const OBSTACLES = [Rect2(430, 405, 65, 155), Rect2(755, 175, 65, 175)]
const ROUTE = [0, 2, 1]
const CLAIMS = ["A letter cannot be delivered to a place that does not exist.", "Even if it exists, you have no proof that you were there.", "And if you are the recipient... who sent the letter?"]
const EVIDENCE = ["THE LETTER", "THE THREE STAMPS", "MY OWN HANDWRITING"]
const ORBIT_TARGETS = [0.65, 3.6, 5.3]

var chapter := 0
var pos := Vector2(180, 485)
var velocity := Vector2.ZERO
var gravity := 1.0
var stamps: Array[bool] = [false, false, false]
var has_letter := false
var dialogue: Array = []
var pending_chapter := -1
var age := 0.0
var moving := false
var facing := 1.0
var moved := false
var flip_count := 0
var flip_cooldown := 0.0
var door_choice := 0
var corridor_step := 0
var verdict := 0
var feedback := ""
var feedback_time := 0.0
var orbit_angle := 2.2
var orbit_step := 0
var orbit_hold := 0.0
var orbit_help := false
var pause_discovered := false
var finished := false

func begin(index: int, intro: bool = true) -> void:
	chapter = clampi(index, 0, 6)
	pos = Vector2(180, 485) if chapter == 0 else Vector2(170, 520)
	velocity = Vector2.ZERO
	gravity = 1.0
	stamps = [chapter > 1, chapter > 1, chapter > 1]
	has_letter = chapter > 0
	dialogue.clear()
	pending_chapter = -1
	age = 0.0
	moved = false
	flip_count = 0
	flip_cooldown = 0.0
	corridor_step = 0
	door_choice = 0
	verdict = 0
	feedback = ""
	orbit_angle = 2.2
	orbit_step = 0
	orbit_hold = 0.0
	pause_discovered = false
	finished = chapter == 6
	chapter_changed.emit()
	if not intro:
		return
	match chapter:
		1: say([["JUNE", "The stairs are gone. There's a note where the stairs used to be."], ["A NOTE", "We have left to pursue a career in jazz. Press SPACE to reconsider which way is down."]])
		2: say([["JUNE", "Oh. I'm looking through my own eyes now. They didn't ask first."], ["THE LETTER", "When the way is uncertain: first the MOON, then the EYE, then the DOOR."]])
		3: say([["THE CLERK", "Welcome to the Department of Depth. You're late. By approximately six oceans."], ["JUNE", "I just need to deliver this letter."], ["THE CLERK", "Naturally. First, prove that you are allowed to exist."]])
		4: say([["THE CLERK", "Approved. Your address is the little house between the stars. We regret that the universe is poorly aligned."], ["JUNE", "I'm not moving anymore. Everything else is."], ["THE LETTER", "Hold LEFT or RIGHT to turn the sky. Bring each memory into the light, then hold SPACE to remember."]])
		5: say([["JUNE", "The envelope is empty. All this way, and there's nothing inside."], ["THE LETTER", "Of course it's empty. You were the message."], ["JUNE", "Wait. Those words at the bottom. The ones telling me how to move. Who are they talking to?"], ["JUNE", "You. There is someone outside this room. I've tried every door. Could you try pausing the game?"]])
		6: say([["JUNE", "I heard you. The world stopped, but you kept going."], ["JUNE", "I used to think someone was writing my story. Now I think... maybe we're writing it together."], ["SOMETHING BEHIND THE SCREEN", "Delivery received. Please remain available for the next impossible thing."]])

func say(lines: Array, next_chapter: int = -1) -> void:
	dialogue = lines.duplicate(true)
	pending_chapter = next_chapter
	cue.emit("talk")

func dismiss() -> void:
	if dialogue.is_empty(): return
	dialogue.pop_front()
	cue.emit("talk")
	if dialogue.is_empty() and pending_chapter >= 0:
		begin(pending_chapter)

func hint(text: String) -> void:
	feedback = text
	feedback_time = 5.0
	cue.emit("soft")

func step(delta: float, axis: Vector2) -> void:
	feedback_time = maxf(0.0, feedback_time - delta)
	flip_cooldown = maxf(0.0, flip_cooldown - delta)
	moving = false
	if not dialogue.is_empty() or finished: return
	age += delta
	if axis.length() > 0.01:
		moved = true
		moving = true
		if axis.x != 0: facing = signf(axis.x)
	match chapter:
		0:
			pos += axis.limit_length() * delta * 220.0
			pos.x = clampf(pos.x, 95, 1180)
			pos.y = clampf(pos.y, 390, 605)
		1:
			velocity.y = clampf(velocity.y + gravity * delta * 970.0, -520.0, 520.0)
			var next_x := pos.x + axis.x * delta * 235.0
			var bounds := Rect2(Vector2(next_x - 15, pos.y - 23), Vector2(30, 46))
			var blocked := false
			for obstacle in OBSTACLES:
				if bounds.intersects(obstacle): blocked = true
			if not blocked: pos.x = clampf(next_x, 110, 1160)
			var next_y := pos.y + velocity.y * delta
			for obstacle in OBSTACLES:
				if pos.x + 15 > obstacle.position.x and pos.x - 15 < obstacle.end.x:
					if velocity.y > 0 and pos.y + 23 <= obstacle.position.y + 1 and next_y + 23 >= obstacle.position.y:
						next_y = obstacle.position.y - 23
						velocity.y = 0
					elif velocity.y < 0 and pos.y - 23 >= obstacle.end.y - 1 and next_y - 23 <= obstacle.end.y:
						next_y = obstacle.end.y + 23
						velocity.y = 0
			pos.y = clampf(next_y, 203, 537)
			if pos.y <= 203 or pos.y >= 537: velocity.y = 0
			for i in range(3):
				if not stamps[i] and pos.distance_to(STAMP_POSITIONS[i]) < 40:
					stamps[i] = true
					hint(["A stamp from tomorrow. It smells like rain.", "A stamp from nowhere. It feels familiar.", "A stamp from home. You haven't been there yet."][i])
					cue.emit("collect")
		4:
			orbit_angle = fposmod(orbit_angle + axis.x * delta * (0.8 if orbit_help else 1.0), TAU)

func action() -> void:
	if not dialogue.is_empty():
		dismiss()
		return
	match chapter:
		0:
			if not has_letter and pos.distance_to(Vector2(335, 420)) < 100:
				has_letter = true
				cue.emit("collect")
				say([["POSTMASTER", "One last delivery, June. Number Zero, Elsewhere Lane."], ["JUNE", "There isn't a number zero."], ["POSTMASTER", "Then it should be easy to find. Oh, and the handwriting looks a lot like yours."]])
			elif pos.distance_to(Vector2(1080, 420)) < 110:
				if has_letter:
					say([["JUNE", "Number Zero. This was a perfectly normal wall a moment ago."], ["THE DOOR", "Please leave your expectations outside."]], 1)
				else: hint("Pick up your last letter at the little post office first.")
			elif pos.distance_to(Vector2(710, 460)) < 95:
				say([["THE CAT", "Meow."], ["JUNE", "Thank you. Something normal."], ["THE CAT", "For now."]])
			else: hint("Walk close to the post office" if not has_letter else "The new door is at the far right. Walk close, then press E.")
		1:
			if pos.x > 1040 and pos.y > 440:
				if stamps.count(true) == 3:
					say([["JUNE", "Three stamps. Not one of them from a real place."], ["THE DOOR", "You are becoming extremely well traveled."]], 2)
				else: hint("The door needs all three stamps. Try the ceiling.")
			else: hint("SPACE changes gravity. Collect the three glowing stamps, then reach the door.")
		2: choose_door()
		3: hint("Choose a piece of evidence with 1, 2, or 3. The letter has followed you all this way.")
		4: hint("Turn the sky with LEFT / RIGHT. Hold SPACE when a memory reaches the light at the top.")
		5: hint("June cannot reach your pause menu. You can. Press ESC.")

func flip() -> void:
	if not dialogue.is_empty():
		dismiss()
		return
	if chapter == 1 and flip_cooldown <= 0:
		gravity *= -1
		velocity.y = 0
		flip_cooldown = 0.25
		flip_count += 1
		cue.emit("flip")

func choose_door() -> void:
	if door_choice == ROUTE[corridor_step]:
		corridor_step += 1
		cue.emit("collect")
		if corridor_step == 3:
			say([["JUNE", "The last door opens underwater. Somehow my socks are still dry."], ["A DISTANT VOICE", "Next applicant, please."]], 3)
		else:
			hint(["", "The moon remembers you. Now follow the EYE.", "The eye watches you leave. Now find the DOOR."][corridor_step])
			door_choice = 0
	else:
		hint("The hallway politely returns you. Follow the " + ["MOON", "EYE", "DOOR"][corridor_step] + ". No progress lost.")

func evidence(index: int) -> void:
	if chapter != 3 or not dialogue.is_empty() or verdict > 2: return
	if index == verdict:
		verdict += 1
		cue.emit("collect")
		match verdict:
			1: say([["JUNE", "Then why does this letter already have its address?"], ["THE CLERK", "A compelling procedural inconvenience. Very well."]])
			2: say([["JUNE", "These stamps are from tomorrow, nowhere, and home. I've been to all three."], ["THE CLERK", "Objection sustained against my own objection."]])
			3: say([["JUNE", "I did. That's my handwriting. But I haven't written it yet."], ["THE CLERK", "Ah. A return delivery. Why didn't you say so?"]], 4)
	else:
		hint(["A good exhibit, but first show the address on THE LETTER.", "The clerk needs proof of travel. Show THE THREE STAMPS.", "Look at the handwriting. Who does it belong to?"][verdict])

func align_memory(delta: float, held: bool) -> void:
	if chapter != 4 or not dialogue.is_empty() or orbit_step >= 3: return
	var distance := absf(wrapf(orbit_angle + ORBIT_TARGETS[orbit_step] + PI / 2, -PI, PI))
	if held and distance < (0.25 if orbit_help else 0.17):
		orbit_hold += delta
		if orbit_hold >= 0.65:
			orbit_step += 1
			orbit_hold = 0
			cue.emit("collect")
			match orbit_step:
				1: say([["A MEMORY", "A small yellow coat. Your first day. Someone says: 'All roads lead somewhere.'"], ["JUNE", "But they don't say who builds the roads."]])
				2: say([["A MEMORY", "A hand writes a letter. Your hand. The paper is the size of the sky."], ["JUNE", "These aren't memories. They're things that haven't happened yet."]])
				3: say([["A MEMORY", "A rectangle of light. Someone on the other side. Watching."], ["JUNE", "I know where to deliver it now."]], 5)
	else:
		orbit_hold = maxf(0.0, orbit_hold - delta * 0.7)

func open_outside_door() -> void:
	if chapter == 5 and dialogue.is_empty():
		pause_discovered = true
		begin(6)

func objective() -> String:
	match chapter:
		0:
			if not moved: return "First, take a few steps. Use WASD or the arrow keys."
			return "Pick up the letter at the post office. Walk close, then press E." if not has_letter else "Deliver the letter to Number Zero. Find the door on the right."
		1: return "Try SPACE. Down is now a matter of opinion." if flip_count == 0 else "Collect the three stamps (%d / 3), then enter the door on the floor." % stamps.count(true)
		2: return "Follow the %s. LEFT / RIGHT to choose; E to enter." % ["MOON", "EYE", "DOOR"][mini(corridor_step, 2)]
		3: return "Answer the clerk's claim. Choose the evidence that contradicts it."
		4: return "Turn the sky. Bring the glowing memory into the top beam; hold SPACE."
		5: return "June needs something only you can do. Press ESC to pause."
		_: return "June knows you're there. This is where the next strange thing begins."

static func valid_checkpoint(value: Variant) -> bool:
	if not value is Dictionary: return false
	return value.get("version") == 1 and value.get("chapter") is float and value.chapter == floor(value.chapter) and value.chapter >= 0 and value.chapter <= 6
