class_name IDAssignment extends Packet

var id: int
var remote_ids: Array[int]

static func create(player_id: int, player_remote_ids: Array[int]) -> IDAssignment:
	var packet: IDAssignment = IDAssignment.new()
	packet.packet_type = PACKET_TYPE.ID_ASSIGNMENT
	packet.flag = ENetPacketPeer.FLAG_RELIABLE
	packet.id = player_id
	packet.remote_ids = player_remote_ids
	return packet

static func create_from_data(data: PackedByteArray) -> IDAssignment:
	var packet: IDAssignment = IDAssignment.new()
	packet.decode(data)
	return packet

func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(2 + remote_ids.size())
	data.encode_u8(1, id)
	for i in remote_ids.size():
		data.encode_u8(2 + i, remote_ids[i])
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	remote_ids = []
	for i in range(2, data.size()):
		remote_ids.append(data.decode_u8(i))
