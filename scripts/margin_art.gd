extends "res://scripts/art.gd"
## The second delivery leaves illustration for typography, clockwork and recursion.
const PAPER = Color("e4dfcd")
const CORRECTION = Color("be4b56")
const VIOLET = Color("a8a0f0")

func dashed(a: Vector2, b: Vector2, color: Color, width := 2.0) -> void:
	var distance := a.distance_to(b)
	var direction := (b - a).normalized()
	for i in range(int(distance / 20)):
		line(a + direction * i * 20, a + direction * (i * 20 + 10), color, width)

func margin_door(color: Color = INK) -> void:
	box(1080, 452, 68, 108, color)
	box(1090, 462, 48, 98, PAPER)
	centered("?", 1114, 503, 28, INK, title_font)
	draw_circle(Vector2(1126, 528), 3, CORRECTION)
	centered("E", 1114, 435, 16, color, mono_font)

func draw_banks(color: Color) -> void:
	for surface in j.BANKS:
		draw_rect(surface, color)
		for x in range(int(surface.position.x) + 10, int(surface.end.x), 24):
			line(Vector2(x, surface.position.y + 3), Vector2(x + 12, surface.end.y - 3), Color(PAPER, 0.18), 1)

func plate(p: Vector2, ceiling: bool, active: bool, icon: int) -> void:
	var y := p.y - 23 if ceiling else p.y + 23
	box(p.x - 37, y - 3, 74, 6, GOLD if active else MUTED)
	var glyph := Vector2(p.x, y + 43 if ceiling else y - 72)
	draw_circle(glyph, 22, Color(GOLD, 0.12))
	symbol(icon, glyph, 14, GOLD if active else MINT)
	line(Vector2(p.x, y), glyph, Color(MINT, 0.25), 1)

func draw_echo() -> void:
	if not j.echo_active: return
	for i in range(3):
		draw_arc(j.echo_pos, 32 + i * 9, PI * 0.15, PI * 0.9, 24, Color(VIOLET, 0.35 - i * 0.08), 1, true)
	# Wireframe silhouette distinguishes the remembered June from the living one.
	var p: Vector2 = j.echo_pos
	draw_arc(p + Vector2(0, -25), 13, 0, TAU, 24, VIOLET, 2, true)
	line(p + Vector2(-18, -33), p + Vector2(18, -33), VIOLET, 3)
	for points in [[Vector2(-12, -11), Vector2(12, -11)], [Vector2(-12, -11), Vector2(-18, 13)], [Vector2(12, -11), Vector2(18, 13)], [Vector2(-18, 13), Vector2(18, 13)], [Vector2(-7, 13), Vector2(-10, 23)], [Vector2(7, 13), Vector2(10, 23)]]:
		line(p + points[0], p + points[1], VIOLET, 2)
	centered("A MOMENT AGO", p.x, p.y + 58, 13, VIOLET, mono_font)

func draw_margin_page() -> void:
	box(0, 120, 1280, 540, PAPER)
	for y in range(150, 650, 31): line(Vector2(65, y), Vector2(1215, y), Color(INK, 0.07), 1)
	line(Vector2(70, 120), Vector2(70, 660), Color(CORRECTION, 0.4), 1)
	text_at("PLEASE DO NOT WRITE BETWEEN THE WORLDS", 93, 143, 13, CORRECTION, mono_font)
	# Cut-out banks and the two possible positions of a physical word.
	draw_banks(INK)
	for side in range(2):
		var y := 560 if side == 0 else 155
		var selected: bool = j.bridge == side
		if selected:
			box(390, y, 500, 25, CORRECTION)
			centered("H E R E", 640, y + 20, 20, PAPER, mono_font)
		else:
			dashed(Vector2(390, y + 12), Vector2(890, y + 12), Color(CORRECTION, 0.55))
			centered("click to put HERE " + ("below" if side == 0 else "above"), 640, y + 45 if side == 0 else y - 10, 14, CORRECTION, mono_font)
	centered("THERE IS", 640, 313, 52, Color(INK, 0.75), title_font)
	centered("NO", 640, 388, 71, Color(INK, 0.22), title_font)
	if j.bridge >= 0:
		line(Vector2(552, 362), Vector2(724, 334), CORRECTION, 5)
		line(Vector2(557, 377), Vector2(728, 349), CORRECTION, 3)
	centered("GROUND FOR THIS CLAIM.", 640, 430, 25, Color(INK, 0.65), title_font)
	text_at("YOU MAY DISAGREE.", 876, 390, 14, CORRECTION, mono_font)
	line(Vector2(870, 380), Vector2(750, 362), CORRECTION, 1)
	for i in range(2):
		var p := Vector2(625, 507 if i == 0 else 232)
		if not j.pieces[i]:
			var word := "I" if i == 0 else "AM"
			box(p.x - 39, p.y - 25, 78, 40, INK)
			centered(word, p.x, p.y + 3, 28, GOLD, title_font)
		else:
			text_at("I" if i == 0 else "AM", 118 + i * 48, 339, 31, CORRECTION, title_font)
	text_at("YOUR SENTENCE", 118, 293, 13, INK, mono_font)
	margin_door()
	hero(j.pos, 1, j.facing, j.moving, j.gravity < 0)
	grain(Color(INK, 0.14), 130, 650)

