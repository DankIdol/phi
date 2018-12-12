extends Node2D

func _ready():
	pass

func player_enter():
	$AnimatedSprite.play('open')