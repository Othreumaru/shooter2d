extends Control

@onready var host_input: LineEdit = $%HostInput
@onready var start_server_button: Button = $%StartServerButton
@onready var start_client_button: Button = $%StartClientButton

func _ready() -> void:
	start_server_button.pressed.connect(_on_server_button_pressed)
	start_client_button.pressed.connect(_on_client_button_pressed)

func get_server_and_port(host_text: String) -> Array[String]:
	if host_text.find(":") != -1:
		var array: Array[String]
		array.assign(host_text.split(":"))
		return array
	return [host_text, "42069"]

func _on_server_button_pressed() -> void:
	var server_and_port = get_server_and_port(host_input.text)
	NetworkHandler.start_server(server_and_port[0], int(server_and_port[1]))


func _on_client_button_pressed() -> void:
	var server_and_port = get_server_and_port(host_input.text)
	NetworkHandler.start_client(server_and_port[0], int(server_and_port[1]))