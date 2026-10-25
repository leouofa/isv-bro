# scripts/TitleBackground3D.gd
extends Node3D

@onready var camera: Camera3D = $Camera3D
@onready var rings_container: Node3D = $RingsContainer

const RING_MODEL: PackedScene = preload("res://assets/models/hazard_collider_ring.glb")
const NUM_RINGS := 7
const RING_SPACING := 8.0
const RING_SPEED := 6.0
const TOTAL_SPAN := NUM_RINGS * RING_SPACING

var rings: Array[Node3D] = []
var time_elapsed: float = 0.0

func _ready() -> void:
	setup_rings()

func setup_rings() -> void:
	if RING_MODEL == null:
		return
	
	for i in range(NUM_RINGS):
		var ring := RING_MODEL.instantiate() as Node3D
		# Center rings slightly above the grid plane
		ring.position = Vector3(0, 1.2, -float(i) * RING_SPACING)
		ring.scale = Vector3(1.1, 1.1, 1.1)
		rings_container.add_child(ring)
		rings.append(ring)

func _process(delta: float) -> void:
	time_elapsed += delta

	# Subtle, smooth camera breathing and sway
	if camera:
		camera.position.x = sin(time_elapsed * 0.35) * 0.35
		camera.position.y = 1.7 + sin(time_elapsed * 0.5) * 0.08
		camera.rotation.z = -sin(time_elapsed * 0.35) * 0.018

	# Move rings forward along Z towards camera
	for ring in rings:
		ring.position.z += RING_SPEED * delta
		# When behind camera, wrap back to the far distance
		if ring.position.z > 8.0:
			ring.position.z -= TOTAL_SPAN
