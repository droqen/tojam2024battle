extends Node2D
var lobby_id = 0 
var peer = SteamMultiplayerPeer.new()

@onready var ms = get_node("/root/Main/MultiplayerSpawner")
const PACKET_READ_LIMIT: int = 32

var lobby_data
var lobby_members: Array = []
var lobby_members_max: int = 4
var lobby_vote_kick: bool = false
var steam_id: int = 0
var steam_username: String = ""

var players = {}

var host = false
var curLevel

# Called when the node enters the scene tree for the first time.
func _ready():
	OS.set_environment("SteamAppID", str(480))
	OS.set_environment("SteamGameID", str(480))
	Steam.steamInitEx()
	steam_id = Steam.getSteamID()
	ms.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)
	Steam.p2p_session_request.connect(_on_p2p_session_request)
	multiplayer.connect("peer_connected", Callable(self, "_on_connection_succeeded"))
	Steam.p2p_session_connect_fail.connect(_on_p2p_session_connect_fail)
	check_command_line()
	
func _on_connection_succeeded(id):
	print("Connection to lobby succeeded. Peer ID: %d" % id)
	#make_p2p_handshake()
	# Additional setup after successful connection
func check_command_line() -> void:
	var these_arguments: Array = OS.get_cmdline_args()
	if these_arguments.size() > 0:
		if these_arguments[0] == "+connect_lobby":
			if int(these_arguments[1]) > 0:
				print("Command line lobby ID: %s" % these_arguments[1])
				join_lobby(int(these_arguments[1]))
				
func _on_p2p_session_request(remote_id: int) -> void:
	var this_requester: String = Steam.getFriendPersonaName(remote_id)
	print("%s is requesting a P2P session" % this_requester)
	Steam.acceptP2PSessionWithUser(remote_id)
	#make_p2p_handshake()

func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	Steam.run_callbacks()
	if lobby_id > 0:
		read_all_p2p_packets()
		
func make_p2p_handshake() -> void:
	print("Sending P2P handshake to the lobby")
	send_p2p_packet(0, {"getMap": steam_id})

func join_lobby(id):
	print("Attempting to connect to lobby: %s" % id)
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	host = false
	#make_p2p_handshake()
	
func read_all_p2p_packets(read_count: int = 0):
	if read_count >= PACKET_READ_LIMIT:
		return
	if Steam.getAvailableP2PPacketSize(0) > 0:
		read_p2p_packet()
		read_all_p2p_packets(read_count + 1)

func read_p2p_packet() -> void:
	var packet_size: int = Steam.getAvailableP2PPacketSize(0)

	# There is a packet
	if packet_size > 0:
		var this_packet: Dictionary = Steam.readP2PPacket(packet_size, 0)

		if this_packet.is_empty() or this_packet == null:
			print("WARNING: read an empty packet with non-zero size!")

		# Get the remote user's ID
		var packet_sender: int = this_packet['steam_id_remote']

		# Make the packet data readable
		var packet_code: PackedByteArray = this_packet['data']
		var readable_data: Dictionary = bytes_to_var(packet_code)

		# Print the packet to output
		print("Packet: %s" % readable_data)
		
		if readable_data.has("input"):
			var input_data = readable_data["input"]
			players[input_data[0]].inputs = [input_data[1], input_data[2], input_data[3]]
		elif readable_data.has("getMap"):
			if host:
				var clientId = readable_data["getMap"]
				print("getMap request recieved")
				var packet_data = {'recieveMap': [GameGrid.gridJson]}
				send_p2p_packet(clientId[0], packet_data)
		elif readable_data.has("recieveMap"):
			var map = readable_data["recieveMap"]
			print(map)
			

		# Append logic here to deal with packet data
func send_p2p_packet(this_target: int, packet_data: Dictionary) -> void:
	print("send packet called")
			# Set the send_type and channel
	var send_type: int = Steam.P2P_SEND_RELIABLE
	var channel: int = 0

	# Create a data array to send the data through
	var this_data: PackedByteArray
	this_data.append_array(var_to_bytes(packet_data))

	# If sending a packet to everyone
	if this_target == 0:
		# If there is more than one user, send packets
		if lobby_members.size() > 1:
			# Loop through all members that aren't you
			for this_member in lobby_members:
				if this_member['steam_id'] != steam_id:
					Steam.sendP2PPacket(this_member['steam_id'], this_data, send_type, channel)

	# Else send it to someone specific
	else:
		Steam.sendP2PPacket(this_target, this_data, send_type, channel)
		
func _on_p2p_session_connect_fail(steam_id: int, session_error: int) -> void:
	# If no error was given
	if session_error == 0:
		print("WARNING: Session failure with %s: no error given" % steam_id)

	# Else if target user was not running the same game
	elif session_error == 1:
		print("WARNING: Session failure with %s: target user not running the same game" % steam_id)

	# Else if local user doesn't own app / game
	elif session_error == 2:
		print("WARNING: Session failure with %s: local user doesn't own app / game" % steam_id)

	# Else if target user isn't connected to Steam
	elif session_error == 3:
		print("WARNING: Session failure with %s: target user isn't connected to Steam" % steam_id)

	# Else if connection timed out
	elif session_error == 4:
		print("WARNING: Session failure with %s: connection timed out" % steam_id)

	# Else if unused
	elif session_error == 5:
		print("WARNING: Session failure with %s: unused" % steam_id)

	# Else no known error
	else:
		print("WARNING: Session failure with %s: unknown error %s" % [steam_id, session_error])
		

var scene  = preload("res://dev/droqen/control_test.tscn")
func HostGame():
	host = true
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, lobby_members_max)
	peer.as_relay
	multiplayer.multiplayer_peer = peer
	ms.spawn("res://dev/droqen/control_test.tscn")
	Steam.allowP2PPacketRelay(true)
	#curLevel = instantiate("res://dev/droqen/control_test.tscn")
	
func _on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id,"name",str(Steam.getPersonaName()+"'s Lobby"))
		Steam.setLobbyJoinable(lobby_id,true)
		
func get_lobby_members() -> void:
	# Clear your previous lobby list
	lobby_members.clear()

	# Get the number of members from this lobby from Steam
	var num_of_members: int = Steam.getNumLobbyMembers(lobby_id)
	print("somone joined " + str(num_of_members))
	# Get the data of these players from Steam
	for this_member in range(0, num_of_members):
		# Get the member's Steam ID
		var member_steam_id: int = Steam.getLobbyMemberByIndex(lobby_id, this_member)

		# Get the member's Steam name
		var member_steam_name: String = Steam.getFriendPersonaName(member_steam_id)

		# Add them to the list
		lobby_members.append({"steam_id":member_steam_id, "steam_name":member_steam_name})
	make_p2p_handshake()
		

