extends SubViewport

func _process(_delta):
	size.x = get_tree().root.size.x * 1.1
	size.y = get_tree().root.size.y
