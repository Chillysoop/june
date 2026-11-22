extends Node2D
## All artwork is original vector geometry, drawn locally by Godot.
const INK = Color("19363b")
const DARK = Color("10272e")
const CREAM = Color("f1e5c9")
const ORANGE = Color("f58c62")
const MINT = Color("a9d6c5")
const MUTED = Color("8babaa")
const GOLD = Color("f2c66b")
var body_font: Font
var title_font: Font
var mono_font: Font
var clock := 0.0
var j: RefCounted
var mouse := Vector2.ZERO

func prepare_art() -> void:
	body_font = SystemFont.new()
	body_font.font_names = PackedStringArray(["Bahnschrift", "Arial"])
	title_font = SystemFont.new()
	title_font.font_names = PackedStringArray(["Georgia", "Times New Roman"])
	mono_font = SystemFont.new()
	mono_font.font_names = PackedStringArray(["Consolas", "Courier New"])

func box(x: float, y: float, w: float, h: float, color: Color) -> void:
	draw_rect(Rect2(x, y, w, h), color)

func line(a: Vector2, b: Vector2, color: Color = INK, width: float = 2.0) -> void:
	draw_line(a, b, color, width, true)

func poly(points: Array, color: Color) -> void:
	draw_colored_polygon(PackedVector2Array(points), color)

func ellipse(center: Vector2, size: Vector2, color: Color) -> void:
	var points := PackedVector2Array()
	for k in range(48):
		var angle := k * TAU / 48
		points.append(center + Vector2(cos(angle), sin(angle)) * size)
	draw_colored_polygon(points, color)

