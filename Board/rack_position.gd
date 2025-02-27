extends Marker3D

var tile: Area3D
var tween

func set_tile(t, speed):
	tile = t
	if t == null: return
	tween = get_tree().create_tween()
	tween.tween_property(tile, "global_position", global_position, speed)
