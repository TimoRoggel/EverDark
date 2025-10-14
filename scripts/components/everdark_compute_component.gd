class_name EverdarkComputeComponent
extends Component

const EVERDARK_SHADER: RDShaderFile = preload("uid://c8qixv7npp02w")
const MAX_LIGHTS := 1024

@export var affected_sprite: Sprite2D

# RD / GPU resources (declare all of them)
var rd: RenderingDevice = null
var shader_rid: RID = RID()
var pipeline_rid: RID = RID()
var uniform_set_rid: RID = RID()

var src_tex_rid: RID = RID()
var dst_tex_rid: RID = RID()
var dst_texture2drd: Texture2DRD = null

var lights_storage_rid: RID = RID()
var ub_light_count_rid: RID = RID()
var ub_falloff_start_rid: RID = RID()
var ub_falloff_end_rid: RID = RID()

# Cached CPU-side data
var last_lights_hash: int = 0
var last_falloff_start: float = 128.0
var last_falloff_end: float = 160.0

func _enter() -> void:
	return
	# get main rendering device
	rd = RenderingServer.get_rendering_device()

	# create shader and pipeline
	shader_rid = rd.shader_create_from_spirv(EVERDARK_SHADER.get_spirv())
	pipeline_rid = rd.compute_pipeline_create(shader_rid)

	# prepare source and destination RD textures
	_create_src_and_dst_textures()

	# create initial buffers and uniform set
	_rebuild_buffers_and_uniforms(true)


func _update(_delta: float) -> void:
	return
	# If lights move or falloff changes, update buffers (this function will check and update only what's needed)
	_rebuild_buffers_and_uniforms(false)

	# dispatch compute
	var list = rd.compute_list_begin()
	rd.compute_list_bind_compute_pipeline(list, pipeline_rid)
	rd.compute_list_bind_uniform_set(list, uniform_set_rid, 0)

	var w := int(affected_sprite.texture.get_width())
	var h := int(affected_sprite.texture.get_height())
	var dispatch_x := int(ceil(float(w) / 8.0))
	var dispatch_y := int(ceil(float(h) / 8.0))

	rd.compute_list_dispatch(list, dispatch_x, dispatch_y, 1)
	rd.compute_list_end()
	rd.submit()


func _exit() -> void:
	# free RIDs if valid
	if uniform_set_rid and uniform_set_rid.is_valid(): rd.free_rid(uniform_set_rid)
	if pipeline_rid and pipeline_rid.is_valid(): rd.free_rid(pipeline_rid)
	if shader_rid and shader_rid.is_valid(): rd.free_rid(shader_rid)
	if lights_storage_rid and lights_storage_rid.is_valid(): rd.free_rid(lights_storage_rid)
	if ub_light_count_rid and ub_light_count_rid.is_valid(): rd.free_rid(ub_light_count_rid)
	if ub_falloff_start_rid and ub_falloff_start_rid.is_valid(): rd.free_rid(ub_falloff_start_rid)
	if ub_falloff_end_rid and ub_falloff_end_rid.is_valid(): rd.free_rid(ub_falloff_end_rid)
	if dst_tex_rid and dst_tex_rid.is_valid(): rd.free_rid(dst_tex_rid)
	if src_tex_rid and src_tex_rid.is_valid(): rd.free_rid(src_tex_rid)


# -------------------------
# Texture and RD setup
# -------------------------
func _create_src_and_dst_textures() -> void:
	# source texture: sample existing Sprite2D texture
	var src_texture : Texture2D = affected_sprite.texture
	var img := src_texture.get_image()
	var w := img.get_width()
	var h := img.get_height()
	var bytes := img.get_data() # PackedByteArray

	# Create RDTextureFormat for RGBA8 sampling (sampled input)
	var fmt := RDTextureFormat.new()
	fmt.width = w
	fmt.height = h
	fmt.depth = 1
	fmt.format = RenderingDevice.DATA_FORMAT_R8G8B8A8_UNORM
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT

	# create RD texture for source (sampler)
	src_tex_rid = rd.texture_create(fmt, RDTextureView.new(), [bytes])

	# create RD texture for destination (storage + sampling + copy-from)
	fmt.usage_bits = RenderingDevice.TEXTURE_USAGE_STORAGE_BIT | RenderingDevice.TEXTURE_USAGE_SAMPLING_BIT | RenderingDevice.TEXTURE_USAGE_CAN_COPY_FROM_BIT

	# initial zero bytes for dst
	var init_size := w * h * 4
	var init_bytes := PackedByteArray()
	init_bytes.resize(init_size) # zero initialized

	dst_tex_rid = rd.texture_create(fmt, RDTextureView.new(), [init_bytes])

	# Wrap destination in Texture2DRD so Sprite2D can display it
	dst_texture2drd = Texture2DRD.new()
	dst_texture2drd.texture_rd_rid = dst_tex_rid
	affected_sprite.texture = dst_texture2drd


