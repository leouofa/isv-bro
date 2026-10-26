# scripts/SynthwaveUI.gd
extends Node

# Synthwave Color Palette Constants
const COLOR_CYAN := Color(0.0, 0.94, 1.0, 1.0)
const COLOR_MAGENTA := Color(1.0, 0.0, 0.55, 1.0)
const COLOR_YELLOW := Color(1.0, 0.9, 0.0, 1.0)
const COLOR_BG_NORMAL := Color(0.06, 0.06, 0.12, 0.92)
const COLOR_BG_HOVER := Color(0.13, 0.08, 0.24, 0.96)
const COLOR_BG_PRESSED := Color(0.20, 0.05, 0.30, 0.98)
const COLOR_BG_DISABLED := Color(0.04, 0.04, 0.07, 0.7)
const COLOR_BORDER_DISABLED := Color(0.25, 0.25, 0.32, 0.5)

var btn_style_normal: StyleBoxFlat
var btn_style_hover: StyleBoxFlat
var btn_style_pressed: StyleBoxFlat
var btn_style_disabled: StyleBoxFlat
var btn_style_focus: StyleBoxFlat

var card_style_normal: StyleBoxFlat
var card_style_hover: StyleBoxFlat
var card_style_locked: StyleBoxFlat

var global_theme: Theme

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_create_styleboxes()
	_create_global_theme()
	
	if is_inside_tree():
		var tree := get_tree()
		if tree:
			tree.node_added.connect(_on_node_added)
			_scan_and_style(tree.root)

func _create_styleboxes() -> void:
	# --- Button Style Normal ---
	btn_style_normal = StyleBoxFlat.new()
	btn_style_normal.bg_color = COLOR_BG_NORMAL
	btn_style_normal.set_border_width_all(2)
	btn_style_normal.border_color = COLOR_CYAN
	btn_style_normal.set_corner_radius_all(6)
	btn_style_normal.content_margin_left = 12.0
	btn_style_normal.content_margin_top = 8.0
	btn_style_normal.content_margin_right = 12.0
	btn_style_normal.content_margin_bottom = 8.0

	# --- Button Style Hover (Neon Bloom) ---
	btn_style_hover = StyleBoxFlat.new()
	btn_style_hover.bg_color = COLOR_BG_HOVER
	btn_style_hover.set_border_width_all(2)
	btn_style_hover.border_color = COLOR_MAGENTA
	btn_style_hover.set_corner_radius_all(6)
	btn_style_hover.shadow_color = Color(1.0, 0.0, 0.55, 0.45)
	btn_style_hover.shadow_size = 8
	btn_style_hover.content_margin_left = 12.0
	btn_style_hover.content_margin_top = 8.0
	btn_style_hover.content_margin_right = 12.0
	btn_style_hover.content_margin_bottom = 8.0

	# --- Button Style Pressed ---
	btn_style_pressed = StyleBoxFlat.new()
	btn_style_pressed.bg_color = COLOR_BG_PRESSED
	btn_style_pressed.set_border_width_all(2)
	btn_style_pressed.border_color = COLOR_YELLOW
	btn_style_pressed.set_corner_radius_all(6)
	btn_style_pressed.shadow_color = Color(1.0, 0.9, 0.0, 0.35)
	btn_style_pressed.shadow_size = 6
	btn_style_pressed.content_margin_left = 12.0
	btn_style_pressed.content_margin_top = 8.0
	btn_style_pressed.content_margin_right = 12.0
	btn_style_pressed.content_margin_bottom = 8.0

	# --- Button Style Disabled ---
	btn_style_disabled = StyleBoxFlat.new()
	btn_style_disabled.bg_color = COLOR_BG_DISABLED
	btn_style_disabled.set_border_width_all(2)
	btn_style_disabled.border_color = COLOR_BORDER_DISABLED
	btn_style_disabled.set_corner_radius_all(6)
	btn_style_disabled.content_margin_left = 12.0
	btn_style_disabled.content_margin_top = 8.0
	btn_style_disabled.content_margin_right = 12.0
	btn_style_disabled.content_margin_bottom = 8.0

	# --- Button Style Focus ---
	btn_style_focus = StyleBoxFlat.new()
	btn_style_focus.draw_center = false
	btn_style_focus.set_border_width_all(2)
	btn_style_focus.border_color = COLOR_CYAN
	btn_style_focus.set_corner_radius_all(6)
	btn_style_focus.shadow_color = Color(0.0, 0.94, 1.0, 0.4)
	btn_style_focus.shadow_size = 4

	# --- Card Style Normal ---
	card_style_normal = StyleBoxFlat.new()
	card_style_normal.bg_color = Color(0.07, 0.07, 0.13, 0.95)
	card_style_normal.set_border_width_all(2)
	card_style_normal.border_color = COLOR_CYAN
	card_style_normal.set_corner_radius_all(8)
	card_style_normal.content_margin_left = 16.0
	card_style_normal.content_margin_top = 16.0
	card_style_normal.content_margin_right = 16.0
	card_style_normal.content_margin_bottom = 16.0

	# --- Card Style Hover (Pulsing Magenta Bloom) ---
	card_style_hover = StyleBoxFlat.new()
	card_style_hover.bg_color = COLOR_BG_HOVER
	card_style_hover.set_border_width_all(2)
	card_style_hover.border_color = COLOR_MAGENTA
	card_style_hover.set_corner_radius_all(8)
	card_style_hover.shadow_color = Color(1.0, 0.0, 0.55, 0.55)
	card_style_hover.shadow_size = 12
	card_style_hover.content_margin_left = 16.0
	card_style_hover.content_margin_top = 16.0
	card_style_hover.content_margin_right = 16.0
	card_style_hover.content_margin_bottom = 16.0

	# --- Card Style Locked ---
	card_style_locked = StyleBoxFlat.new()
	card_style_locked.bg_color = COLOR_BG_DISABLED
	card_style_locked.set_border_width_all(2)
	card_style_locked.border_color = COLOR_BORDER_DISABLED
	card_style_locked.set_corner_radius_all(8)
	card_style_locked.content_margin_left = 16.0
	card_style_locked.content_margin_top = 16.0
	card_style_locked.content_margin_right = 16.0
	card_style_locked.content_margin_bottom = 16.0

