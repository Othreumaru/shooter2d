class_name PlayerPosition extends Packet

var id: int
var position: Vector2
var gun_angle: float

static func create(player_id: int, player_position: Vector2, player_gun_angle: float) -> PlayerPosition:
	var packet: PlayerPosition = PlayerPosition.new()
	packet.packet_type = PACKET_TYPE.PLAYER_POSITION
	packet.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	packet.id = player_id
	packet.position = player_position
	packet.gun_angle = player_gun_angle
	return packet

static func create_from_data(data: PackedByteArray) -> PlayerPosition:
	var packet: PlayerPosition = PlayerPosition.new()
	packet.decode(data)
	return packet

func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(14)
	data.encode_u8(1, id)
	data.encode_float(2, position.x)
	data.encode_float(6, position.y)
	data.encode_float(10, gun_angle)
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	position = Vector2(data.decode_float(2), data.decode_float(6))
	gun_angle = data.decode_float(10)