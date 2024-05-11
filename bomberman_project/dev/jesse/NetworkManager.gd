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
	ms.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)

func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#if lobby_id > 0:
		#read_all_p2p_packets()

func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	host = false
	
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
		elif readable_data.has("input"):
			var input_data = readable_data["input"]
		

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

var scene  = preload("res://dev/droqen/control_test.tscn")
func HostGame():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC, lobby_members_max)
	multiplayer.multiplayer_peer = peer
	ms.spawn("res://dev/droqen/control_test.tscn")
	#curLevel = instantiate("res://dev/droqen/control_test.tscn")
	host = true
	
func _on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id,"name",str(Steam.getPersonaName()+"'s Lobby"))
		Steam.setLobbyJoinable(lobby_id,true)
		
		print(peer.get_lobby_data(str(id)))
		print(lobby_id)
		
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
		