func draw_clock_room() -> void:
	box(0, 120, 1280, 540, Color("17172b"))
	# The architecture is a broken clock with an open jaw, not a backdrop of gears.
	var center := Vector2(659, 365)
	ellipse(center, Vector2(488, 196), Color("24243e"))
	for i in range(48):
		var a := i * TAU / 48 + 0.015 * sin(clock)
		var inner := center + Vector2(cos(a) * 435, sin(a) * 164)
		var outer := center + Vector2(cos(a) * 471, sin(a) * 184)
		line(inner, outer, VIOLET if i % 4 == 0 else Color(VIOLET, 0.2), 3 if i % 4 == 0 else 1)
	for i in range(10):
		var x := 396 + i * 52.0
		poly([Vector2(x, 180), Vector2(x + 36, 180), Vector2(x + 19, 224 + 9 * sin(clock + i))], Color(VIOLET, 0.18))
		poly([Vector2(x, 560), Vector2(x + 36, 560), Vector2(x + 19, 518 + 9 * sin(clock + i))], Color(VIOLET, 0.18))
	draw_arc(center, 96, 0, TAU, 80, Color(VIOLET, 0.18), 1, true)
	line(center, center + Vector2(cos(clock * 0.12), sin(clock * 0.12)) * 122, Color(VIOLET, 0.2), 3)
	line(center, center + Vector2(34, -78), Color(VIOLET, 0.25), 5)
	centered("NOW", 651, 370, 47, Color(CREAM, 0.16), title_font)
	centered("THE PAST IS OCCUPIED" if j.echo_on_moon() else "ONE PERSON MUST REMAIN", 650, 417, 16, MINT, mono_font)
	box(90, 560, 1100, 25, Color("41415b"))
	box(90, 155, 1100, 25, Color("41415b"))
	var open_gate: bool = j.echo_on_moon() or j.gate_latched
	if not open_gate:
		box(505, 180, 42, 380, CORRECTION)
		for y in range(193, 558, 20): line(Vector2(509, y), Vector2(543, y + 13), Color(PAPER, 0.3), 2)
	else:
		box(505, 180, 42, 20, VIOLET)
		box(505, 540, 42, 20, VIOLET)
	plate(j.MOON_PLATE, false, j.echo_on_moon() or j.can_remember(), 0)
	plate(j.EYE_PLATE, true, j.gate_latched, 2)
	if j.gate_latched:
		centered("WITH", 1000, 354, 47, GOLD, title_font)
	else:
		centered("?", 1000, 354, 47, Color(MINT, 0.35), title_font)
	text_at("I AM", 109, 281, 21, MINT, mono_font)
	margin_door(MINT)
	draw_echo()
	hero(j.pos, 1, j.facing, j.moving, j.gravity < 0)
	if j.can_remember() and not j.echo_on_moon(): centered("ESC / KEEP A MEMORY", 270, 413, 15, GOLD, mono_font)

func miniature_page(center: Vector2, size: Vector2, angle: float, opacity: float) -> void:
	var corners: Array = []
	for p in [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)]:
		corners.append(center + (p * size).rotated(angle))
	for i in range(4): line(corners[i], corners[(i + 1) % 4], Color(MINT, opacity), 1.5)
	line(center + Vector2(-size.x, size.y * 0.58).rotated(angle), center + Vector2(size.x, size.y * 0.58).rotated(angle), Color(ORANGE, opacity), 2)
	var p := center + Vector2(-size.x * 0.55, size.y * 0.35).rotated(angle)
	draw_circle(p, size.y * 0.065, Color(GOLD, opacity))