func _create_global_theme() -> void:
	global_theme = Theme.new()
	
	# Button Theme
	global_theme.set_stylebox("normal", "Button", btn_style_normal)
	global_theme.set_stylebox("hover", "Button", btn_style_hover)
	global_theme.set_stylebox("pressed", "Button", btn_style_pressed)
	global_theme.set_stylebox("disabled", "Button", btn_style_disabled)
	global_theme.set_stylebox("focus", "Button", btn_style_focus)

	global_theme.set_color("font_color", "Button", COLOR_CYAN)
	global_theme.set_color("font_hover_color", "Button", Color.WHITE)
	global_theme.set_color("font_pressed_color", "Button", COLOR_YELLOW)
	global_theme.set_color("font_disabled_color", "Button", Color(0.45, 0.45, 0.55, 0.7))
	global_theme.set_color("font_focus_color", "Button", COLOR_CYAN)

	# OptionButton Theme
	global_theme.set_stylebox("normal", "OptionButton", btn_style_normal)
	global_theme.set_stylebox("hover", "OptionButton", btn_style_hover)
	global_theme.set_stylebox("pressed", "OptionButton", btn_style_pressed)
	global_theme.set_stylebox("disabled", "OptionButton", btn_style_disabled)
	global_theme.set_stylebox("focus", "OptionButton", btn_style_focus)

	global_theme.set_color("font_color", "OptionButton", COLOR_CYAN)
	global_theme.set_color("font_hover_color", "OptionButton", Color.WHITE)
	global_theme.set_color("font_pressed_color", "OptionButton", COLOR_YELLOW)

func _on_node_added(node: Node) -> void:
	if node is Control:
		# Defer styling so node dimensions and properties settle
		call_deferred("_check_and_style_control", node)

func _scan_and_style(node: Node) -> void:
	if node is Control:
		_check_and_style_control(node)
	for child in node.get_children():
		_scan_and_style(child)

func _check_and_style_control(ctrl: Control) -> void:
	if not is_instance_valid(ctrl):
		return

	if ctrl is Button:
		apply_button_style(ctrl)
	elif _is_card(ctrl):
		apply_card_style(ctrl)

func _is_card(ctrl: Control) -> bool:
	if ctrl.is_in_group("synthwave_card"):
		return true
	var n_name := ctrl.name.to_lower()
	if n_name.begins_with("card") or n_name.ends_with("card"):
		return true
	return false

func _get_sfx() -> Node:
	if not is_inside_tree():
		return null
	return get_node_or_null("/root/SoundEffects")

# ----------------------------------------------------
# Button Styling, Cursor & Micro-Scale Animation
# ----------------------------------------------------
func apply_button_style(btn: Button) -> void:
	# Ensure mouse cursor changes to pointing hand
	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

	# Apply synthwave styleboxes
	btn.add_theme_stylebox_override("normal", btn_style_normal)
	btn.add_theme_stylebox_override("hover", btn_style_hover)
	btn.add_theme_stylebox_override("pressed", btn_style_pressed)
	btn.add_theme_stylebox_override("disabled", btn_style_disabled)
	btn.add_theme_stylebox_override("focus", btn_style_focus)

	# Font colors
	btn.add_theme_color_override("font_color", COLOR_CYAN)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", COLOR_YELLOW)
	btn.add_theme_color_override("font_disabled_color", Color(0.45, 0.45, 0.55, 0.7))
	btn.add_theme_color_override("font_focus_color", COLOR_CYAN)

	if not btn.has_meta("synthwave_styled"):
		btn.set_meta("synthwave_styled", true)
		_setup_hover_tween(btn, 1.025)

		# Hook audio triggers
		btn.mouse_entered.connect(func():
			if not btn.disabled:
				var sfx := _get_sfx()
				if sfx and sfx.has_method("play_ui_hover"):
					sfx.play_ui_hover()
		)
		btn.pressed.connect(func():
			var sfx := _get_sfx()
			if sfx and sfx.has_method("play_ui_click"):
				sfx.play_ui_click()
		)