func text_at(text: String, x: float, y: float, size: int = 20, color: Color = CREAM, font: Font = null) -> void:
	draw_string(body_font if font == null else font, Vector2(x, y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, size, color)

func centered(text: String, x: float, y: float, size: int = 20, color: Color = CREAM, font: Font = null) -> void:
	var f := body_font if font == null else font
	text_at(text, x - f.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x / 2, y, size, color, f)

func wrapped(text: String, x: float, y: float, width: float, size: int = 24, color: Color = CREAM, font: Font = null) -> float:
	var f := body_font if font == null else font
	var current := ""
	var baseline := y
	for word in text.split(" "):
		var candidate := current + (" " if current != "" else "") + word
		if f.get_string_size(candidate, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x > width and current != "":
			text_at(current, x, baseline, size, color, f)
			baseline += size * 1.45
			current = word
		else: current = candidate
	text_at(current, x, baseline, size, color, f)
	return baseline

func grain(color: Color, top: int = 0, bottom: int = 800) -> void:
	for i in range(220):
		var x := fposmod(i * 173.31, 1280)
		var y := top + fposmod(i * 71.33, bottom - top)
		line(Vector2(x, y), Vector2(x + 2, y), color, 1)

func star(p: Vector2, radius: float, color: Color) -> void:
	var points: Array = []
	for i in range(8):
		var a := i * PI / 4
		points.append(p + Vector2(cos(a), sin(a)) * (radius if i % 2 == 0 else radius * 0.25))
	poly(points, color)

func eye(p: Vector2, radius: float, color: Color, look := Vector2.ZERO) -> void:
	ellipse(p, Vector2(radius, radius * 0.52), color)
	draw_circle(p + look.limit_length(radius * 0.25), radius * 0.30, INK)
	draw_circle(p + look.limit_length(radius * 0.25) + Vector2(-radius * 0.1, -radius * 0.1), radius * 0.08, CREAM)

func envelope(p: Vector2, scale_value: float = 1.0, color: Color = CREAM) -> void:
	box(p.x - 25 * scale_value, p.y - 17 * scale_value, 50 * scale_value, 34 * scale_value, color)
	line(p + Vector2(-25, -17) * scale_value, p + Vector2(0, 4) * scale_value, INK, 2)
	line(p + Vector2(25, -17) * scale_value, p + Vector2(0, 4) * scale_value, INK, 2)
	box(p.x + 13 * scale_value, p.y - 12 * scale_value, 7 * scale_value, 8 * scale_value, ORANGE)

func hero(p: Vector2, scale_value: float = 1.0, face: float = 1.0, walk := false, inverted := false) -> void:
	var bob := sin(clock * 12) * 2 if walk else sin(clock * 2) * 0.7
	var stride := sin(clock * 12) * 7 if walk else 2.0
	draw_set_transform(p, PI if inverted else 0, Vector2(scale_value * face, scale_value))
	line(Vector2(-7, 9), Vector2(-8 - stride, 25), INK, 7)
	line(Vector2(7, 9), Vector2(8 + stride, 25), INK, 7)
	poly([Vector2(-15, -13 + bob), Vector2(13, -13 + bob), Vector2(18, 13), Vector2(-18, 13)], ORANGE)
	line(Vector2(-12, -8), Vector2(-20, 5 + bob), INK, 5)
	draw_circle(Vector2(0, -25 + bob), 13, GOLD)
	ellipse(Vector2(0, -34 + bob), Vector2(17, 8), INK)
	box(-14, -36 + bob, 29, 7, MINT)
	line(Vector2(-17, -30 + bob), Vector2(20, -30 + bob), INK, 4)
	draw_circle(Vector2(7, -24 + bob), 2, INK)
	line(Vector2(-9, -12), Vector2(14, 11), INK, 3)
	box(5, 0, 19, 18, CREAM)
	line(Vector2(6, 6), Vector2(23, 6), GOLD, 2)
	draw_set_transform(Vector2.ZERO)

func building(x: float, floor_y: float, width: float, height: float, color: Color, roof: Color, windows: int = 2) -> void:
	box(x + 12, floor_y - height + 12, width, height, Color(0.05, 0.15, 0.16, 0.13))
	box(x, floor_y - height, width, height, color)
	poly([Vector2(x - 10, floor_y - height), Vector2(x + width / 2, floor_y - height - 55), Vector2(x + width + 10, floor_y - height)], roof)
	box(x + width * 0.68, floor_y - height - 45, 19, 35, roof)
	for row in range(windows):
		for col in range(2):
			var wx := x + 22 + col * (width - 66)
			var wy := floor_y - height + 26 + row * 59
			box(wx, wy, 23, 32, INK)
			box(wx + 3, wy + 3, 17, 24, GOLD)
			line(Vector2(wx + 11, wy + 3), Vector2(wx + 11, wy + 29), INK)
	box(x + width / 2 - 17, floor_y - 52, 34, 52, INK)
	draw_circle(Vector2(x + width / 2 + 9, floor_y - 26), 2, GOLD)

func draw_title() -> void:
	box(0, 0, 1280, 800, DARK)
	for i in range(60):
		var p := Vector2(fposmod(i * 137.8, 1260), 90 + fposmod(i * 59.6, 570))
		draw_circle(p, 1 + i % 2, Color(0.65, 0.84, 0.77, 0.25 + 0.15 * sin(clock + i)))
	draw_circle(Vector2(960, 280), 186, ORANGE)
	draw_circle(Vector2(1017, 235), 162, DARK)
	for i in range(6):
		var x := 716 + i * 54
		var y := 565 - i * 28
		box(x, y, 57, 16, MINT)
		line(Vector2(x, y + 16), Vector2(x, 675), Color(0.66, 0.84, 0.77, 0.12))
	building(850, 480, 150, 165, MINT, INK, 2)
	box(880, 470, 28, 94, INK)
	box(942, 470, 28, 94, INK)
	eye(Vector2(925, 327), 29, CREAM, (mouse - Vector2(925, 327)) * 0.025)
	hero(Vector2(787, 506 + sin(clock) * 4), 1.7)
	envelope(Vector2(1083, 562 + sin(clock * 1.4) * 12), 1.7)
	draw_arc(Vector2(950, 425), 280, 0.4, 5.2, 100, Color(MINT, 0.16), 1, true)
	text_at("A GAME ABOUT JUNE", 80, 125, 16, MINT, mono_font)
	text_at("RETURN", 74, 248, 94, CREAM, title_font)
	text_at("TO SENDER", 74, 346, 94, CREAM, title_font)
	line(Vector2(80, 384), Vector2(150, 384), ORANGE, 3)
	wrapped("One courier. One impossible address.", 80, 430, 580, 24, CREAM)
	wrapped("A small delivery. An increasingly unreasonable universe.", 80, 468, 520, 21, MUTED)
	text_at("A PROGRESSIVELY PECULIAR ADVENTURE", 80, 734, 14, MUTED, mono_font)
	text_at("THE MARGINS  /  v0.2", 953, 734, 14, MUTED, mono_font)
	grain(Color(0.8, 0.9, 0.8, 0.09))

func draw_town() -> void:
	box(0, 120, 1280, 540, Color("d7dfc7"))
	draw_circle(Vector2(1030, 230), 72, GOLD)
	poly([Vector2(0, 375), Vector2(170, 250), Vector2(390, 370), Vector2(590, 255), Vector2(900, 365), Vector2(1120, 275), Vector2(1280, 360), Vector2(1280, 540), Vector2(0, 540)], Color("b4cbb6"))
	box(0, 399, 1280, 244, Color("b1bf9d"))
	poly([Vector2(0, 465), Vector2(1280, 452), Vector2(1280, 595), Vector2(0, 605)], Color("eee1c2"))
	for i in range(24):
		var x := i * 59.0
		line(Vector2(x, 591), Vector2(x + 40, 589), Color("b7b697"), 2)
	building(72, 401, 160, 147, Color("e7bd92"), Color("678b7f"))
	building(260, 400, 150, 184, CREAM, Color("c16f53"))
	box(265, 346, 140, 31, ORANGE)
	centered("POST OFFICE", 335, 368, 17, INK, mono_font)
	building(488, 395, 144, 135, Color("91b5a3"), INK, 1)
	building(785, 393, 148, 192, Color("d9bc92"), Color("577c75"))
	for x in [680, 985]:
		line(Vector2(x, 410), Vector2(x, 310), INK, 5)
		draw_circle(Vector2(x, 304), 13, GOLD)
		line(Vector2(x - 18, 317), Vector2(x + 18, 317), INK, 4)
	if j.has_letter:
		box(1036, 269, 87, 141, INK)
		draw_arc(Vector2(1079.5, 270), 43.5, PI, TAU, 32, INK, 12, true)
		box(1048, 280, 63, 126, Color("426965"))
		centered("0", 1080, 331, 35, GOLD, title_font)
		draw_circle(Vector2(1098, 364), 4, GOLD)
		for i in range(5): star(Vector2(1030 + i * 25, 250 + sin(clock * 2 + i) * 13), 4, ORANGE)
	else:
		box(1029, 301, 107, 100, Color("c7c5a7"))
		for i in range(4): line(Vector2(1029, 315 + i * 24), Vector2(1136, 315 + i * 24), Color("b2b594"))
	# The first tutorial is an in-world, clearly marked destination.
	if not j.has_letter:
		envelope(Vector2(335, 304 + sin(clock * 3) * 5), 0.7)
		centered("YOUR LAST LETTER", 335, 183, 15, INK, mono_font)
	else: centered("NUMBER ZERO", 1080, 227, 15, INK, mono_font)
	# A cat with an optional conversation.
	ellipse(Vector2(710, 458), Vector2(24, 8), Color(INK, 0.13))
	ellipse(Vector2(710, 446), Vector2(16, 12), INK)
	poly([Vector2(710, 438), Vector2(714, 419), Vector2(724, 433), Vector2(732, 421), Vector2(732, 444)], INK)
	draw_circle(Vector2(724, 434), 2, GOLD)
	draw_arc(Vector2(689, 435), 13, 0, 4.1, 16, INK, 4, true)
	ellipse(j.pos + Vector2(0, 26), Vector2(24, 7), Color(INK, 0.17))
	hero(j.pos, 1.25, j.facing, j.moving)
	var near: bool = (not j.has_letter and j.pos.distance_to(Vector2(335, 420)) < 100) or (j.has_letter and j.pos.distance_to(Vector2(1080, 420)) < 110) or j.pos.distance_to(Vector2(710, 460)) < 95
	if near: centered("[ E ]", j.pos.x, j.pos.y - 67, 18, INK, mono_font)
	grain(Color(INK, 0.10), 130, 650)

func draw_gravity() -> void:
	box(0, 120, 1280, 530, Color("252c46"))
	for i in range(14):
		var x := i * 100.0
		line(Vector2(x, 180), Vector2(x, 560), Color("343c55"), 1)
	for y in [220, 300, 380, 460, 540]: line(Vector2(0, y), Vector2(1280, y), Color("343c55"), 1)
	box(75, 148, 1130, 32, MINT)
	box(75, 560, 1130, 32, MINT)
	for i in range(23):
		line(Vector2(80 + i * 50, 148), Vector2(102 + i * 50, 180), INK, 2)
		line(Vector2(80 + i * 50, 560), Vector2(102 + i * 50, 592), INK, 2)
	for obstacle in j.OBSTACLES:
		draw_rect(obstacle, Color("7b8194"))
		for y in range(int(obstacle.position.y) + 12, int(obstacle.end.y), 25):
			line(Vector2(obstacle.position.x + 5, y), Vector2(obstacle.end.x - 5, y), Color("3e4d61"), 2)
	# A chair bolted to the ceiling.
	box(570, 180, 7, 33, ORANGE)
	box(610, 180, 7, 33, ORANGE)
	box(566, 210, 55, 8, ORANGE)
	box(612, 211, 8, 47, ORANGE)
	for i in range(3):
		if not j.stamps[i]:
			var p: Vector2 = j.STAMP_POSITIONS[i] + Vector2(0, sin(clock * 2 + i) * 4)
			draw_circle(p, 32 + sin(clock * 2) * 3, Color(GOLD, 0.07))
			box(p.x - 16, p.y - 20, 32, 40, CREAM)
			box(p.x - 11, p.y - 15, 22, 30, ORANGE)
			star(p, 9, CREAM)
	box(1070, 455, 62, 105, INK)
	box(1078, 464, 46, 96, Color("577f7b"))
	centered("0", 1101, 501, 26, GOLD, title_font)
	centered("EXIT", 1101, 433, 15, MINT, mono_font)
	hero(j.pos, 1, j.facing, j.moving, j.gravity < 0)
	centered("GRAVITY IS A SUGGESTION", 640, 365, 29, Color(MINT, 0.25), title_font)
	centered("SPACE  /  CHANGE DOWN", 640, 397, 15, Color(MINT, 0.45), mono_font)

func symbol(index: int, p: Vector2, radius: float, color: Color) -> void:
	match index:
		0:
			draw_circle(p, radius, color)
			draw_circle(p + Vector2(radius * 0.5, -radius * 0.3), radius * 0.8, Color("19373f"))
		1:
			draw_rect(Rect2(p - Vector2(radius * 0.65, radius), Vector2(radius * 1.3, radius * 2)), color, false, 3)
			draw_circle(p + Vector2(radius * 0.3, 0), 3, color)
		2: eye(p, radius * 1.3, color, Vector2(sin(clock) * 3, 0))

func draw_corridor() -> void:
	box(0, 120, 1280, 540, Color("19373f"))
	poly([Vector2(0, 120), Vector2(1280, 120), Vector2(1030, 235), Vector2(250, 235)], Color("28444a"))
	poly([Vector2(0, 660), Vector2(1280, 660), Vector2(1030, 530), Vector2(250, 530)], Color("50736c"))
	poly([Vector2(0, 120), Vector2(250, 235), Vector2(250, 530), Vector2(0, 660)], Color("345b60"))
	poly([Vector2(1280, 120), Vector2(1030, 235), Vector2(1030, 530), Vector2(1280, 660)], Color("345b60"))
	for i in range(7):
		var x := -300 + i * 320.0
		line(Vector2(x, 660), Vector2(640 + (x - 640) * 0.35, 530), INK, 2)
	for i in range(4):
		var y := 537 + pow(i / 3.0, 1.7) * 125
		line(Vector2(0, y), Vector2(1280, y), INK, 2)
	for i in range(3):
		var x := 335 + i * 240
		var selected: bool = j.door_choice == i
		box(x - 8, 264, 146, 270, ORANGE if selected else Color("63857a"))
		box(x, 274, 130, 256, Color("19373f"))
		symbol(i, Vector2(x + 65, 355), 28, GOLD if selected else MINT)
		draw_circle(Vector2(x + 110, 443), 5, GOLD)
		centered(["MOON", "DOOR", "EYE"][i], x + 65, 495, 17, CREAM, mono_font)
		if selected: centered("[ E  ENTER ]", x + 65, 573, 18, GOLD, mono_font)
	# June's hands and the same letter establish the perspective change.
	poly([Vector2(396, 660), Vector2(439, 576), Vector2(493, 585), Vector2(472, 660)], ORANGE)
	poly([Vector2(884, 660), Vector2(841, 576), Vector2(787, 585), Vector2(808, 660)], ORANGE)
	ellipse(Vector2(479, 589), Vector2(25, 18), GOLD)
	ellipse(Vector2(801, 589), Vector2(25, 18), GOLD)
	box(490, 577, 300, 80, CREAM)
	centered("moon  /  eye  /  door", 640, 608, 21, INK, title_font)
	centered("written in your handwriting", 640, 637, 13, INK, mono_font)
	for i in range(3): draw_circle(Vector2(605 + i * 35, 203), 5, ORANGE if i < j.corridor_step else MUTED)

func draw_trial() -> void:
	box(0, 120, 1280, 540, Color("102d45"))
	for i in range(14):
		var x := 50 + i * 94.0
		var y := 655 - fposmod(clock * (10 + i % 4 * 5) + i * 57, 510)
		draw_arc(Vector2(x, y), 5 + i % 4 * 3, 0, TAU, 20, Color(MINT, 0.16), 1, true)
	for i in range(6):
		poly([Vector2(100 + i * 240, 120), Vector2(180 + i * 240, 120), Vector2(400 + i * 240, 620), Vector2(190 + i * 240, 620)], Color(0.3, 0.7, 0.7, 0.035))
	box(128, 513, 1024, 52, Color("335b64"))
	box(167, 565, 946, 28, INK)
	for x in [190, 1045]:
		box(x, 170, 45, 344, Color("33505b"))
		box(x - 10, 170, 65, 20, MINT)
		box(x - 10, 493, 65, 20, MINT)
	var bob := sin(clock * 1.5) * 5
	ellipse(Vector2(758, 321 + bob), Vector2(155, 98), MINT)
	poly([Vector2(875, 321 + bob), Vector2(1004, 235 + bob), Vector2(985, 399 + bob)], Color("649e9b"))
	poly([Vector2(710, 260 + bob), Vector2(786, 189 + bob), Vector2(813, 260 + bob)], Color("649e9b"))
	eye(Vector2(686, 294 + bob), 34, CREAM, Vector2(-7, 0))
	draw_arc(Vector2(654, 356 + bob), 24, 0.4, 2.0, 18, INK, 3, true)
	line(Vector2(660, 285 + bob), Vector2(716, 285 + bob), INK, 3)
	draw_arc(Vector2(688, 296 + bob), 23, 0, TAU, 24, INK, 3, true)
	# Judicial wig and utterly unnecessary tie.
	for i in range(6): draw_circle(Vector2(655 + i * 23, 232 + bob), 17, CREAM)
	poly([Vector2(719, 391 + bob), Vector2(737, 389 + bob), Vector2(741, 439 + bob), Vector2(729, 452 + bob), Vector2(716, 436 + bob)], ORANGE)
	box(590, 453, 360, 61, Color("b57c65"))
	centered("THE DEPARTMENT OF DEPTH", 770, 488, 15, INK, mono_font)
	hero(Vector2(348, 482), 1.85)
	box(280, 491, 150, 59, Color("b57c65"))
	centered("JUNE", 355, 528, 17, INK, mono_font)
	for i in range(3):
		var x := 1045 + (i - 1) * 22
		star(Vector2(x, 222), 6, GOLD if i < j.verdict else MUTED)
	if j.dialogue.is_empty():
		wrapped(j.CLAIMS[mini(j.verdict, 2)], 292, 166, 680, 22, CREAM, title_font)

func draw_orbit() -> void:
	box(0, 120, 1280, 540, Color("161d32"))
	var center := Vector2(640, 393)
	for i in range(95):
		var p := Vector2(fposmod(i * 151.31, 1260), 135 + fposmod(i * 67.37, 505))
		draw_circle(p, 1 + i % 2, Color(CREAM, 0.25 + 0.2 * sin(clock * 0.6 + i)))
	for radius in [98, 157, 218]: draw_arc(center, radius, 0, TAU, 128, Color(MINT, 0.19), 1, true)
	poly([center + Vector2(-17, -225), center + Vector2(17, -225), center + Vector2(43, -276), center + Vector2(-43, -276)], Color(GOLD, 0.15))
	draw_arc(center, 218, -PI / 2 - 0.17, -PI / 2 + 0.17, 24, GOLD, 6, true)
	centered("REMEMBER", 640, 141, 14, GOLD, mono_font)
	for i in range(3):
		var angle: float = j.orbit_angle + j.ORBIT_TARGETS[i]
		var p := center + Vector2(cos(angle), sin(angle)) * 218
		var active: bool = i == j.orbit_step
		var color: Color = GOLD if active else (MINT if i < j.orbit_step else Color("4c586b"))
		draw_circle(p, 30 if active else 20, Color(color, 0.1))
		symbol(i, p, 12 if not active else 18, color)
		if active and j.orbit_hold > 0: draw_arc(p, 33, -PI / 2, -PI / 2 + TAU * j.orbit_hold / 0.65, 32, GOLD, 3, true)
	# An entire town is now one object inside a small glass planet.
	draw_circle(center, 75, Color("3d6b70"))
	poly([center + Vector2(-70, 23), center + Vector2(69, 23), center + Vector2(48, 55), center + Vector2(0, 73), center + Vector2(-43, 60)], INK)
	building(610, 416, 58, 58, CREAM, ORANGE, 0)
	hero(Vector2(688, 413), 0.55)
	draw_arc(center, 76, 0, TAU, 64, MINT, 2, true)
	centered("YOU ARE HERE", 640, 515, 15, MINT, mono_font)
	text_at("MEMORIES", 93, 230, 16, MUTED, mono_font)
	for i in range(3):
		text_at(("+  " if i < j.orbit_step else "·  ") + ["THE FIRST DAY", "THE HANDWRITING", "THE OTHER SIDE"][i], 93, 267 + i * 34, 16, MINT if i < j.orbit_step else MUTED, mono_font)

func draw_outside(ending := false) -> void:
	box(0, 120, 1280, 540, Color("e8e5d7") if not ending else DARK)
	var color := INK if not ending else MINT
	for x in range(100, 1200, 50): line(Vector2(x, 145), Vector2(x, 620), Color(color, 0.06), 1)
	for y in range(170, 640, 50): line(Vector2(70, y), Vector2(1210, y), Color(color, 0.06), 1)
	if not ending:
		text_at("RETURN", 366, 281, 77, INK, title_font)
		text_at("TO SENDER", 364, 354, 77, INK, title_font)
		line(Vector2(315, 477), Vector2(1002, 477), INK, 3)
		hero(Vector2(550 + sin(clock * 0.6) * 8, 444), 1.4, 1 if mouse.x > 550 else -1)
		box(900, 358, 75, 117, INK)
		box(910, 368, 55, 107, CREAM)
		centered("ESC", 937, 416, 20, INK, mono_font)
		centered("THIS DOOR IS ON YOUR SIDE", 640, 551, 16, INK, mono_font)
		if j.dialogue.is_empty():
			line(Vector2(570, 409), mouse, Color(INK, 0.12), 1)
			eye(Vector2(1168, 185), 18, INK, (mouse - Vector2(1168, 185)) * 0.03)
	else:
		draw_circle(Vector2(955, 337), 130, Color(ORANGE, 0.12))
		eye(Vector2(955, 337), 87, ORANGE, (mouse - Vector2(955, 337)) * 0.03)
		hero(Vector2(753, 516), 2.2, 1 if mouse.x > 753 else -1)
		line(Vector2(665, 573), Vector2(1080, 573), MINT, 2)
		text_at("DELIVERY RECEIVED.", 90, 238, 16, ORANGE, mono_font)
		text_at("She knows", 87, 324, 64, CREAM, title_font)
		text_at("you're there.", 87, 399, 64, CREAM, title_font)
		wrapped("This was only the first impossible thing.", 90, 472, 520, 23, MINT)
		text_at("JUNE WILL REMEMBER THIS.", 90, 545, 15, MUTED, mono_font)

func draw_world() -> void:
	match j.chapter:
		0: draw_town()
		1: draw_gravity()
		2: draw_corridor()
		3: draw_trial()
		4: draw_orbit()
		5: draw_outside()
		6: draw_outside(true)
