# scripts/Anomaly.gd
extends Area3D

signal destroyed(anomaly_node: Node3D)

@export var move_speed: float = 14.0
@export var oscillation_speed: float = 2.0
@export var oscillation_amplitude: float = 0.5

var root_data: Dictionary = {}
var prompt_data: Dictionary = {}
var sector_id: int = 1
var is_destroyed: bool = false
var time_alive: float = 0.0
var base_x: float = 0.0
var base_y: float = 0.0

@onready var label_3d: Label3D = $Label3D
@onready var model_container: Node3D = $ModelContainer

const MODEL_PATHS := {
	1: "res://assets/models/anomaly_bio.glb",
	2: "res://assets/models/anomaly_astro.glb",
	3: "res://assets/models/anomaly_geo.glb",
	4: "res://assets/models/anomaly_thermo.glb"
}

func _ready() -> void:
	add_to_group("anomalies")
	base_x = position.x
	base_y = position.y

func setup(target_root: Dictionary, sector: int) -> void:
	root_data = target_root
	sector_id = sector
	if has_node("/root/LexiconManager"):
		prompt_data = get_node("/root/LexiconManager").build_multiple_choice_prompt(root_data.get("id", "bio"), 4)

	# Update 3D Billboard label
	if label_3d:
		var clue_text: String = root_data.get("meaning", "").to_upper()
		label_3d.text = "[ " + clue_text + " ]"
		label_3d.modulate = Color("#FFF033")
		label_3d.outline_modulate = Color(0, 0, 0, 1)
		label_3d.outline_size = 14
		label_3d.font_size = 48

	# Instantiate Sector-specific 3D Model
	if model_container:
		for child in model_container.get_children():
			child.queue_free()
		var model_path: String = MODEL_PATHS.get(sector_id, MODEL_PATHS[1])
		if ResourceLoader.exists(model_path):
			var packed := load(model_path) as PackedScene
			if packed:
				var inst := packed.instantiate()
				model_container.add_child(inst)

func _physics_process(delta: float) -> void:
	if is_destroyed:
		return
	time_alive += delta

	# Rail advance toward camera (+Z)
	position.z += move_speed * delta

	# Gentle floating oscillation
	position.x = base_x + sin(time_alive * oscillation_speed) * oscillation_amplitude
	position.y = base_y + cos(time_alive * oscillation_speed * 0.8) * (oscillation_amplitude * 0.6)

	if model_container:
		model_container.rotate_y(1.2 * delta)
		model_container.rotate_x(0.8 * delta)

	# If it travels past the player (z > 8.0), register a miss
	if position.z > 8.0:
		if has_node("/root/GameManager"):
			get_node("/root/GameManager").register_root_miss(root_data.get("id", ""))
		destroyed.emit(self)
		queue_free()

func detonate() -> void:
	if is_destroyed:
		return
	is_destroyed = true
	destroyed.emit(self)
	# Simple shrink animation before free
	var tween := create_tween()
	tween.tween_property(self, "scale", Vector3.ZERO, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.tween_callback(queue_free)
