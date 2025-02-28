extends Node3D

@export var tile3D_scene: PackedScene
@export var spaces: Node3D
@export var bag: Node3D
@export var highlight: SpotLight3D
@export var rack_area: Area3D

var space_matrix: Array = []
var board_size: int = 9
var tiles_in_bag: Array
var rack_positions: Array

var tile_held
var tile_hovered

var space_hovered
var rack_hovered: bool

var mouse: Vector2
var grab_distance: float = 2.8

func _ready() -> void:
	rack_area.col.disabled = true

# runs when player class is init
func _on_player_ready() -> void:
	initialize_spaces()
	initialize_bag()
	deal_tiles()

func _process(delta: float) -> void:
#find the nearest rack position to the mouse
	var mouse_position: Vector3 = get_viewport().get_camera_3d().project_position(mouse,grab_distance)
	var nearest_rack_position: int = 0
	for i in rack_positions.size():
		if mouse_position.distance_to(rack_positions[i].global_position) < mouse_position.distance_to(rack_positions[nearest_rack_position].global_position):
			nearest_rack_position = i
	if tile_held:
		tile_held.global_position = tile_held.global_position.lerp(mouse_position, delta * 20)
		if rack_hovered:
			rearrange_rack(nearest_rack_position)
	if Input.is_action_just_pressed("left_mouse"):
		if tile_hovered:
			holding_tile(tile_hovered)
	if Input.is_action_just_released("left_mouse"):
		if !tile_held: return
		if space_hovered:
			tile_played(space_hovered, tile_held)
		else:
			tile_placed_on_rack(nearest_rack_position, tile_held)
		rack_area.col.disabled = true
		for i in rack_positions:
			if i.tile != null: i.tile.col.disabled = false
		tile_held = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.position

func holding_tile(t):
	#TODO enable space that tile was played in so another tile can be placed there
	tile_held = t
	rack_area.col.disabled = false
	for i in rack_positions:
		if i.tile != null: i.tile.col.disabled = true
	for i in rack_positions:
		if i.tile == t: i.tile = null

func rearrange_rack(nearest):
	if nearest == null: return
	if rack_positions[nearest].tile == null: return
	var empty = 10
	for i in rack_positions.size():
		if rack_positions[i].tile == null:
			if abs(nearest - i) < empty:
				empty = i
	if empty == 10: return
	if nearest > empty:
		for i in (nearest - empty):
			rack_positions[empty + i].set_tile(rack_positions[empty + i + 1].tile, .1)
		rack_positions[nearest].tile = null
	else: 
		for i in (empty-nearest):
			rack_positions[empty - i].set_tile(rack_positions[empty - i - 1].tile, .1)
		rack_positions[nearest].tile = null

func tile_played(s, t):
	#TODO disable space that tile is played in so another tile cant be placed there
	var tile_offset = Vector3(0,.18,0)
	t.global_position = s.global_position + tile_offset
	var row: int = int(s.name.left(1))
	var column: int = int(s.name.right(1))
	space_matrix[column-1][row-1] = t
	t.col.disabled = false

func tile_placed_on_rack(s, t):
	rearrange_rack(s)
	rack_positions[s].set_tile(t, .1)
	t.col.disabled = false

#creates array for tiles on board and tiles on rack, and connects space entered signals
func initialize_spaces():
	for i in board_size:
		space_matrix.append([])
		for j in board_size:
			space_matrix[i].append(null)
	for i in $Rack.get_children():
		rack_positions.append(i)
	for c in spaces.get_children():
		c.mouse_entered.connect(on_mouse_entered_space.bind(c))
		c.mouse_exited.connect(on_mouse_exited_space.bind(c))

# creates an array of tile3D objects which each have a reference to a tile that the player owns
# then shuffles the array to form the "bag"
func initialize_bag():
	for i in %Player.owned_tiles.size():
		var new_tile = tile3D_scene.instantiate()
		tiles_in_bag.append(new_tile)
		add_child(new_tile)
		new_tile.global_position = bag.global_position
		new_tile.tile_reference = i
		new_tile.player = %Player
		new_tile.update_tile()
		new_tile.mouse_entered.connect(on_mouse_entered_tile.bind(new_tile))
		new_tile.mouse_exited.connect(on_mouse_exited_tile.bind(new_tile))
	tiles_in_bag.shuffle()

func deal_tiles():
	#TODO shuffle all existing tiles to the left, then check how many tiles need to be dealt
	for i in rack_positions:
		if i.tile == null:
			i.set_tile(tiles_in_bag.pop_back(), .2)
		await wait(.2)

func on_mouse_entered_space(space):
	var light_height_offset: Vector3 = Vector3(0, .3, 0)
	space_hovered = space
	highlight.visible = true
	highlight.global_position = space.global_position + light_height_offset
func on_mouse_exited_space(_space):
	space_hovered = null
	highlight.visible = false

func on_mouse_entered_tile(t) -> void:
	tile_hovered = t
func on_mouse_exited_tile(_t) -> void:
	tile_hovered = null

func on_mouse_entered_rack() -> void:
	rack_hovered = true
func on_mouse_exited_rack() -> void:
	rack_hovered = false

func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout
