class_name GameMap extends Node2D

const NAV_BORDER: int = 8

var layers: Array[TileMapLayer] = []
var area: Area2D = null
var navigation: NavigationRegion2D = null

func _ready() -> void:
	await get_layers()
	create_area()
	await get_tree().physics_frame
	create_navigation()

func get_layers(p: Node = self) -> void:
	for c: Node in p.get_children():
		if is_instance_of(c, TileMapLayer):
			layers.append(c)
			if !c.is_node_ready():
				await c.ready
		if c.get_child_count() > 0:
			get_layers(c)

func create_area() -> void:
	var region: Rect2 = get_region()
	area = Area2D.new()
	add_child(area)
	var shape: CollisionShape2D = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = region.size
	shape.debug_color = Color(0.5, 0.2, 0.1, 0.1)
	area.add_child(shape)
	area.position = region.position + region.size * 0.5

func create_navigation() -> void:
	var region: Rect2 = get_region()
	navigation = NavigationRegion2D.new()
	var polygon: NavigationPolygon = NavigationPolygon.new()
	var vertices: PackedVector2Array = PackedVector2Array([region.position - Vector2(NAV_BORDER,NAV_BORDER),Vector2(region.end.x,region.position.y) + Vector2(NAV_BORDER,-NAV_BORDER),region.end + Vector2(NAV_BORDER,NAV_BORDER),Vector2(region.position.x, region.end.y) - Vector2(NAV_BORDER,-NAV_BORDER)])
	polygon.add_outline(vertices)
	polygon.agent_radius = NAV_BORDER
	polygon.source_geometry_mode = NavigationPolygon.SOURCE_GEOMETRY_GROUPS_WITH_CHILDREN
	polygon.cell_size = 2.0
	polygon.border_size = 32
	var group_name := "map_nav"
	polygon.source_geometry_group_name = group_name
	set_layers_group(group_name)
	add_child(navigation)
	NavigationServer2D.map_set_cell_size(navigation.get_navigation_map(), polygon.cell_size)
	if !navigation.is_inside_tree():
		await navigation.tree_entered
	NavigationServer2D.bake_from_source_geometry_data(polygon, NavigationMeshSourceGeometryData2D.new(), func() -> void:
		navigation.navigation_polygon = polygon
	)
	navigation.bake_navigation_polygon()
	await navigation.bake_finished

func get_region() -> Rect2:
	var region: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
	for layer: TileMapLayer in layers:
		var used: Rect2 = Rect2(layer.get_used_rect())
		used.position *= Vector2(layer.tile_set.tile_size)
		used.size *= Vector2(layer.tile_set.tile_size)
		if used.size > region.size:
			region = used
	return region

func set_layers_group(group: String) -> void:
	for layer: TileMapLayer in layers:
		layer.add_to_group(group)