func draw_recursive_room() -> void:
	box(0, 120, 1280, 540, Color("090f22"))
	if j.world_view:
		var center := Vector2(655, 380)
		# A room inside an eye inside the same room, all responding to the same input.
		for i in range(6):
			var scale_value := pow(0.67, i)
			miniature_page(center, Vector2(455, 231) * scale_value, j.world_angle * (1 + i * 0.12), 0.2 + i * 0.1)
		ellipse(center, Vector2(168, 97), Color("35436c"))
		eye(center, 112, VIOLET, Vector2(cos(j.world_angle), sin(j.world_angle)) * 22)
		miniature_page(center, Vector2(30, 18), j.world_angle, 0.8)
		draw_arc(center, 204, 0, TAU, 120, Color(MINT, 0.28), 1, true)
		var moon: Vector2 = center + Vector2(cos(j.world_angle), sin(j.world_angle)) * 204
		symbol(0, moon, 22, GOLD)
		var arc_width := 0.26 if j.orbit_help else 0.18
		draw_arc(center, 204, -PI / 2 - arc_width, -PI / 2 + arc_width, 24, GOLD, 7, true)
		centered("PIN HERE", 655, 147, 14, GOLD, mono_font)
		text_at("YOU ARE", 70, 283, 16, MUTED, mono_font)
		text_at("OUTSIDE.", 67, 327, 34, CREAM, title_font)
		text_at("JUNE IS", 1030, 456, 16, MUTED, mono_font)
		text_at("INSIDE.", 1027, 500, 34, CREAM, title_font)
		if j.world_pinned:
			centered("HELD BY YOU", 655, 630, 20, GOLD, mono_font)
		else: centered("THE ROOM IS THE PUPIL. THE PUPIL IS THE ROOM.", 655, 630, 15, MINT, mono_font)
	else:
		# The eye becomes architecture; its tiny interior is now June's whole stage.
		for i in range(7):
			var scale_value := pow(0.78, i)
			miniature_page(Vector2(640, 358), Vector2(600, 250) * scale_value, 0, 0.12)
		ellipse(Vector2(640, 350), Vector2(395, 174), Color("222f4f"))
		eye(Vector2(640, 350), 148, Color("424a77"), (j.pos - Vector2(640, 350)) * 0.03)
		miniature_page(Vector2(640, 350), Vector2(27, 17), 0, 0.55)
		draw_banks(MINT)
		if j.world_pinned and j.echo_on_moon():
			box(390, 155, 500, 25, VIOLET)
			centered("W E   A R E   H E R E", 640, 174, 17, INK, mono_font)
		else: dashed(Vector2(390, 167), Vector2(890, 167), Color(VIOLET, 0.6))
		plate(j.MOON_PLATE, false, j.echo_on_moon() or j.can_remember(), 0)
		if not j.has_you:
			box(596, 215, 88, 38, INK)
			centered("YOU", 640, 243, 27, GOLD, title_font)
		else: centered("I AM WITH YOU", 640, 470, 27, CREAM, title_font)
		margin_door(MINT)
		draw_echo()
		hero(j.pos, 1, j.facing, j.moving, j.gravity < 0)
		text_at("PINNED" if j.world_pinned else "UNPINNED", 1020, 285, 14, GOLD if j.world_pinned else CORRECTION, mono_font)
		line(Vector2(1059, 298), Vector2(1059, 335), MINT, 1)
		star(Vector2(1059, 342), 8, GOLD)

func draw_margin_ending() -> void:
	box(0, 120, 1280, 540, Color("131d30"))
	for i in range(50): star(Vector2(fposmod(i * 181.7, 1240), 140 + fposmod(i * 71.4, 480)), 2 + i % 3, Color(MINT, 0.18))
	# The line under the new sentence is a street, receding into an envelope.
	poly([Vector2(660, 660), Vector2(1120, 660), Vector2(949, 382), Vector2(844, 382)], Color("3b4c64"))
	for i in range(6):
		var y := 421 + pow(i / 5.0, 1.6) * 236
		line(Vector2(890, y), Vector2(890, y + 14), Color(MINT, 0.6), 3)
	envelope(Vector2(895, 339), 3.2)
	eye(Vector2(895, 339), 32, ORANGE, (mouse - Vector2(895, 339)) * 0.015)
	hero(Vector2(804, 531), 1.9, 1)
	# An empty outline beside June is the place she is keeping for the player.
	draw_arc(Vector2(978, 506), 17, 0, TAU, 32, VIOLET, 2, true)
	dashed(Vector2(959, 531), Vector2(951, 573), VIOLET)
	dashed(Vector2(996, 531), Vector2(1004, 573), VIOLET)
	line(Vector2(951, 573), Vector2(1004, 573), VIOLET, 2)
	text_at("THE SECOND DELIVERY", 80, 214, 15, ORANGE, mono_font)
	text_at("I am", 76, 296, 65, CREAM, title_font)
	text_at("with you.", 76, 371, 65, CREAM, title_font)
	wrapped("Someone erased the sender. June has decided that a missing person is also an address.", 80, 434, 480, 23, MINT)
	text_at("SHE HAS KEPT YOUR PLACE.", 80, 572, 15, VIOLET, mono_font)

func draw_world() -> void:
	match j.chapter:
		7: draw_margin_page()
		8: draw_clock_room()
		9: draw_recursive_room()
		10: draw_margin_ending()
		_: super.draw_world()
