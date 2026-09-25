class_name EnvironmentMaterialBuilder
extends RefCounted

const SurfaceSpec = preload("res://environment_authoring/environment_surface_material_spec.gd")

func build(spec: Resource) -> StandardMaterial3D:
	if spec == null or not spec.validate().is_empty():
		push_error("Cannot build invalid environment material spec")
		return null
	var material := StandardMaterial3D.new()
	material.resource_name = spec.material_id
	material.albedo_texture = spec.base_color_texture
	material.albedo_color = Color(spec.albedo_multiplier, spec.albedo_multiplier, spec.albedo_multiplier)
	material.normal_enabled = spec.normal_texture != null
	material.normal_texture = _normal_texture(spec.normal_texture, spec.normal_y_flip)
	material.normal_scale = spec.normal_strength
	material.roughness_texture = spec.roughness_texture
	material.roughness = spec.roughness_multiplier
	material.metallic_texture = spec.metallic_texture
	material.metallic = spec.metallic_multiplier if spec.metallic_texture != null else 0.0
	material.ao_enabled = spec.ao_texture != null
	material.ao_texture = spec.ao_texture
	material.heightmap_enabled = false
	material.uv1_triplanar = spec.mapping_mode != SurfaceSpec.MappingMode.UV
	material.uv1_world_triplanar = spec.mapping_mode == SurfaceSpec.MappingMode.WORLD_TRIPLANAR
	# Review UVs are authored in metres. Triplanar uses local/world metres.
	# Both therefore need the same reciprocal conversion: a 0.5 m repeat -> scale 2.
	var repeats_per_metre: float = 1.0 / spec.meters_per_repeat
	material.uv1_scale = Vector3.ONE * repeats_per_metre
	material.texture_filter = BaseMaterial3D.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS_ANISOTROPIC
	return material


func _normal_texture(source: Texture2D, flip_y: bool) -> Texture2D:
	if source == null or not flip_y:
		return source
	# StandardMaterial3D has no per-material normal-green inversion in Godot 4.7.
	# Make a transient copy of the imported texture; source PNG bytes remain intact.
	var source_image := source.get_image()
	var image: Image = source_image.duplicate() if source_image != null else null
	if image == null or image.is_empty():
		push_error("Normal texture has no readable image")
		return null
	if image.is_compressed() and image.decompress() != OK:
		push_error("Could not decompress normal texture for Y inversion")
		return null
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var pixel: Color = image.get_pixel(x, y)
			pixel.g = 1.0 - pixel.g
			image.set_pixel(x, y, pixel)
	image.generate_mipmaps()
	return ImageTexture.create_from_image(image)
