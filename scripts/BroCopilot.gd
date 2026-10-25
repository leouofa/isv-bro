# scripts/BroCopilot.gd
extends Control

var current_state: String = "IDLE"
var is_talking: bool = false
var mouth_phase: float = 0.0
var visor_sweep: float = 0.0
var pulse_time: float = 0.0

const COLOR_SKIN := Color(0.96, 0.76, 0.58)
const COLOR_HAIR := Color(0.98, 0.85, 0.1) # Radical 90s blond spiky hair
const COLOR_VISOR_BASE := Color(0.06, 0.06, 0.12)
const COLOR_CYAN := Color(0.0, 0.94, 1.0)
const COLOR_MAGENTA := Color(1.0, 0.0, 0.5)
const COLOR_RED := Color(1.0, 0.1, 0.2)
const COLOR_LIME := Color(0.22, 1.0, 0.08)

func _ready() -> void:
	custom_minimum_size = Vector2(140, 140)

func set_state(state: String) -> void:
	current_state = state
	queue_redraw()

func set_talking(talking: bool) -> void:
	is_talking = talking
	if not is_talking:
		mouth_phase = 0.0
	queue_redraw()

func _process(delta: float) -> void:
	pulse_time += delta
	visor_sweep = fmod(visor_sweep + delta * 1.8, 1.0)

	if is_talking:
		mouth_phase += delta * 14.0
		queue_redraw()
	else:
		# Slower idle redraw for visor sweep
		queue_redraw()

func _draw() -> void:
	var w := size.x
	var h := size.y
	var center := Vector2(w * 0.5, h * 0.5)

	# 1. CRT Background Frame
	var bg_color := Color(0.04, 0.04, 0.08, 0.9)
	draw_rect(Rect2(Vector2.ZERO, size), bg_color, true)

	var frame_color := COLOR_CYAN
	if current_state == "OVERHEAT_ALARM":
		frame_color = COLOR_RED if fmod(pulse_time * 6.0, 1.0) > 0.5 else Color.BLACK
	elif current_state == "HYPE_COMBO":
		frame_color = COLOR_LIME
	elif current_state == "BOSS_ALERT":
		frame_color = COLOR_MAGENTA

	draw_rect(Rect2(Vector2.ZERO, size), frame_color, false, 3.0)

	# 2. Spiky 90s Hair (Back)
	var hair_points := PackedVector2Array([
		center + Vector2(-42, -18),
		center + Vector2(-54, -46),
		center + Vector2(-32, -42),
		center + Vector2(-22, -65),
		center + Vector2(-4, -48),
		center + Vector2(16, -66),
		center + Vector2(28, -44),
		center + Vector2(50, -50),
		center + Vector2(40, -16)
	])
	draw_colored_polygon(hair_points, COLOR_HAIR)

	# 3. Head / Face Shape
	var head_points := PackedVector2Array([
		center + Vector2(-32, -22),
		center + Vector2(32, -22),
		center + Vector2(28, 26),
		center + Vector2(14, 46),
		center + Vector2(-14, 46),
		center + Vector2(-28, 26)
	])
	draw_colored_polygon(head_points, COLOR_SKIN)

	# 4. Neon Visor Sunglasses
	var visor_points := PackedVector2Array([
		center + Vector2(-36, -14),
		center + Vector2(36, -14),
		center + Vector2(32, 8),
		center + Vector2(0, 4),
		center + Vector2(-32, 8)
	])
	draw_colored_polygon(visor_points, COLOR_VISOR_BASE)

	# Visor Neon Outline
	var visor_glow := COLOR_CYAN
	if current_state == "HYPE_COMBO":
		visor_glow = COLOR_LIME
	elif current_state == "OVERHEAT_ALARM":
		visor_glow = COLOR_RED
	elif current_state == "BOSS_ALERT":
		visor_glow = COLOR_MAGENTA

	draw_polyline(visor_points, visor_glow, 2.5)

	# Visor Light Sweep Reflection
	var sweep_x := lerpf(-30.0, 30.0, visor_sweep)
	var sweep_p1 := center + Vector2(sweep_x, -10)
	var sweep_p2 := center + Vector2(sweep_x + 8.0, 4)
	draw_line(sweep_p1, sweep_p2, Color(1, 1, 1, 0.85), 2.0)

	# 5. Mouth (Talking animation)
	var mouth_open: float = abs(sin(mouth_phase)) * 8.0 if is_talking else 1.0
	if current_state == "HYPE_COMBO":
		# Huge ecstatic grin
		var grin_points := PackedVector2Array([
			center + Vector2(-18, 22),
			center + Vector2(18, 22),
			center + Vector2(12, 28 + mouth_open),
			center + Vector2(-12, 28 + mouth_open)
		])
		draw_colored_polygon(grin_points, Color.WHITE)
		draw_polyline(grin_points, Color(0.2, 0.05, 0.05), 1.5)
	elif current_state == "OVERHEAT_ALARM":
		# Alarmed 'O' mouth
		draw_circle(center + Vector2(0, 26), 5.0 + mouth_open * 0.5, Color(0.15, 0.02, 0.02))
	else:
		# Standard mouth line or talking aperture
		if is_talking and mouth_open > 2.0:
			draw_circle(center + Vector2(0, 26), mouth_open * 0.6, Color(0.2, 0.05, 0.05))
		else:
			draw_line(center + Vector2(-12, 26), center + Vector2(12, 27), Color(0.3, 0.1, 0.1), 2.0)

	# 6. CRT Scanline Accent inside Avatar Box
	for y in range(0, int(h), 6):
		draw_line(Vector2(0, y), Vector2(w, y), Color(0, 0, 0, 0.18), 1.0)
