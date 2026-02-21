extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

@export var velocidade_maxima = 600
@export var aceleracao = 400
@export var desaceleracao = 2500
var direcao_anterior=Vector2.DOWN

func get_input():
	var input_direcao = Vector2(
		Input.get_axis("esquerda", "direita"),
		Input.get_axis("cima", "baixo")
	)
	return input_direcao

func _physics_process(delta):
	var direcao_input=get_input()
	var velocidade_desejada = direcao_input * velocidade_maxima
	if direcao_input != Vector2.ZERO:
		velocity = velocity.move_toward(velocidade_desejada, aceleracao * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, desaceleracao * delta)
	move_and_slide()
	if (direcao_input!= Vector2.ZERO):
		if (abs(velocity.x)> abs(velocity.y)):
			if (velocity.x>0):
				animated_sprite.play("andar direita")
				direcao_anterior=Vector2.RIGHT
			else:
				animated_sprite.play("andar_esquerda")
				direcao_anterior=Vector2.LEFT
		else:
			if (velocity.y>0):
				animated_sprite.play("andar_frente")
				direcao_anterior=Vector2.UP
			else:
				animated_sprite.play("andar_trás")
				direcao_anterior=Vector2.DOWN
	else:
		match direcao_anterior:
			Vector2.DOWN:
				animated_sprite.play("parado_trás")
			Vector2.UP:
				animated_sprite.play("parado_frente")
			Vector2.LEFT:
				animated_sprite.play("parado_esquerda")
			_:
				animated_sprite.play("parado_direita")
