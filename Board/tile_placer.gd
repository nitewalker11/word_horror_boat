extends Node3D

var tile: Area3D
var offset: Vector3 = Vector3.ZERO
var col: CollisionShape3D
var tween

func _ready() -> void:
	if get_child_count() > 0:
		col = get_child(0)

func set_tile(t, speed):
	tile = t
	if t == null: return
	tween = get_tree().create_tween()
	tween.tween_property(tile, "global_position", global_position + offset, speed)
