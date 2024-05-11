extends Node2D
@onready var ms = $MultiplayerSpawner
var lobby_id = 0 
var peer = SteamMultiplayerPeer.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	ms.spawn_function = spawn_level
	peer.lobby_created.connect(_on_lobby_created)
	Steam.lobby_match_list.connect(on_lobby_match_list)
	open_lobby_list()

func spawn_level(data):
	var a = (load(data) as PackedScene).instantiate()
	return a

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func join_lobby(id):
	peer.connect_lobby(id)
	multiplayer.multiplayer_peer = peer
	lobby_id = id
	$Host.hide()
	$LobbyContainer.hide()

func _on_button_pressed():
	peer.create_lobby(SteamMultiplayerPeer.LOBBY_TYPE_PUBLIC)
	multiplayer.multiplayer_peer = peer
	ms.spawn("res://dev/droqen/control_test.tscn")
	$Host.hide()
	$LobbyContainer.hide()
	
func _on_lobby_created(connect, id):
	if connect:
		lobby_id = id
		Steam.setLobbyData(lobby_id,"name",str(Steam.getPersonaName()+"'s Lobby"))
		Steam.setLobbyJoinable(lobby_id,true)
		print(lobby_id)
		
func open_lobby_list():
	Steam.addRequestLobbyListDistanceFilter(Steam.LOBBY_DISTANCE_FILTER_WORLDWIDE)
	Steam.requestLobbyList()
	
func on_lobby_match_list(lobbies):
	for lobby in lobbies:
		var lobby_name = Steam.getLobbyData(lobby,"name")
		var mem_count = Steam.getNumLobbyMembers(lobby)
		var but = Button.new()
		but.set_text(str(lobby_name, " : ", mem_count, "/4"))
		but.set_size(Vector2(20,100))
		but.connect("pressed", Callable(self,"join_lobby").bind(lobby))
		$LobbyContainer/Lobbies.add_child(but)


func _on_refresh_pressed():
	if $LobbyContainer/Lobbies.get_child_count() > 0:
		for i in $LobbyContainer/Lobbies.get_children():
			i.queue_free()
	open_lobby_list()
