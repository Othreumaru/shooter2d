extends Node

# Server Signals
signal on_peer_connected(peer_id: int)
signal on_peer_disconnected(peer_id: int)
signal on_server_packet(peer_id: int, data: PackedByteArray)

# Client Signals
signal on_connected_to_server()
signal on_disconnected_from_server()
signal on_client_packet(data: PackedByteArray)

# Server variables
var available_peer_ids: Array = range(255, -1, -1)  # Pool of available peer IDs (1-255)
var client_peers: Dictionary[int, ENetPacketPeer] = {}  # Mapping of peer_id to ENetPacketPeer

# Client variables
var server_peer: ENetPacketPeer = null

# General variables
var connection: ENetConnection = null
var is_server: bool = false

func _process(_delta: float) -> void:
	if connection == null:
		return
	handle_events()


func handle_events() -> void:
	var packet_event: Array = connection.service()
	var event_type: int = packet_event[0]

	while event_type != ENetConnection.EVENT_NONE:
		var peer : ENetPacketPeer = packet_event[1]
		match event_type:
			ENetConnection.EVENT_ERROR:
				push_warning("Network error occurred.")
				return
			ENetConnection.EVENT_CONNECT:
				if is_server:
					peer_connected(peer)
				else:
					connected_to_server()
				return
			ENetConnection.EVENT_DISCONNECT:
				if is_server:
					peer_disconnected(peer)
				else:
					disconnected_from_server()
					return
			ENetConnection.EVENT_RECEIVE:
				if is_server:
					var peer_id: int = peer.get_meta("id")
					var data: PackedByteArray = peer.get_packet()
					on_server_packet.emit(peer_id, data)
				else:
					var data: PackedByteArray = peer.get_packet()
					on_client_packet.emit(data)
		packet_event = connection.service()
		event_type = packet_event[0]


func peer_connected(peer: ENetPacketPeer) -> void:
	var peer_id: int = available_peer_ids.pop_back()
	peer.set_meta("id", peer_id)
	client_peers[peer_id] = peer
	print("Peer connected with ID: ", peer_id)
	on_peer_connected.emit(peer_id)


func connected_to_server() -> void:
	print("Connected to server.")
	on_connected_to_server.emit()


func peer_disconnected(peer: ENetPacketPeer) -> void:
	var peer_id: int = peer.get_meta("id")
	available_peer_ids.push_back(peer_id)
	client_peers.erase(peer_id)
	print ("Peer disconnected with ID: ", peer_id)
	on_peer_disconnected.emit(peer_id)


func disconnected_from_server() -> void:
	print("Disconnected from server.")
	on_disconnected_from_server.emit()
	connection = null

func start_server(ip_address: String = "127.0.0.1", port: int = 42069) -> void:
	connection = ENetConnection.new()
	var error: Error = connection.create_host_bound(ip_address, port)
	if error:
		print("Server starting failed with error: ", error_string(error))
		connection = null
		return
	print("Server started on ", ip_address, ":", port)
	is_server = true


func start_client(ip_address: String = "127.0.0.1", server_port: int = 42069) -> void:
	connection = ENetConnection.new()
	var error: Error = connection.create_host(1)
	if error:
		print("Client startin`g failed with error: ", error_string(error))
		connection = null
		return
	print("Client started, connecting to server at ", ip_address, ":", server_port)
	server_peer = connection.connect_to_host(ip_address, server_port)
	
func disconnect_client() -> void:
	if is_server:
		push_warning("This function is only for clients.")
		return
	if server_peer != null:
		server_peer.peer_disconnect()
		server_peer = null
