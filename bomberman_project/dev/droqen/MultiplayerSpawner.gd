extends MultiplayerSpawner

@export var playerScene : PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_function = spawnPlayer
	if is_multiplayer_authority():
		spawn(1)
		multiplayer.peer_connected.connect(spawn)
		multiplayer.peer_disconnected.connect(removePlayer)

func spawnPlayer(data):
	var p = playerScene.instantiate()
	p.set_multiplayer_authority(data)
	NetworkManager.players[data] = p
	p.playerSteamId = data
	p.playerNum = NetworkManager.players.size()
	print("player " + str(p.playerNum) + " joined")
	NetworkManager.get_lobby_members()
	return p
	
func removePlayer(data):
	NetworkManager.players[data].queue_free()
	NetworkManager.players.erase(data)
