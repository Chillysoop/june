extends RefCounted
## Pure journey state. Rendering and audio never decide progress.
signal chapter_changed
signal cue(kind: String)

const TITLES = ["A perfectly ordinary Tuesday", "The stairs have resigned", "A matter of perspective", "The Department of Depth", "You are not the center", "Outside the story", "Someone is listening", "Please hold this thought", "A minute with teeth", "A door in the pupil", "The other side has a street"]
const MODES = ["WALKING SIMULATOR", "GRAVITY PLATFORMER", "FIRST-PERSON LABYRINTH", "TURN-BASED TESTIMONY", "ORBITAL PUZZLE", "THE FOURTH WALL", "THE FIRST DELIVERY", "THE MARGINS  /  WORDS BECOME MATTER", "THE MARGINS  /  COOPERATE WITH A MEMORY", "THE MARGINS  /  INSIDE & OUTSIDE", "THE MARGINS  /  A LETTER WRITTEN TOGETHER"]
const LAST_CHAPTER = 10
const BANKS = [Rect2(90, 560, 300, 25), Rect2(890, 560, 300, 25), Rect2(90, 155, 300, 25), Rect2(890, 155, 300, 25)]
const MOON_PLATE = Vector2(270, 537)
const EYE_PLATE = Vector2(850, 203)
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
var bridge := -1
var pieces: Array[bool] = [false, false]
var safe_pos := Vector2(180, 537)
var safe_gravity := 1.0
var echo_active := false
var echo_pos := Vector2.ZERO
var echo_gravity := 1.0
var gate_latched := false
var world_view := false
var world_angle := 1.0
var world_pinned := false
var has_you := false
var rescue_count := 0

func begin(index: int, intro: bool = true) -> void:
	chapter = clampi(index, 0, LAST_CHAPTER)
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
	feedback_time = 0.0
	orbit_angle = 2.2
	orbit_step = 0
	orbit_hold = 0.0
	pause_discovered = false
	finished = chapter == LAST_CHAPTER
	bridge = -1
	pieces = [chapter > 7, chapter > 7]
	safe_pos = Vector2(180, 537)
	safe_gravity = 1.0
	echo_active = false
	echo_pos = Vector2.ZERO
	echo_gravity = 1.0
	gate_latched = false
	world_view = chapter == 9
	world_angle = 1.0
	world_pinned = false
	has_you = chapter == LAST_CHAPTER
	rescue_count = 0
	if chapter in [7, 8, 9]: pos = safe_pos
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
		7: say([["JUNE", "You're still here. Good. The back of the letter has become a place."], ["THE MARGIN", "UNAUTHORIZED READER DETECTED. Please do not give the characters ideas."], ["JUNE", "Too late. See that dotted bridge? I can't touch it. But you can make the word HERE true."], ["JUNE", "Press F to put HERE on the floor. Let's try crossing it together."]])
		8: say([["JUNE", "The room is a minute. I can see its teeth."], ["THE MINUTE", "ONE PERSON MUST REMAIN IN THE PAST. STANDARD DOOR POLICY."], ["JUNE", "You stopped time before. Could you leave a memory of me on that moon plate?"], ["JUNE", "Walk onto the moon. Press ESC, then Keep a memory here. I'll keep going; the memory can stay."]])
		9: say([["JUNE", "That enormous eye... the room we just left was inside it."], ["THE MARGIN", "PLEASE RETURN THE READER TO THEIR DESIGNATED SIDE."], ["JUNE", "They're not cargo. And I'm not a message anymore."], ["JUNE", "You're outside the world now. Turn it with LEFT or RIGHT, like the sky. Line the moon up with the top beam, then pin it with F."]])
		10: say([["JUNE", "I AM WITH YOU. Four words. Neither of us could have written them alone."], ["THE LETTER", "TO: THE ONE HOLDING THE WORLD. FROM: SOMEONE WHO IS NO LONGER HERE."], ["JUNE", "Someone crossed out the sender. They crossed out a whole person."], ["JUNE", "Then that's our next delivery. Find whoever is missing. And this time... I'll keep a place for you."]])

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
		7, 8, 9:
			if chapter == 9 and world_view:
				moving = false
				if not world_pinned: world_angle = fposmod(world_angle + axis.x * delta * (0.8 if orbit_help else 1.0), TAU)
			else: step_margin(delta, axis.x)

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
		6:
			say([["JUNE", "There's writing on the other side of the letter now. It says: PLEASE HOLD."], ["JUNE", "I think it's talking to both of us. Ready?"]], 7)
		7:
			if pos.x > 1040 and pos.y > 470:
				if pieces.count(true) == 2:
					say([["JUNE", "I. AM. The first two words I've ever picked up off a ceiling."], ["THE MARGIN", "Characters may not assemble their own sentences."], ["JUNE", "Put that in writing. We could use another bridge."]], 8)
				else: hint("Bring both words: I on the floor, AM on the ceiling. F moves HERE; SPACE flips gravity.")
			else: hint("F moves the word HERE between floor and ceiling. Gather I and AM, then reach the right door.")
		8:
			if pos.x > 1060 and pos.y > 470:
				if gate_latched:
					say([["JUNE", "My memory stayed behind, but I remember being both of us. That seems medically unlikely."], ["THE MINUTE", "WITH. You have earned a conjunction. Please use it responsibly."]], 9)
				else: hint("Your memory holds the moon. Flip to the ceiling and touch the eye to earn WITH.")
			else: hint("Stand on the floor's moon plate, then ESC > Keep a memory here. Flip to the ceiling eye.")
		9:
			if world_view:
				hint("Line the moon up with the top beam. F pins the world; C returns to June.")
			elif pos.x > 1040 and pos.y > 470 and has_you:
				say([["THE MARGIN", "Final objection: there is no YOU in this world."], ["JUNE", "Then explain who has been holding it together."], ["JUNE", "Let's finish the sentence."]], 10)
			else: hint("Pin the sky, leave a memory on the moon, flip to the ceiling, and collect YOU. The door is on the right.")
		10: hint("The next delivery will begin here. June has kept your place.")

