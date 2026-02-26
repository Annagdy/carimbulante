extends Node2D

@onready var parede_scene = preload("res://parede.tscn")
@onready var prateleira_vazia_scene = preload("res://prateleira_vazia.tscn")
@onready var prateleira_media_direita_scene = preload("res://prateleira_media_direita.tscn")
@onready var prateleira_media_esquerda_scene = preload("res://prateleira_media_esquerda.tscn")
@onready var freezer_grande_scene = preload("res://freezer_grande.tscn")
@onready var freezer_pequeno_scene = preload("res://freezer_pequeno.tscn")
@onready var geladeira_grande_scene = preload("res://geladeira_grande.tscn")
@onready var geladeira_pequena_scene = preload("res://geladeira_pequena.tscn")

# Tamanho do grid aumentado para garantir sobreposição e sem brechas
var grid_size = 128
# Espessura da parede para preencher os cantos
var wall_thickness = 20

const NORTE = 0
const SUL   = 1
const LESTE = 2
const OESTE = 3
const OPOSTO = [SUL, NORTE, OESTE, LESTE]
const DIR_VEC = [Vector2i(0,-1), Vector2i(0,1), Vector2i(1,0), Vector2i(-1,0)]

# Dimensões do labirinto (celulares)
var maze_w = 15
var maze_h = 12

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

	# Criar as paredes externas (bordas)
	# Parede Norte e Sul
	for x in range(maze_w):
		_criar_parede_segmento(Vector2(x * grid_size + grid_size/2, 0), 0.0) # Norte
		_criar_parede_segmento(Vector2(x * grid_size + grid_size/2, maze_h * grid_size), 0.0) # Sul
	
	# Parede Leste e Oeste
	for y in range(maze_h):
		_criar_parede_segmento(Vector2(0, y * grid_size + grid_size/2), PI/2.0) # Oeste
		_criar_parede_segmento(Vector2(maze_w * grid_size, y * grid_size + grid_size/2), PI/2.0) # Leste

	# Preencher paredes internas
	for x in range(maze_w):
		for y in range(maze_h):
			# Parede Leste de cada célula (exceto a última coluna que já tem a borda)
			if x < maze_w - 1 and paredes[x][y][LESTE]:
				_criar_parede_segmento(Vector2((x + 1) * grid_size, y * grid_size + grid_size/2), PI/2.0)
			
			# Parede Sul de cada célula (exceto a última linha que já tem a borda)
			if y < maze_h - 1 and paredes[x][y][SUL]:
				_criar_parede_segmento(Vector2(x * grid_size + grid_size/2, (y + 1) * grid_size), 0.0)

	# Preencher todos os "nós" (junções) para garantir que não haja brechas nos cantos
	for x in range(maze_w + 1):
		for y in range(maze_h + 1):
			_criar_parede_no(Vector2(x * grid_size, y * grid_size))

	# Posicionar jogador
	var spawn_x = 0
	var spawn_y = maze_h - 1
	if has_node("jogador"):
		$jogador.global_position = Vector2(
			spawn_x * grid_size + grid_size / 2,
			spawn_y * grid_size + grid_size / 2
		)

	# Instanciar prateleiras
	for x in range(maze_w):
		for y in range(maze_h):
			if x == spawn_x and y == spawn_y:
				continue
			if randf() < 0.3:
				var world_pos = Vector2(x * grid_size + grid_size / 2, y * grid_size + grid_size / 2)
				_instanciar_prateleira(world_pos)

func _dfs_labirinto(x: int, y: int):
	visitado[x][y] = true
	var dirs = [NORTE, SUL, LESTE, OESTE]
	dirs.shuffle()

	for d in dirs:
		var nx = x + DIR_VEC[d].x
		var ny = y + DIR_VEC[d].y
		if nx >= 0 and nx < maze_w and ny >= 0 and ny < maze_h and not visitado[nx][ny]:
			paredes[x][y][d] = false
			paredes[nx][ny][OPOSTO[d]] = false
			_dfs_labirinto(nx, ny)

func _criar_parede_segmento(pos: Vector2, rot: float):
	var p = parede_scene.instantiate()
	add_child(p)
	p.global_position = pos
	p.rotation = rot
	# Ajustar escala para cobrir exatamente o grid_size + uma pequena margem para evitar gaps
	# O tamanho original é 686. Queremos que ele tenha grid_size + wall_thickness
	p.scale.x = float(grid_size + 2) / 686.0
	# Centralizar a colisão (o original tem position 333,0)
	# Vamos resetar a posição do CollisionShape2D para 0 para facilitar o posicionamento
	if p.has_node("CollisionShape2D"):
		p.get_node("CollisionShape2D").position = Vector2.ZERO

func _criar_parede_no(pos: Vector2):
	# Cria um pequeno bloco no encontro das paredes para fechar qualquer brecha
	var p = parede_scene.instantiate()
	add_child(p)
	p.global_position = pos
	# Escala mínima apenas para cobrir o buraco do canto
	p.scale.x = 40.0 / 686.0 
	if p.has_node("CollisionShape2D"):
		p.get_node("CollisionShape2D").position = Vector2.ZERO

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
