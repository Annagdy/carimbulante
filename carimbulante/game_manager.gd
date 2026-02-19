extends Node
# ============================================================
# GAME MANAGER — Autoload (Singleton)
# Registre em: Projeto > Configurações > Autoload
# Caminho: res://game_manager.gd  |  Nome: GameManager
# ============================================================

var pontuacao_total: int = 0
var jogo_ativo: bool = false

func adicionar_pontos(p: int) -> void:
	pontuacao_total += p

func resetar() -> void:
	pontuacao_total = 0
	jogo_ativo = false

func iniciar_jogo() -> void:
	resetar()
	jogo_ativo = true
