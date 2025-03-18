extends Node3D

var tile: Area3D
var offset: Vector3 = Vector3.ZERO
var col: CollisionShape3D
var tween
var row
var column

func _ready() -> void:
	if get_child_count() > 0:
		col = get_child(0)

func pickup_tile():
	if tile == null: return
	var picked_up_tile = tile
	tile.location = null
	tile.col.disabled = true
	tile = null
	if col != null:
		col.disabled = false
	return picked_up_tile

func set_tile(t, speed: float = .1):
	if t == null: return
	tile = t
	tile.location = self
	tile.col.disabled = false
	tween = get_tree().create_tween()
	tween.tween_property(tile, "global_position", global_position + offset, speed)
	if col != null:
		col.disabled = true
