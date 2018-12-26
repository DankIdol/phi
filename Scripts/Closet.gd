extends Node2D

var active = false
var finished = false

func _process(delta):
	if $AnimatedSprite.animation == 'open' and finished:
		$AnimatedSprite.play('closed')

func _ready():
	get_parent().get_child(0).connect('_hide', self, '_hide')

func _hide():
	if active:
		if $Occupied_sign.visible:
			$Occupied_sign.hide()
		else:
			$Occupied_sign.show()
		finished = false
		$Timer.start()
		$AnimatedSprite.play('open')

func _on_Area2D_body_entered(body):
	if body.get_name().match('Player'):
		active = true

func _on_Area2D_body_exited(body):
	if body.get_name().match('Player'):
		active = false

func _on_Timer_timeout():
	finished = true
