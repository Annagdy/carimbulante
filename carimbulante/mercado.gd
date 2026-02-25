extends Node2D

@onready var parede_scene = preload("res://parede.tscn")
@onready var prateleira_vazia_scene = preload("res://prateleira_vazia.tscn")
@onready var prateleira_media_direita_scene = preload("res://prateleira_media_direita.tscn")
@onready var prateleira_media_esquerda_scene = preload("res://prateleira_media_esquerda.tscn")
@onready var freezer_grande_scene = preload("res://freezer_grande.tscn")
@onready var freezer_pequeno_scene = preload("res://freezer_pequeno.tscn")
@onready var geladeira_grande_scene = preload("res://geladeira_grande.tscn")
@onready var geladeira_pequena_scene = preload("res://geladeira_pequena.tscn")

var grid_size = 128
var map_width = 16
var map_height = 12

const NORTE = 0
const SUL   = 1
const LESTE = 2
const OESTE = 3
const OPOSTO = [SUL, NORTE, OESTE, LESTE]
const DIR_VEC = [Vector2i(0,-1), Vector2i(0,1), Vector2i(1,0), Vector2i(-1,0)]

var maze_w = 7
var maze_h = 5

var paredes = []   
var visitado = []

func _ready():
	if has_node("/root/MusicaGlobal"):
		MusicaGlobal.play_music()
	randomize()
	limpar_mapa_existente()
	await get_tree().process_frame
	gerar_mapa_procedural()

func limpar_mapa_existente():
	for child in get_children():
		if child.name != "jogador" and child.name != "MercadoHUD" and child.name != "TileMap" and child.name != "Camera2D":
			child.queue_free()

func gerar_mapa_procedural():
	paredes = []
	visitado = []
	for x in range(maze_w):
		paredes.append([])
		visitado.append([])
		for y in range(maze_h):
			paredes[x].append([true, true, true, true])
			visitado[x].append(false)

	_dfs_labirinto(0, 0)

	var gw = maze_w * 2 + 1
	var gh = maze_h * 2 + 1

	var grid = []
	for x in range(gw):
		grid.append([])
		for _y in range(gh):
			grid[x].append(0)

	for x in range(gw):
		grid[x][0] = 1
		grid[x][gh - 1] = 1
	for y in range(gh):
		grid[0][y] = 2
		grid[gw - 1][y] = 2

	for cx in range(maze_w):
		for cy in range(maze_h):
			var gx = 1 + cx * 2
			var gy = 1 + cy * 2

			if cy < maze_h - 1 and paredes[cx][cy][SUL]:
				grid[gx][gy + 1] = 1

			if cx < maze_w - 1 and paredes[cx][cy][LESTE]:
				grid[gx + 1][gy] = 2

			if cx < maze_w - 1 and cy < maze_h - 1:
				grid[gx + 1][gy + 1] = 1

	var spawn_gx = 1
	var spawn_gy = 1 + (maze_h - 1) * 2
	if has_node("jogador"):
		$jogador.global_position = Vector2(
			spawn_gx * grid_size + grid_size / 2,
			spawn_gy * grid_size + grid_size / 2
		)

	for x in range(gw):
		for y in range(gh):
			var world_pos = Vector2(x * grid_size + grid_size / 2, y * grid_size + grid_size / 2)
			match grid[x][y]:
				1:
					_criar_parede(world_pos, 0.0)
				2:
					_criar_parede(world_pos, PI / 2.0)

	for cx in range(maze_w):
		for cy in range(maze_h):
			var gx = 1 + cx * 2
			var gy = 1 + cy * 2
			if gx == spawn_gx and gy == spawn_gy:
				continue
			if randf() < 0.4:
				var world_pos = Vector2(gx * grid_size + grid_size / 2, gy * grid_size + grid_size / 2)
				_instanciar_prateleira(world_pos)

func _dfs_labirinto(x: int, y: int):
	visitado[x][y] = true
	var dirs = [NORTE, SUL, LESTE, OESTE]
	for i in range(dirs.size() - 1, 0, -1):
		var j = randi() % (i + 1)
		var tmp = dirs[i]
		dirs[i] = dirs[j]
		dirs[j] = tmp

	for d in dirs:
		var nx = x + DIR_VEC[d].x
		var ny = y + DIR_VEC[d].y
		if nx >= 0 and nx < maze_w and ny >= 0 and ny < maze_h and not visitado[nx][ny]:
			paredes[x][y][d] = false
			paredes[nx][ny][OPOSTO[d]] = false
			_dfs_labirinto(nx, ny)

func _criar_parede(pos: Vector2, rot: float):
	var p = parede_scene.instantiate()
	add_child(p)
	p.global_position = pos
	p.rotation = rot
	p.scale.x = float(grid_size) / 686.0

func _instanciar_prateleira(pos: Vector2):
	var opcoes = [
		prateleira_vazia_scene,
		prateleira_media_direita_scene,
		prateleira_media_esquerda_scene,
		freezer_grande_scene,
		freezer_pequeno_scene,
		geladeira_grande_scene,
		geladeira_pequena_scene
	]
	var cena_sorteada = opcoes[randi() % opcoes.size()]
	var instancia = cena_sorteada.instantiate()
	add_child(instancia)
	instancia.global_position = pos
	if randf() < 0.2:
		instancia.scale.x *= -1

func _process(_delta: float) -> void:
	pass
