extends CharacterBody2D

@onready var gun: Gun = $%Gun

const SPEED: float = 400.0

const FOLLOW_LERP_SPEED: float = 8.0

var owner_id: int

var is_authority: bool:
	get:
		return !NetworkHandler.is_server && owner_id == ClientNetworkGlobals.id


func _enter_tree() -> void:
	ServerNetworkGlobals.on_player_position.connect(on_server_player_position_updated)
	ClientNetworkGlobals.on_player_position_updated.connect(on_client_player_position_updated)


func _exit_tree() -> void:
	ServerNetworkGlobals.on_player_position.disconnect(on_server_player_position_updated)
	ClientNetworkGlobals.on_player_position_updated.disconnect(on_client_player_position_updated)


func _process(_delta: float) -> void:
	if !is_authority:
		return

	var gun_angle: float = (get_global_mouse_position() - global_position).angle()

	gun.rotation = gun_angle

	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * SPEED

	move_and_slide()

	PlayerPosition.create(owner_id, global_position, gun_angle).send(NetworkHandler.server_peer)


func on_server_player_position_updated(peer_id: int, player_position: PlayerPosition) -> void:
	if peer_id != owner_id:
		return

	global_position = player_position.position
	gun.pointAt(global_position + Vector2.RIGHT.rotated(player_position.gun_angle))

	PlayerPosition.create(owner_id, global_position, player_position.gun_angle).broadcast(NetworkHandler.connection)


func on_client_player_position_updated(player_position: PlayerPosition) -> void:
	if is_authority || owner_id != player_position.id:
		return

	# global_position = player_position.position
	global_position = global_position.lerp(player_position.position, FOLLOW_LERP_SPEED * get_process_delta_time())
	gun.pointAt(global_position + Vector2.RIGHT.rotated(player_position.gun_angle))
