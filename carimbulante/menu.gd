extends Node2D

@onready var iniciar = $BotaoInicio
@onready var sair = $BotaoSair
@onready var inicioanimacao = $BotaoInicio/BotaoInicioAnimacao
@onready var sairanimacao = $BotaoSair/BotaoSairAnimacao

var anim_block = false
var cursor_texture = load("res://sprites/hand_normal.png")
var hotspot = Vector2(16, 16)

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
	cursor_texture = load("res://sprites/hand_click.png")
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)
	if not anim_block:
		inicioanimacao.play("passando")

func _on_iniciar_mouse_exited():
	cursor_texture = load("res://sprites/hand_normal.png")
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)
	if not (iniciar.is_pressed() or anim_block):
		inicioanimacao.play("normal")

func _on_iniciar_button_down():
	inicioanimacao.play("clicar")

func _on_iniciar_button_up():
	if anim_block:
		return
	if iniciar.is_hovered():
		inicioanimacao.play("passando")
	else:
		inicioanimacao.play("normal")

func _on_iniciar_pressed():
	# Muda para a cena do mercado (ajuste o caminho se necessário)
	#get_tree().change_scene_to_file("res://mercado.tscn")
	if anim_block:
		return
	anim_block = true
	inicioanimacao.play("clicar")
	await inicioanimacao.animation_finished
	_on_botao_inicio_animacao_animation_finished("clicar")
	
func _on_botao_inicio_animacao_animation_finished(anim_name):
	if anim_name == "clicar":
		anim_block = false
		get_tree().change_scene_to_file.call_deferred("res://mercado.tscn")

func _on_sair_mouse_entered():
	cursor_texture = load("res://sprites/hand_click.png")
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)
	if not anim_block:
		sairanimacao.play("passando")

func _on_sair_mouse_exited():
	cursor_texture = load("res://sprites/hand_normal.png")
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)
	if not (sair.is_pressed() or anim_block):
		sairanimacao.play("normal")

func _on_sair_button_down():
	sairanimacao.play("clicar")

func _on_sair_button_up():
	if anim_block:
		return
	if sair.is_hovered():
		sairanimacao.play("passando")
	else:
		sairanimacao.play("normal")

func _on_sair_pressed():
	# Fecha o jogo
	#get_tree().quit()
	if anim_block:
		return
	anim_block = true
	sairanimacao.play("clicar")
	await sairanimacao.animation_finished
	_on_botao_sair_animacao_animation_finished("clicar")

func _on_botao_sair_animacao_animation_finished(anim_name):
	if anim_name == "clicar":
		anim_block = false
		get_tree().quit()

func set_hand_cursor():
	Input.set_custom_mouse_cursor(cursor_texture, Input.CURSOR_ARROW, hotspot)
