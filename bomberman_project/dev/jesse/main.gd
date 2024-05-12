extends Node

func _ready():
	Steam.lobby_match_list.connect(on_lobby_match_list)
	open_lobby_list()
	
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
		$UI/LobbyContainer/Lobbies.add_child(but)


func _on_refresh_pressed():
	if $UI/LobbyContainer/Lobbies.get_child_count() > 0:
		for i in $UI/LobbyContainer/Lobbies.get_children():
			i.queue_free()
	open_lobby_list()

func OnHostPressed():
	NetworkManager.HostGame()
	$UI.hide()

func join_lobby(id):
	NetworkManager.join_lobby(id)
	$UI.hide()