func flip() -> void:
	if not dialogue.is_empty():
		dismiss()
		return
	if chapter in [1, 7, 8, 9] and not world_view and flip_cooldown <= 0:
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
		6: return "The back of the letter is changing. Press E to turn it over."
		7:
			if bridge < 0: return "A word can be a bridge. Press F to put HERE on the floor."
			if not pieces[0]: return "Walk across HERE to collect I. The dotted spaces cannot hold you yet."
			if not pieces[1]: return "From a safe bank: F moves HERE to the ceiling. SPACE flips gravity. Collect AM."
			return "You have I AM. Reach the right-hand door on the floor, then press E."
		8:
			if not echo_on_moon(): return "Stand on the moon plate. ESC > Keep a memory here. Your memory can hold the door."
			if not gate_latched: return "Leave your memory on the moon. SPACE flips gravity; walk to the ceiling eye."
			return "You earned WITH. Flip down, then enter the right-hand door with E."
		9:
			if not world_pinned: return "You're outside. LEFT / RIGHT turns the world; F pins the moon into the top beam."
			if world_view: return "The world is pinned. Press C to return inside it."
			if not echo_on_moon(): return "Now cooperate with your past self. Stand on the moon; ESC > Keep a memory here."
			if not has_you: return "Your memory holds the ceiling bridge. Flip up with SPACE and cross it to collect YOU."
			return "I AM WITH YOU. Reach the far bank, flip down, and enter the door with E."
		_: return "June has kept a place for you. The next impossible delivery starts here."

func echo_on_moon() -> bool:
	return echo_active and echo_gravity > 0 and echo_pos.distance_to(MOON_PLATE) < 42

func can_remember() -> bool:
	return chapter in [8, 9] and dialogue.is_empty() and not world_view and gravity > 0 and absf(pos.x - MOON_PLATE.x) < 42 and absf(pos.y - MOON_PLATE.y) < 1 and velocity.y == 0

func remember_here() -> bool:
	if not can_remember():
		hint("A memory needs an anchor. Stand on the gold moon plate on the floor first.")
		return false
	echo_active = true
	echo_pos = pos
	echo_gravity = gravity
	cue.emit("echo")
	hint("Your memory will hold the moon. You can go on. SPACE still changes down.")
	return true

func pin_word(side: int = -1) -> void:
	if not dialogue.is_empty(): return
	if chapter == 7:
		bridge = side if side in [0, 1] else (0 if bridge != 0 else 1)
		cue.emit("pin")
		hint("HERE is on the floor. A word you can stand on." if bridge == 0 else "HERE is on the ceiling. SPACE lets June meet it there.")
	elif chapter == 9:
		if not world_view:
			hint("C lets you look from outside again. The ceiling bridge needs your memory on the moon.")
		elif world_pinned:
			hint("The world is safely pinned. C returns to June.")
		elif moon_alignment() < (0.26 if orbit_help else 0.18):
			world_pinned = true
			cue.emit("pin")
			say([["JUNE", "You held the whole world still. I felt that. Like someone putting a hand on my shoulder."], ["JUNE", "Press C to come back inside. Then we can do the impossible part together."]])
		else: hint("Almost. Turn until the moon reaches the gold beam at the top, then press F. H widens the beam.")

