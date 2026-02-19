extends Control

signal minigame_terminado(pontuacao)

var caminho_alvo = []
var trajeto_jogador = []
var desenhando = false

@onready var panel = $Panel
@onready var linha_alvo = $Panel/CaminhoAlvo
@onready var linha_jogador = $Panel/TrajetoJogador
@onready var instrucao_label = $Panel/Label

const PONTUACAO_MAXIMA = 1000
const DISTANCIA_MAXIMA = 50 

func _ready():
	randomize()
	process_mode = Node.PROCESS_MODE_ALWAYS
	z_index = 100
	gerar_caminho_alvo()
	desenhar_caminho_alvo()
	instrucao_label.text = "Clique e arraste para traçar o caminho"

func _input(event):
	if event.is_action("desenhar"):
		if event.pressed:
			desenhando = true
			trajeto_jogador.clear()
			linha_jogador.clear_points()
			adicionar_ponto_mouse()
		else:
			if desenhando:
				desenhando = false
				calcular_e_finalizar()
	
	if event is InputEventMouseMotion and desenhando:
		adicionar_ponto_mouse()

func adicionar_ponto_mouse():
	var pos = panel.get_local_mouse_position()
	if trajeto_jogador.size() == 0 or trajeto_jogador[-1].distance_to(pos) > 5:
		trajeto_jogador.append(pos)
		linha_jogador.add_point(pos)

func gerar_caminho_alvo():
	var largura = panel.size.x
	var altura = panel.size.y
	
	var horizontal = randi() % 2 == 0
	
	var num_pontos = 30
	var caminho = []
	
	if horizontal:
		var num_senoides = randi_range(1, 3)
		var amplitudes = []
		var frequencias = []
		var fases = []
		for i in range(num_senoides):
			amplitudes.append(randf_range(10, 70))
			frequencias.append(randf_range(0.5, 5.0))
			fases.append(randf_range(0, 2*PI))
		var deslocamento_y = randf_range(altura * 0.2, altura * 0.8)
		
		for i in range(num_pontos + 1):
			var x = i * largura / float(num_pontos)
			var t = i / float(num_pontos)
			var y = deslocamento_y
			for j in range(num_senoides):
				y += amplitudes[j] * sin(t * 2 * PI * frequencias[j] + fases[j])
			y = clamp(y, 0, altura)
			caminho.append(Vector2(x, y))
	else:
		var num_senoides = randi_range(1, 3)
		var amplitudes = []
		var frequencias = []
		var fases = []
		for i in range(num_senoides):
			amplitudes.append(randf_range(10, 70))
			frequencias.append(randf_range(0.5, 5.0))
			fases.append(randf_range(0, 2*PI))
		var deslocamento_x = randf_range(largura * 0.2, largura * 0.8)
		
		for i in range(num_pontos + 1):
			var y = i * altura / float(num_pontos)
			var t = i / float(num_pontos)
			var x = deslocamento_x
			for j in range(num_senoides):
				x += amplitudes[j] * sin(t * 2 * PI * frequencias[j] + fases[j])
			x = clamp(x, 0, largura)
			caminho.append(Vector2(x, y))
	
	var step = num_pontos / 10
	caminho_alvo.clear()
	for i in range(0, num_pontos + 1, step):
		caminho_alvo.append(caminho[i])

func desenhar_caminho_alvo():
	linha_alvo.clear_points()
	for ponto in caminho_alvo:
		linha_alvo.add_point(ponto)

func calcular_e_finalizar():
	if trajeto_jogador.size() < 2:
		emit_signal("minigame_terminado", 0)
		return
	
	var soma_distancias = 0.0
	for ponto_j in trajeto_jogador:
		var dist_min = INF
		for ponto_a in caminho_alvo:
			var d = ponto_j.distance_to(ponto_a)
			if d < dist_min:
				dist_min = d
		soma_distancias += dist_min
	
	var dist_media = soma_distancias / trajeto_jogador.size()
	
	var pontuacao = max(0, PONTUACAO_MAXIMA * (1 - dist_media / DISTANCIA_MAXIMA))
	pontuacao = int(pontuacao)
	
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").adicionar_pontos(pontuacao)
	
	var hud = get_tree().get_first_node_in_group("hud")
	if hud and hud.has_method("_atualizar_ui"):
		hud._atualizar_ui()
	
	instrucao_label.text = "Pontuação: " + str(pontuacao)
	
	await get_tree().create_timer(0.7).timeout
	emit_signal("minigame_terminado", pontuacao)
