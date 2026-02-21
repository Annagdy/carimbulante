extends Node2D

@onready var iniciar = $BotaoInicio
@onready var sair = $BotaoSair
@onready var inicioanimacao = $BotaoInicio/BotaoInicioAnimacao
@onready var sairanimacao = $BotaoSair/BotaoSairAnimacao

func _ready():
	set_hand_cursor()
	iniciar.mouse_entered.connect(_on_iniciar_mouse_entered)
	iniciar.mouse_exited.connect(_on_iniciar_mouse_exited)
	iniciar.button_down.connect(_on_iniciar_button_down)
	iniciar.button_up.connect(_on_iniciar_button_up)
	iniciar.pressed.connect(_on_iniciar_pressed)
	
	sair.mouse_entered.connect(_on_sair_mouse_entered)
	sair.mouse_exited.connect(_on_sair_mouse_exited)
	sair.button_down.connect(_on_sair_button_down)
	sair.button_up.connect(_on_sair_button_up)
	sair.pressed.connect(_on_sair_pressed)
	
	# Iniciar com a animação normal
	inicioanimacao.play("normal")
	sairanimacao.play("normal")

func _on_iniciar_mouse_entered():
	inicioanimacao.play("passando")

func _on_iniciar_mouse_exited():
	if not iniciar.is_pressed():
		inicioanimacao.play("normal")

func _on_iniciar_button_down():
	inicioanimacao.play("clicar")

func _on_iniciar_button_up():
	if iniciar.is_hovered():
		inicioanimacao.play("passando")
	else:
		inicioanimacao.play("normal")

func _on_iniciar_pressed():
	# Muda para a cena do mercado (ajuste o caminho se necessário)
	get_tree().change_scene_to_file("res://mercado.tscn")

func _on_sair_mouse_entered():
	sairanimacao.play("passando")

func _on_sair_mouse_exited():
	if not sair.is_pressed():
		sairanimacao.play("normal")

func _on_sair_button_down():
	sairanimacao.play("clicar")

func _on_sair_button_up():
	if sair.is_hovered():
		sairanimacao.play("passando")
	else:
		sairanimacao.play("normal")

func _on_sair_pressed():
	# Fecha o jogo
	get_tree().quit()

func set_hand_cursor():
	var cursor_texture = load("res://sprites/hand.png")
	var hotspot = Vector2(16, 16)
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)
