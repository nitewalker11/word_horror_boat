extends Area3D

@onready var letter_dict: Dictionary = {
	" " : "uid://b0v5mcx7kyvio",
	"A" : "uid://d1eygbccvgg0o",
	"B" : "uid://cjmrphxxvb5ej",
	"C" : "uid://ci60jyaigns4a",
	"D" : "uid://bw3nwy1jiinkl",
	"E" : "uid://by3hiv8c33rdw",
	"F" : "uid://byyb2pvr67aaa",
	"G" : "uid://c110jshcxtfq3",
	"H" : "uid://bj3j3n8tlsau4",
	"I" : "uid://c3maomimvf632",
	"J" : "uid://bfh8kqqvl1hpo",
	"K" : "uid://b30oae43prfhr",
	"L" : "uid://b31d42aylg7vc",
	"M" : "uid://dogcu78hggydp",
	"N" : "uid://cgm1vfa6fa5dr",
	"O" : "uid://n4ioebwb01lf",
	"P" : "uid://bj3k8a4ai56ux",
	"Q" : "uid://by612p03xmtks",
	"R" : "uid://bm4fyhgtip5j0",
	"S" : "uid://dp3mxjrhm4wc5",
	"T" : "uid://chdi3wtygxaj7",
	"U" : "uid://b2jwwjoi3yqo8",
	"V" : "uid://cxmvcwd54l83",
	"W" : "uid://cx8gbeqp6bjs3",
	"X" : "uid://bef4xmwhblycr",
	"Y" : "uid://bf68mqcic1jhh",
	"Z" : "uid://cec2d5cvjy1gs"
}

@export var decal: Decal
@export var arr: Array
@export var col: CollisionShape3D
var player: Node
var mouse_on: bool = false
var selected: bool = false
var selected_offset: Vector3 = Vector3(0,.25,0)
var tile_reference: int
signal tile_clicked

func update_tile():
	var tile = player.owned_tiles[tile_reference]
	decal.texture_albedo = load(letter_dict[tile.letter])
