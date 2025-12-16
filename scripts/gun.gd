class_name Gun extends Area2D

@onready var marker = $Marker2D

func pointAt(position: Vector2) -> void:
	marker.look_at(position)
