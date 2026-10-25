"""
tools/generate_assets.py
Headless 3D Asset Generator for ISV BRO (Godot 4.x)
Run via: /Applications/Blender.app/Contents/MacOS/Blender -b -P tools/generate_assets.py
"""
import bpy
import os
import math

OUTPUT_DIR = os.path.abspath("assets/models")
os.makedirs(OUTPUT_DIR, exist_ok=True)

def clear_scene():
    bpy.ops.wm.read_factory_settings(use_empty=True)

def make_material(name, base_color, roughness=0.3, metallic=0.6, emission=(0, 0, 0, 1), emission_strength=1.0):
    mat = bpy.data.materials.new(name=name)
    bsdf = mat.node_tree.nodes.get("Principled BSDF")
    if bsdf:
        if "Base Color" in bsdf.inputs:
            bsdf.inputs["Base Color"].default_value = base_color
        if "Roughness" in bsdf.inputs:
            bsdf.inputs["Roughness"].default_value = roughness
        if "Metallic" in bsdf.inputs:
            bsdf.inputs["Metallic"].default_value = metallic
        if "Emission Color" in bsdf.inputs:
            bsdf.inputs["Emission Color"].default_value = emission
        elif "Emission" in bsdf.inputs:
            bsdf.inputs["Emission"].default_value = emission
        if "Emission Strength" in bsdf.inputs:
            bsdf.inputs["Emission Strength"].default_value = emission_strength
    return mat

def export_glb(filename):
    out_path = os.path.join(OUTPUT_DIR, filename)
    bpy.ops.export_scene.gltf(
        filepath=out_path,
        export_format='GLB',
        use_selection=False,
        export_apply=True
    )
    print(f"[EXPORTED] {out_path}")

# 1. Hadron Jet (Player Ship)
clear_scene()
mat_hull = make_material("ObsidianHull", (0.06, 0.06, 0.1, 1.0), roughness=0.2, metallic=0.9)
mat_wing = make_material("NeonMagenta", (1.0, 0.0, 0.5, 1.0), roughness=0.3, metallic=0.5, emission=(1.0, 0.0, 0.5, 1.0), emission_strength=2.0)
mat_cyan = make_material("ElectricCyan", (0.0, 0.94, 1.0, 1.0), roughness=0.1, metallic=0.2, emission=(0.0, 0.94, 1.0, 1.0), emission_strength=3.0)

bpy.ops.mesh.primitive_cone_add(vertices=6, radius1=0.65, radius2=0.05, depth=2.8)
fuselage = bpy.context.active_object
fuselage.rotation_euler = (-math.pi / 2, 0, 0)
fuselage.data.materials.append(mat_hull)

bpy.ops.mesh.primitive_cube_add(size=1.0, location=(0, 0.2, -0.05))
wings = bpy.context.active_object
wings.scale = (2.2, 0.65, 0.08)
wings.data.materials.append(mat_wing)

for side in (-0.85, 0.85):
    bpy.ops.mesh.primitive_cylinder_add(vertices=8, radius=0.18, depth=1.6, location=(side, 0.3, 0.0))
    nacelle = bpy.context.active_object
    nacelle.rotation_euler = (math.pi / 2, 0, 0)
    nacelle.data.materials.append(mat_cyan)

export_glb("hadron_jet.glb")

# 2. Sector 01 Anomaly: Bio-Cytology Construct
clear_scene()
mat_bio = make_material("BioLime", (0.22, 1.0, 0.08, 1.0), roughness=0.2, emission=(0.22, 1.0, 0.08, 1.0), emission_strength=2.2)
mat_cyan = make_material("ElectricCyan", (0.0, 0.94, 1.0, 1.0), roughness=0.1, metallic=0.2, emission=(0.0, 0.94, 1.0, 1.0), emission_strength=3.0)
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.9)
core = bpy.context.active_object
core.data.materials.append(mat_bio)
bpy.ops.mesh.primitive_torus_add(major_radius=1.35, minor_radius=0.12, rotation=(0.6, 0.4, 0))
ring = bpy.context.active_object
ring.data.materials.append(mat_cyan)
export_glb("anomaly_bio.glb")

# 3. Sector 02 Anomaly: Astro-Celestial Gyro
clear_scene()
mat_gold = make_material("AstroGold", (1.0, 0.9, 0.0, 1.0), roughness=0.2, emission=(1.0, 0.85, 0.0, 1.0), emission_strength=2.5)
mat_cyan = make_material("ElectricCyan", (0.0, 0.94, 1.0, 1.0), roughness=0.1, metallic=0.2, emission=(0.0, 0.94, 1.0, 1.0), emission_strength=3.0)
bpy.ops.mesh.primitive_uv_sphere_add(segments=12, ring_count=8, radius=0.75)
star = bpy.context.active_object
star.data.materials.append(mat_gold)
for rot in [(0.8, 0, 0), (0, 0.8, 0.8)]:
    bpy.ops.mesh.primitive_torus_add(major_radius=1.4, minor_radius=0.1, rotation=rot)
    r = bpy.context.active_object
    r.data.materials.append(mat_cyan)
