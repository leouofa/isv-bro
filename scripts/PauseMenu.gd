# scripts/PauseMenu.gd
extends CanvasLayer

@onready var panel: Control = $Panel
@onready var resume_btn: Button = $Panel/VBox/ResumeBtn
@onready var restart_btn: Button = $Panel/VBox/RestartBtn
@onready var exit_btn: Button = $Panel/VBox/ExitBtn

@onready var confirm_dimmer: ColorRect = $ConfirmDimmer
@onready var confirm_box: Control = $ConfirmBox
@onready var confirm_label: Label = $ConfirmBox/VBox/Label
@onready var confirm_yes_btn: Button = $ConfirmBox/VBox/HBox/YesBtn
@onready var confirm_no_btn: Button = $ConfirmBox/VBox/HBox/NoBtn

var pending_action: String = ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	if confirm_dimmer:
		confirm_dimmer.visible = false
	if confirm_box:
		confirm_box.visible = false

	if resume_btn:
		resume_btn.pressed.connect(resume_game)
	if restart_btn:
		restart_btn.pressed.connect(func(): _ask_confirmation("restart", "RESTART CURRENT SECTOR?"))
	if exit_btn:
		exit_btn.pressed.connect(func(): _ask_confirmation("exit", "ABORT TO MAIN MENU?"))

	if confirm_yes_btn:
		confirm_yes_btn.pressed.connect(_on_confirm_yes)
	if confirm_no_btn:
		confirm_no_btn.pressed.connect(_on_confirm_no)

func _set_panel_buttons_enabled(enabled: bool) -> void:
	for btn in [resume_btn, restart_btn, exit_btn]:
		if btn:
			btn.disabled = not enabled
			btn.focus_mode = Control.FOCUS_ALL if enabled else Control.FOCUS_NONE

func _get_tree_safe() -> SceneTree:
	if is_inside_tree() and get_tree():
		return get_tree()
	var main_loop := Engine.get_main_loop()
	if main_loop is SceneTree:
		return main_loop as SceneTree
	if Engine.has_meta("active_tree"):
		return Engine.get_meta("active_tree") as SceneTree
	return null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") or (confirm_box and confirm_box.visible and event.is_action_pressed("ui_cancel")):
		if confirm_box and confirm_box.visible:
			_on_confirm_no()
			get_viewport().set_input_as_handled()
			return
		var tree := _get_tree_safe()
		if tree and tree.paused:
			resume_game()
		else:
			pause_game()
		get_viewport().set_input_as_handled()

func pause_game() -> void:
	visible = true
	var tree := _get_tree_safe()
	if tree:
		tree.paused = true
	if is_inside_tree() and has_node("/root/MusicManager"):
		get_node("/root/MusicManager").set_low_pass_enabled(true)
	if resume_btn and is_inside_tree() and resume_btn.is_inside_tree():
		resume_btn.grab_focus()

func resume_game() -> void:
	visible = false
	if confirm_dimmer:
		confirm_dimmer.visible = false
	if confirm_box:
		confirm_box.visible = false
	_set_panel_buttons_enabled(true)
	var tree := _get_tree_safe()
	if tree:
		tree.paused = false
	if is_inside_tree() and has_node("/root/MusicManager"):
		get_node("/root/MusicManager").set_low_pass_enabled(false)

func _ask_confirmation(action: String, message: String) -> void:
	pending_action = action
	if confirm_label:
		confirm_label.text = message
	if confirm_dimmer:
		confirm_dimmer.visible = true
	if confirm_box:
		confirm_box.visible = true
	_set_panel_buttons_enabled(false)
	if confirm_no_btn and is_inside_tree() and confirm_no_btn.is_inside_tree():
		confirm_no_btn.grab_focus()

func _on_confirm_yes() -> void:
	if confirm_dimmer:
		confirm_dimmer.visible = false
	if confirm_box:
		confirm_box.visible = false
	_set_panel_buttons_enabled(true)
	resume_game()
	var tree := _get_tree_safe()
	if tree:
		if pending_action == "restart":
			tree.reload_current_scene()
		elif pending_action == "exit":
			tree.change_scene_to_file("res://scenes/MainMenu.tscn")

func _on_confirm_no() -> void:
	if confirm_dimmer:
		confirm_dimmer.visible = false
	if confirm_box:
		confirm_box.visible = false
	_set_panel_buttons_enabled(true)
	if resume_btn and is_inside_tree() and resume_btn.is_inside_tree():
		resume_btn.grab_focus()
