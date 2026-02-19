extends CanvasLayer

const TEMPO_TOTAL := 90.0 

var tempo_restante: float = TEMPO_TOTAL
var jogo_ativo: bool = true

@onready var label_timer: Label = $PainelHUD/LabelTimer
@onready var label_pontuacao: Label = $PainelHUD/LabelPontuacao
@onready var painel_resultado: Panel = $PainelResultado
@onready var label_resultado: Label = $PainelResultado/LabelResultado
@onready var botao_finalizar: Button = $PainelHUD/BotaoFinalizar
@onready var timer_animacao: AnimatedSprite2D= $PainelHUD/LabelTimer/TimerAnimation

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	painel_resultado.hide()
	botao_finalizar.pressed.connect(_on_botao_finalizar_pressed)
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").resetar()
		get_node("/root/GameManager").jogo_ativo = true
	_atualizar_ui()
	timer_animacao.play("default")

func _process(delta: float) -> void:
	if not jogo_ativo:
		return
	
	tempo_restante -= delta
	tempo_restante = max(tempo_restante, 0.0)
	_atualizar_ui()
	
	if tempo_restante <= 0.0:
		_fim_de_jogo()
	
	if Input.is_action_just_pressed("finalizar"):
		_on_botao_finalizar_pressed()

func _atualizar_ui() -> void:
	var minutos := int(tempo_restante) / 60
	var segundos := int(tempo_restante) % 60
	label_timer.text = "%d:%02d" % [minutos, segundos]
	
	var pontos = 0
	if has_node("/root/GameManager"):
		pontos = get_node("/root/GameManager").pontuacao_total
	
	label_pontuacao.text = "Pontos: %d" % pontos
	
	if tempo_restante <= 10.0:
		label_timer.add_theme_color_override("font_color", Color.RED)
	else:
		label_timer.remove_theme_color_override("font_color")

func adicionar_pontos(pontos: int) -> void:
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").adicionar_pontos(pontos)
	_atualizar_ui()

func _on_botao_finalizar_pressed() -> void:
	if not jogo_ativo: return
	_fim_de_jogo()

func _fim_de_jogo() -> void:
	jogo_ativo = false
	if has_node("/root/GameManager"):
		get_node("/root/GameManager").jogo_ativo = false
		var pontuacao_final = get_node("/root/GameManager").pontuacao_total
		if pontuacao_final >= 1200:
			_mostrar_vitoria(pontuacao_final)
		else:
			_mostrar_derrota(pontuacao_final)
	else:
		_mostrar_derrota(0)

func _mostrar_vitoria(pontos: int) -> void:
	painel_resultado.show()
	label_resultado.text = "🎉 VOCÊ GANHOU! 🎉\nPontuação: %d" % pontos

func _mostrar_derrota(pontos: int) -> void:
	painel_resultado.show()
	label_resultado.text = "Fim de jogo!\nPontuação: %d\nPrecisava de 1200 pontos." % pontos
