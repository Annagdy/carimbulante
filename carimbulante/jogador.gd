extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D

@export var velocidade = 200
var direcao_anterior=Vector2.DOWN

func get_input():
	var input_direcao = Vector2(
		Input.get_axis("esquerda", "direita"),
		Input.get_axis("cima", "baixo")
	)
	return input_direcao

func _physics_process(_delta):
	var direcao_input=get_input()
	velocity=direcao_input * velocidade
	move_and_slide()
	if (direcao_input!= Vector2.ZERO):
		if (abs(direcao_input.x)> abs(direcao_input.y)):
			if (direcao_input.x>0):
				animated_sprite.play("andar direita")
				direcao_anterior=Vector2.RIGHT
			else:
				animated_sprite.play("andar_esquerda")
				direcao_anterior=Vector2.LEFT
		else:
			if (direcao_input.y>0):
				animated_sprite.play("andar_frente")
				direcao_anterior=Vector2.UP
			else:
				animated_sprite.play("andar_trás")
				direcao_anterior=Vector2.DOWN
	else:
		if (direcao_anterior==Vector2.DOWN):
			animated_sprite.play("parado_trás")
		elif (direcao_anterior==Vector2.UP):
			animated_sprite.play("parado_frente")
		elif (direcao_anterior==Vector2.LEFT):
			animated_sprite.play("parado_esquerda")
		else:
			animated_sprite.play("parado_direita") 