# -------------------------
# Buffers, uniform set
# -------------------------
func _rebuild_buffers_and_uniforms(force_recreate: bool) -> void:
	# Prepare lights data
	var lights : PackedVector2Array = Generator.lumin_positions # replace with your source
	var lights_bytes : PackedByteArray = lumin_byte_positions(lights, MAX_LIGHTS)
	var lights_hash := _hash_bytes(lights_bytes)

	# Check if we need to recreate or update lights storage buffer
	if force_recreate or lights_storage_rid == null or not lights_storage_rid.is_valid() or lights_hash != last_lights_hash:
		# (re)create or update storage buffer
		if lights_storage_rid and lights_storage_rid.is_valid():
			# try to update if available, otherwise recreate
			if rd.has_method("storage_buffer_update"):
				rd.storage_buffer_update(lights_storage_rid, 0, lights_bytes)
			else:
				rd.free_rid(lights_storage_rid)
				lights_storage_rid = rd.storage_buffer_create(lights_bytes.size(), lights_bytes)
		else:
			lights_storage_rid = rd.storage_buffer_create(lights_bytes.size(), lights_bytes)

		last_lights_hash = lights_hash

	# light count uniform buffer
	var light_count_bytes := PackedInt32Array([lights.size()]).to_byte_array()
	if force_recreate or ub_light_count_rid == null or not ub_light_count_rid.is_valid():
		ub_light_count_rid = rd.uniform_buffer_create(light_count_bytes.size(), light_count_bytes)
	else:
		if rd.has_method("uniform_buffer_update"):
			rd.uniform_buffer_update(ub_light_count_rid, 0, light_count_bytes)
		else:
			rd.free_rid(ub_light_count_rid)
			ub_light_count_rid = rd.uniform_buffer_create(light_count_bytes.size(), light_count_bytes)

	# falloff start uniform buffer
	var falloff_start_bytes := PackedFloat32Array([last_falloff_start]).to_byte_array()
	if force_recreate or ub_falloff_start_rid == null or not ub_falloff_start_rid.is_valid():
		ub_falloff_start_rid = rd.uniform_buffer_create(falloff_start_bytes.size(), falloff_start_bytes)
	else:
		if rd.has_method("uniform_buffer_update"):
			rd.uniform_buffer_update(ub_falloff_start_rid, 0, falloff_start_bytes)
		else:
			rd.free_rid(ub_falloff_start_rid)
			ub_falloff_start_rid = rd.uniform_buffer_create(falloff_start_bytes.size(), falloff_start_bytes)

	# falloff end uniform buffer
	var falloff_end_bytes := PackedFloat32Array([last_falloff_end]).to_byte_array()
	if force_recreate or ub_falloff_end_rid == null or not ub_falloff_end_rid.is_valid():
		ub_falloff_end_rid = rd.uniform_buffer_create(falloff_end_bytes.size(), falloff_end_bytes)
	else:
		if rd.has_method("uniform_buffer_update"):
			rd.uniform_buffer_update(ub_falloff_end_rid, 0, falloff_end_bytes)
		else:
			rd.free_rid(ub_falloff_end_rid)
			ub_falloff_end_rid = rd.uniform_buffer_create(falloff_end_bytes.size(), falloff_end_bytes)

	# Finally build uniform list and create uniform set
	var uniforms := []

	# Binding 0: source sampled texture
	var u0 := RDUniform.new()
	u0.uniform_type = RenderingDevice.UNIFORM_TYPE_TEXTURE
	u0.binding = 0
	u0.add_id(src_tex_rid)
	uniforms.append(u0)

	# Binding 1: destination writable image
	var u1 := RDUniform.new()
	u1.uniform_type = RenderingDevice.UNIFORM_TYPE_IMAGE
	u1.binding = 1
	u1.add_id(dst_tex_rid)
	uniforms.append(u1)

	# Binding 2: lights storage buffer
	var u2 := RDUniform.new()
	u2.uniform_type = RenderingDevice.UNIFORM_TYPE_STORAGE_BUFFER
	u2.binding = 2
	u2.add_id(lights_storage_rid)
	uniforms.append(u2)

	# Binding 3: light count uniform buffer
	var u3 := RDUniform.new()
	u3.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	u3.binding = 3
	u3.add_id(ub_light_count_rid)
	uniforms.append(u3)

	# Binding 4: falloff_start uniform buffer
	var u4 := RDUniform.new()
	u4.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	u4.binding = 4
	u4.add_id(ub_falloff_start_rid)
	uniforms.append(u4)

	# Binding 5: falloff_end uniform buffer
	var u5 := RDUniform.new()
	u5.uniform_type = RenderingDevice.UNIFORM_TYPE_UNIFORM_BUFFER
	u5.binding = 5
	u5.add_id(ub_falloff_end_rid)
	uniforms.append(u5)

	# replace uniform set
	if uniform_set_rid and uniform_set_rid.is_valid():
		rd.free_rid(uniform_set_rid)
	uniform_set_rid = rd.uniform_set_create(uniforms, shader_rid, 0)


# -------------------------
# Helpers
# -------------------------
func lumin_byte_positions(lumin_positions: PackedVector2Array, max_lumin_count: int) -> PackedByteArray:
	var data := PackedFloat32Array()
	for i in range(max_lumin_count):
		if i < lumin_positions.size():
			var pos := lumin_positions[i]
			data.append(pos.x)
			data.append(pos.y)
		else:
			data.append(0.0)
			data.append(0.0)
	return data.to_byte_array()


func _hash_bytes(b: PackedByteArray) -> int:
	# cheap hash to detect changes to lights bytes
	var h := 2166136261
	for i in b:
		h = (h ^ i) * 16777619
	return int(h & 0x7fffffff)