func apply_btn_style(btn: Button) -> void:
	apply_button_style(btn)

# ----------------------------------------------------
# Card Styling, Cursor & Interactivity
# ----------------------------------------------------
func apply_card_style(card: Control, is_unlocked: bool = true) -> void:
	if is_unlocked:
		card.mouse_filter = Control.MOUSE_FILTER_STOP
		card.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		card.add_theme_stylebox_override("panel", card_style_normal)
	else:
		card.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.mouse_default_cursor_shape = Control.CURSOR_ARROW
		card.add_theme_stylebox_override("panel", card_style_locked)

	if not card.has_meta("synthwave_card_styled"):
		card.set_meta("synthwave_card_styled", true)
		_setup_card_interactions(card)

func _setup_card_interactions(card: Control) -> void:
	_setup_hover_tween(card, 1.025)

	card.mouse_entered.connect(func():
		var is_locked: bool = card.has_meta("is_locked") and bool(card.get_meta("is_locked"))
		if not is_locked:
			card.add_theme_stylebox_override("panel", card_style_hover)
			var sfx := _get_sfx()
			if sfx and sfx.has_method("play_ui_hover"):
				sfx.play_ui_hover()
	)

	card.mouse_exited.connect(func():
		var is_locked: bool = card.has_meta("is_locked") and bool(card.get_meta("is_locked"))
		if is_locked:
			card.add_theme_stylebox_override("panel", card_style_locked)
		else:
			card.add_theme_stylebox_override("panel", card_style_normal)
	)

	# Full card click & activation handler (Mouse, Keyboard & Controller)
	card.gui_input.connect(func(event: InputEvent):
		var is_locked: bool = card.has_meta("is_locked") and bool(card.get_meta("is_locked"))
		if is_locked:
			return

		var triggered := false
		if event is InputEventMouseButton:
			var mb := event as InputEventMouseButton
			if mb.button_index == MOUSE_BUTTON_LEFT and mb.pressed:
				triggered = true
		elif event is InputEventKey:
			var k := event as InputEventKey
			if (k.keycode == KEY_ENTER or k.keycode == KEY_SPACE) and k.pressed and not k.echo:
				triggered = true
		elif event is InputEventJoypadButton:
			var jb := event as InputEventJoypadButton
			if jb.button_index == JOY_BUTTON_A and jb.pressed:
				triggered = true

		if triggered:
			var sfx := _get_sfx()
			if sfx and sfx.has_method("play_ui_click"):
				sfx.play_ui_click()

			# Check for custom callable or internal launch button
			var handled := false
			if card.has_meta("card_clicked_callable"):
				var cb = card.get_meta("card_clicked_callable")
				if cb is Callable:
					cb.call()
					handled = true
			if not handled:
				var launch_btn: Button = card.get_node_or_null("VBox/LaunchBtn")
				if launch_btn and not launch_btn.disabled:
					launch_btn.emit_signal("pressed")
	)

# ----------------------------------------------------
# Smooth Micro-Scale Tween (Pivot-Centered)
# ----------------------------------------------------
func _setup_hover_tween(target: Control, target_scale: float = 1.025) -> void:
	target.resized.connect(func():
		target.pivot_offset = target.size / 2.0
	)
	target.pivot_offset = target.size / 2.0

	target.mouse_entered.connect(func():
		var is_locked: bool = target.has_meta("is_locked") and bool(target.get_meta("is_locked"))
		if target is Button and (target as Button).disabled:
			return
		if is_locked:
			return

		target.pivot_offset = target.size / 2.0
		var tw := target.create_tween()
		tw.set_parallel(true)
		tw.set_ease(Tween.EASE_OUT)
		tw.set_trans(Tween.TRANS_BACK)
		tw.tween_property(target, "scale", Vector2(target_scale, target_scale), 0.12)
	)

	target.mouse_exited.connect(func():
		target.pivot_offset = target.size / 2.0
		var tw := target.create_tween()
		tw.set_parallel(true)
		tw.set_ease(Tween.EASE_OUT)
		tw.set_trans(Tween.TRANS_QUAD)
		tw.tween_property(target, "scale", Vector2.ONE, 0.10)
	)