func moon_alignment() -> float:
	return absf(wrapf(world_angle + PI / 2, -PI, PI))

func change_view() -> void:
	if chapter != 9 or not dialogue.is_empty(): return
	world_view = not world_view
	moving = false
	cue.emit("flip")

func margin_surfaces() -> Array:
	if chapter == 8:
		var surfaces: Array = [Rect2(90, 560, 1100, 25), Rect2(90, 155, 1100, 25)]
		if not echo_on_moon() and not gate_latched: surfaces.append(Rect2(505, 180, 42, 380))
		return surfaces
	var surfaces := BANKS.duplicate()
	if chapter == 7 and bridge >= 0: surfaces.append(Rect2(390, 560 if bridge == 0 else 155, 500, 25))
	if chapter == 9 and world_pinned and echo_on_moon(): surfaces.append(Rect2(390, 155, 500, 25))
	return surfaces

func step_margin(delta: float, axis: float) -> void:
	var surfaces := margin_surfaces()
	velocity.y = clampf(velocity.y + gravity * delta * 970.0, -520.0, 520.0)
	var next_x := clampf(pos.x + axis * delta * 225.0, 110, 1160)
	var bounds := Rect2(Vector2(next_x - 15, pos.y - 22), Vector2(30, 44))
	var blocked := false
	for surface in surfaces:
		if bounds.intersects(surface): blocked = true
	if not blocked: pos.x = next_x
	var next_y := pos.y + velocity.y * delta
	for surface in surfaces:
		if pos.x + 15 > surface.position.x and pos.x - 15 < surface.end.x:
			if velocity.y > 0 and pos.y + 23 <= surface.position.y + 1 and next_y + 23 >= surface.position.y:
				next_y = surface.position.y - 23
				velocity.y = 0
			elif velocity.y < 0 and pos.y - 23 >= surface.end.y - 1 and next_y - 23 <= surface.end.y:
				next_y = surface.end.y + 23
				velocity.y = 0
	pos.y = next_y
	if pos.y > 640 or pos.y < 125:
		pos = safe_pos
		gravity = safe_gravity
		velocity = Vector2.ZERO
		rescue_count += 1
		hint("I've got you. Back to the last bank. All collected words are safe.")
	if (pos.x < 365 or pos.x > 915) and velocity.y == 0 and (absf(pos.y - 537) < 1 or absf(pos.y - 203) < 1):
		safe_pos = pos
		safe_gravity = gravity
	if chapter == 7:
		for i in range(2):
			var target := Vector2(625, 537 if i == 0 else 203)
			if not pieces[i] and bridge == i and pos.distance_to(target) < 34:
				pieces[i] = true
				cue.emit("collect")
				hint("I. Your first word. Take it to the far bank before moving HERE." if i == 0 else "AM. I AM. That's a start. The door is on the right, down on the floor.")
	elif chapter == 8 and echo_on_moon() and not gate_latched and pos.distance_to(EYE_PLATE) < 38:
		gate_latched = true
		cue.emit("collect")
		say([["THE MINUTE", "PARADOX ACCEPTED. One June in the past. One June in the present."], ["JUNE", "And someone outside time, keeping us both company. I think the next word is WITH."]])
	elif chapter == 9 and world_pinned and echo_on_moon() and not has_you and pos.distance_to(Vector2(640, 203)) < 35:
		has_you = true
		cue.emit("collect")
		say([["JUNE", "YOU. There it is. Right in the middle of the sentence."], ["THE MARGIN", "A READER IS NOT A CHARACTER."], ["JUNE", "No. They're my friend. Keep holding the world. I'm nearly across."]])

static func migrated_checkpoint(value: Variant) -> Dictionary:
	if not value is Dictionary: return {}
	var version: Variant = value.get("version")
	var saved: Variant = value.get("chapter")
	if not (version is float or version is int) or (version != 1 and version != 2) or not (saved is float or saved is int): return {}
	if saved != floor(saved) or saved < 0 or saved > (6 if version == 1 else LAST_CHAPTER): return {}
	return {"version": 2, "chapter": 7 if version == 1 and saved == 6 else int(saved), "muted": value.get("muted", false) == true, "assist": value.get("assist", false) == true}

static func valid_checkpoint(value: Variant) -> bool:
	return not migrated_checkpoint(value).is_empty()