export_glb("anomaly_astro.glb")

# 4. Sector 03 Anomaly: Geo-Lithic Crystal
clear_scene()
mat_geo = make_material("GeoAmber", (1.0, 0.55, 0.0, 1.0), roughness=0.15, metallic=0.7, emission=(1.0, 0.4, 0.0, 1.0), emission_strength=2.0)
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=1, radius=1.15)
crystal = bpy.context.active_object
crystal.scale = (0.85, 0.85, 1.45)
crystal.data.materials.append(mat_geo)
export_glb("anomaly_geo.glb")

# 5. Sector 04 Anomaly: Thermo-Quantum Torus
clear_scene()
mat_wing = make_material("NeonMagenta", (1.0, 0.0, 0.5, 1.0), roughness=0.3, metallic=0.5, emission=(1.0, 0.0, 0.5, 1.0), emission_strength=2.0)
mat_cyan = make_material("ElectricCyan", (0.0, 0.94, 1.0, 1.0), roughness=0.1, metallic=0.2, emission=(0.0, 0.94, 1.0, 1.0), emission_strength=3.0)
bpy.ops.mesh.primitive_torus_add(major_radius=1.1, minor_radius=0.32)
torus = bpy.context.active_object
torus.data.materials.append(mat_wing)
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.55)
qcore = bpy.context.active_object
qcore.data.materials.append(mat_cyan)
export_glb("anomaly_thermo.glb")

# 6. Physical Hazard: Crimson Laser Gate
clear_scene()
mat_hazard = make_material("CrimsonHazard", (1.0, 0.0, 0.2, 1.0), roughness=0.3, emission=(1.0, 0.0, 0.15, 1.0), emission_strength=3.0)
bpy.ops.mesh.primitive_cube_add(size=1.0)
bar = bpy.context.active_object
bar.scale = (2.8, 0.35, 0.35)
bar.data.materials.append(mat_hazard)
export_glb("hazard_laser_gate.glb")

# 7. Tunnel Environment: Particle Collider Ring
clear_scene()
mat_arch = make_material("ColliderArch", (0.08, 0.1, 0.18, 1.0), roughness=0.4, metallic=0.8, emission=(0.0, 0.35, 0.5, 1.0), emission_strength=0.8)
bpy.ops.mesh.primitive_torus_add(major_segments=8, minor_segments=6, major_radius=9.5, minor_radius=0.35)
arch = bpy.context.active_object
arch.rotation_euler = (math.pi / 2, 0, 0)
arch.data.materials.append(mat_arch)
export_glb("hazard_collider_ring.glb")

# 8. Pickup: Cryo-Coolant Cell
clear_scene()
mat_cyan = make_material("ElectricCyan", (0.0, 0.94, 1.0, 1.0), roughness=0.1, metallic=0.2, emission=(0.0, 0.94, 1.0, 1.0), emission_strength=3.0)
bpy.ops.mesh.primitive_cylinder_add(vertices=10, radius=0.45, depth=1.2)
cell = bpy.context.active_object
cell.data.materials.append(mat_cyan)
export_glb("pickup_coolant_cell.glb")

# 9. Pickup: Shield Harmonic Orb
clear_scene()
mat_bio = make_material("BioLime", (0.22, 1.0, 0.08, 1.0), roughness=0.2, emission=(0.22, 1.0, 0.08, 1.0), emission_strength=2.2)
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=0.55)
orb = bpy.context.active_object
orb.data.materials.append(mat_bio)
export_glb("pickup_shield_orb.glb")

# 10. Boss Exam Core
clear_scene()
mat_wing = make_material("NeonMagenta", (1.0, 0.0, 0.5, 1.0), roughness=0.3, metallic=0.5, emission=(1.0, 0.0, 0.5, 1.0), emission_strength=2.0)
mat_cyan = make_material("ElectricCyan", (0.0, 0.94, 1.0, 1.0), roughness=0.1, metallic=0.2, emission=(0.0, 0.94, 1.0, 1.0), emission_strength=3.0)
bpy.ops.mesh.primitive_ico_sphere_add(subdivisions=2, radius=1.8)
bcore = bpy.context.active_object
bcore.data.materials.append(mat_wing)
for radius, rot in [(2.7, (0.5, 0.2, 0)), (3.3, (-0.4, 0.6, 0.3))]:
    bpy.ops.mesh.primitive_torus_add(major_radius=radius, minor_radius=0.22, rotation=rot)
    bring = bpy.context.active_object
    bring.data.materials.append(mat_cyan)
export_glb("boss_core.glb")

print("\n>>> ALL 10 ISV BRO 3D ASSETS GENERATED SUCCESSFULLY! <<<")
