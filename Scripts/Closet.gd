extends Node2D

var active = false

func _process(delta):
	$Label.text = '^' if active else '-'

func _ready():
	get_parent().get_child(0).connect('_hide', self, '_hide')

func _hide():
	pass

func _on_Area2D_body_entered(body):
	if body.get_name().match('Player'):
		active = true

func _on_Area2D_body_exited(body):
	if body.get_name().match('Player'):
		active = false

