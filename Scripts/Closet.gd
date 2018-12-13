extends Node2D

func _ready():
	get_parent().get_child(0).connect('test', self, '_test')

func _test():
	print('asd')

func player_enter():
	$AnimatedSprite.play('open')

func _on_Area2D_body_entered(body):
	if body.get_name().match('Player'):
		player_enter()
