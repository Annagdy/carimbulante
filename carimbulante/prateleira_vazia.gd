extends Node2D

@onready var area_interacao=$areainteracao
@onready var prompt_interacao = $SpritePrompt

var jogador_proximo=false
var jogador = null
var interagiu= false

func _ready():
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
	print("interagiu com a prateleira")
