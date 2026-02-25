extends Node2D

@onready var area_interacao= $Areainteracao
@onready var prompt_interacao = $SpritePrompt

var jogador_proximo=false
var jogador = null
var interagiu= false

var minigame_atual = null

func _ready():
	print("=== FILHOS DO NÓ ===")
	for child in get_children():
		print(child.name, " | tipo: ", child.get_class())
	print("Tentando achar Areainteracao: ", get_node_or_null("Areainteracao"))
	if area_interacao:
		print("areainteracao nao e o problema")
	area_interacao.body_entered.connect(_on_areainteracao_body_entered)
	area_interacao.body_exited.connect(_on_areainteracao_body_exited)

func _on_areainteracao_body_entered(body):
	if (body.is_in_group("jogador")):
		jogador_proximo=true
		jogador = body

func _on_areainteracao_body_exited(body):
	if (body.is_in_group("jogador")):
		jogador_proximo=false
		jogador = null
		

func _process(_delta: float) -> void:
	if prompt_interacao:
		prompt_interacao.visible=jogador_proximo and not interagiu
		if jogador_proximo and jogador and not interagiu:
			prompt_interacao.play("default")
			prompt_interacao.global_position = jogador.global_position + Vector2(0, -50)
	
func _input(event):
	if event.is_action_pressed("acao") and jogador_proximo and not interagiu:
		interagir()

func interagir():
	interagiu = true
	var minigame_scene = preload("res://minigame.tscn")
	minigame_atual = minigame_scene.instantiate()
	minigame_atual.connect("minigame_terminado", _on_minigame_terminado)
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "MinigameLayer"
	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().current_scene.add_child(canvas_layer)
	canvas_layer.add_child(minigame_atual)
	
	get_tree().paused = true

func _on_minigame_terminado(_pontos):
	if minigame_atual:
		var parent = minigame_atual.get_parent()
		if parent is CanvasLayer:
			parent.queue_free()
		else:
			minigame_atual.queue_free()
		minigame_atual = null
	get_tree().paused = false
