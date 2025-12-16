extends Node2D

const PLAYER_SCENE: PackedScene = preload("res://scenes/network_player.tscn")

func _ready() -> void:
	NetworkHandler.on_peer_connected.connect(spawn_player)
	ClientNetworkGlobals.on_id_assigned.connect(spawn_player)
	ClientNetworkGlobals.on_remote_id_assigned.connect(spawn_player)


func spawn_player(id: int) -> void:
	var player = PLAYER_SCENE.instantiate()
	player.owner_id = id
	player.name = str(id)
	call_deferred("add_child", player)
