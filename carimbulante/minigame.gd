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
	
	caminho_alvo.clear()
	for i in range(11):
		var x = i * largura / 10.0
		var y = altura / 2 + sin(i * 0.5) * 50
		caminho_alvo.append(Vector2(x, y))

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
	
	instrucao_label.text = "Pontuação: " + str(pontuacao)
	
	await get_tree().create_timer(0.7).timeout
	emit_signal("minigame_terminado", pontuacao)
