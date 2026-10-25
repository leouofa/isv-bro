# tools/generate_fallback_meshes.gd
@tool
extends SceneTree

# Fallback generator for systems without Blender
func _init() -> void:
	print("Fallback mesh generator available.")
	quit(0)
