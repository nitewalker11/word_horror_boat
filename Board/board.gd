extends Node3D

@export var tile3D_scene: PackedScene
@export var spaces: Node3D
@export var bag: Node3D
@export var highlight: SpotLight3D
@export var rack_area: Area3D
@export var discard_area: Area3D

var board_positions: Array = []
var board_size: int = 9
var tiles_in_bag: Array
var rack_positions: Array
var discard_positions: Array

var tile_held
var tile_hovered

var space_hovered
var rack_hovered: bool
var discard_hovered: bool
var discard_button_hovered: bool
var play_button_hovered: bool

var mouse: Vector2
var grab_distance: float = 2.8

var selected_blank: Node3D
var space_for_blank: Node3D
var alphabet: String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
var typed_letter: String = ""

func _ready() -> void:
	rack_area.col.disabled = true

# runs when player class is init
func _on_player_ready() -> void:
	initialize_spaces()
	initialize_bag()
	deal_tiles()

func _process(delta: float) -> void:
	#dont run other game controls until blank has been selected
	if selected_blank:
		if Input.is_action_just_pressed("left_mouse") or Input.is_action_just_pressed("confirm"):
			space_for_blank.set_tile(selected_blank)
			selected_blank.place_blank()
			selected_blank = null
			return
		blank_selection()
		return
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
		if discard_button_hovered:
			for i in discard_positions:
				if i.tile != null: i.pickup_tile().queue_free()
			deal_tiles()
			pass
		if play_button_hovered:
			pass
	if Input.is_action_just_released("left_mouse"):
		if !tile_held: return
		if space_hovered:
			tile_placed_on_board(space_hovered, tile_held)
		elif tile_hovered:
			var cur_space = tile_hovered.location
			var swapped_tile = tile_hovered.location.pickup_tile()
			if swapped_tile.blank:
				swapped_tile.reset_blank()
			cur_space.set_tile(tile_held)
			tile_placed_on_rack(nearest_rack_position, swapped_tile)
		elif discard_hovered:
			tile_place_in_discard(tile_held)
		else:
			tile_placed_on_rack(nearest_rack_position, tile_held)
		rack_area.col.disabled = true
		discard_area.col.disabled = true
		tile_held = null

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		mouse = event.position
	if event is InputEventKey && event.pressed:
		if alphabet.find(event.as_text_key_label()) != -1:
			typed_letter = event.as_text_key_label()

func holding_tile(t):
	tile_held = t.location.pickup_tile()
	if tile_held.blank:
		tile_held.reset_blank()
	rack_area.col.disabled = false
	discard_area.col.disabled = false

func rearrange_rack(nearest):
	#BUG tiles swap strangely with empty spaces, can stack on top of one another
	#check for nearest empty tile
	if rack_positions[nearest].tile == null: return
	var empty = 10
	for i in rack_positions.size():
		if rack_positions[i].tile == null:
			if abs(nearest - i) < empty:
				empty = i
	if empty == 10: return
	if nearest > empty:
		for i in (nearest - empty):
			rack_positions[empty + i].set_tile(rack_positions[empty + i + 1].pickup_tile())
	else: 
		for i in (empty-nearest):
			rack_positions[empty - i].set_tile(rack_positions[empty - i - 1].pickup_tile())

func tile_placed_on_board(s, t):
	if t.blank:
		space_for_blank = s
		selected_blank = t
		selected_blank.init_blank()
		return
	s.set_tile(t)
	
func blank_selection():
	var current_letter: String = selected_blank.blank_display
	var next_letter: String = current_letter
	var scroll_down: bool = true
	if Input.is_action_just_pressed("scroll_down"):
		next_letter = alphabet[wrapi(alphabet.find(current_letter) + 1, 0, 26)]
		scroll_down = false
	elif Input.is_action_just_pressed("scroll_up"):
		next_letter = alphabet[wrapi(alphabet.find(current_letter) - 1, 0, 26)]
	if typed_letter != "":
		next_letter = typed_letter
		typed_letter = ""
	if next_letter == current_letter: return
	await selected_blank.blank_selection(next_letter, scroll_down)
	
	

func tile_placed_on_rack(s, t):
	rearrange_rack(s)
	rack_positions[s].set_tile(t)

func tile_place_in_discard(t):
	for i in discard_positions:
		if i.tile == null:
			i.set_tile(t)
			break
	
#creates array for tiles on board and tiles on rack, and connects space entered signals
func initialize_spaces():
	for i in board_size:
		board_positions.append([])
		for j in board_size:
			board_positions[i].append(null)
	for i in discard_area.mesh.get_children():
		discard_positions.append(i)
	for i in rack_area.mesh.get_children():
		rack_positions.append(i)
	for c in spaces.get_children():
		var row: int = int(c.name.left(1))
		var column: int = int(c.name.right(1))
		board_positions[column-1][row-1] = c
		c.offset = Vector3(0,.18,0)
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
		new_tile.update_tile(i, %Player)
		new_tile.mouse_entered.connect(on_mouse_entered_tile.bind(new_tile))
		new_tile.mouse_exited.connect(on_mouse_exited_tile.bind(new_tile))
	tiles_in_bag.shuffle()

func deal_tiles():
	#calc how many tiles to deal
	var tiles_to_deal: int = 0
	for i in rack_positions:
		if i.tile == null: tiles_to_deal += 1
	if tile_held: tiles_to_deal -= 1
	for i in board_size:
		for j in board_size:
			if board_positions[i][j].tile != null:
				if board_positions[i][j].tile.locked == false: tiles_to_deal -= 1
	#deal that many tiles
	for i in tiles_to_deal:
		var next_null
		for j in rack_positions:
			if j.tile == null:
				next_null = j
				break
		next_null.set_tile(tiles_in_bag.pop_back(), .2)
		await wait(.2)
		

#input for each individual board space
func on_mouse_entered_space(space):
	var light_height_offset: Vector3 = Vector3(0, .3, 0)
	space_hovered = space
	highlight.visible = true
	highlight.global_position = space.global_position + light_height_offset
func on_mouse_exited_space(_space):
	space_hovered = null
	highlight.visible = false

#input for each individual tile
func on_mouse_entered_tile(t) -> void:
	tile_hovered = t
func on_mouse_exited_tile(_t) -> void:
	tile_hovered = null

#input for the tile rack zone
func on_mouse_entered_rack() -> void:
	rack_hovered = true
func on_mouse_exited_rack() -> void:
	rack_hovered = false

#input for the tile discarding zone
func on_mouse_entered_discard() -> void:
	discard_hovered = true
func on_mouse_exited_discard() -> void:
	discard_hovered = false
	
	
func wait(seconds: float):
	await get_tree().create_timer(seconds).timeout

#input for discard button
func discard_button_entered() -> void:
	discard_button_hovered = true
func discard_button_exited() -> void:
	discard_button_hovered = false

func play_button_entered() -> void:
	play_button_hovered = true
func play_button_exited() -> void:
	play_button_hovered = false
