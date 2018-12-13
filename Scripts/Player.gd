extends KinematicBody2D

signal test

const GRAVITY = 10
const SLIDE = 5
const LEAP_X = 175
const LEAP_Y = -150
const FLOOR = Vector2(0, -1)
const KEYS = {
	W = 87,
	A = 65,
	S = 83,
	D = 68,
	F = 70
}

var velocity = Vector2()
var movespeed = 30
var state = {
	stationary = true,
	can_leap_r = false,
	can_leap_l = false,
	leaping = false,
	focusing = false,
	blending = false,
	moving = false,
	facing = "r",
	visibility = 0
}

func _ready():
	pass
	
func _process(delta):

	if Input.is_key_pressed(KEYS.A) and state.stationary:
		state.moving = true
		state.facing = 'l'
		velocity.x = -movespeed
		$AnimatedSprite.play('walk')
		$AnimatedSprite.flip_h = true
		
	elif Input.is_key_pressed(KEYS.D) and state.stationary:
		state.moving = true
		state.facing = 'r'
		velocity.x = movespeed
		$AnimatedSprite.play('walk')
		$AnimatedSprite.flip_h = false

	elif Input.is_key_pressed(KEYS.S):
		velocity.x = 0
		$AnimatedSprite.play('blend')
		if $AnimatedSprite.frame == 2:
			state.blending = true

	elif Input.is_key_pressed(KEYS.F):
		state.focusing = true
		$Visibility.show()
		velocity.x = 0
		$AnimatedSprite.play('focus')

	elif Input.is_key_pressed(KEYS.W) and not state.leaping\
		 and (state.can_leap_l or state.can_leap_r) and state.stationary:
		state.leaping = true
		state.leap_timer_tick = false
		if state.can_leap_r:
			$Timer.start()
			$AnimatedSprite.play('vanish')
		if state.can_leap_l:
			$Timer.start()
			$AnimatedSprite.play('vanish')

	elif not state.leaping:
		state.moving = false
		state.blending = false
		state.focusing = false
		$Visibility.hide()
		if velocity.x > 0:
			velocity.x -= SLIDE
		elif velocity.x < 0:
			velocity.x += SLIDE
		else:
			$AnimatedSprite.play('idle')
	
	state_set()

	velocity.y += GRAVITY
	if state.facing.match('r'):
		state.can_leap_l = false
	if state.facing.match('l'):
		state.can_leap_r = false

func _physics_process(delta):
	if state.blending:
		$LightOccluder2D.hide()
	else:
		$LightOccluder2D.show()
	
#	if state.leaping:
#		$PlayerCollider.disabled = true
#	if state.leap_timer_tick:
#		$PlayerCollider.disabled = false
	
	move_and_slide(velocity, FLOOR)
	
# STATE -----------------------

func state_set():
	state.stationary = not (state.blending or state.leaping or state.moving or state.focusing) and is_on_floor()
	
	var tex
	if state.visibility < 10:
		tex = load('res://sprites/objects/Player_icons/visibility_0.png')
	elif state.visibility < 50:
		tex = load('res://sprites/objects/Player_icons/visibility_1.png')
	else:
		tex = load('res://sprites/objects/Player_icons/visibility_2.png')
	$Visibility.texture = tex
	
	if state.can_leap_l:
		$Arrow.rotation = -45
		$Arrow.show()
	elif state.can_leap_r:
		$Arrow.rotation = 45
		$Arrow.show()
	else:
		$Arrow.rotation = 0
		$Arrow.hide()

# EVENTS ----------------------

func _on_ColliderR_body_entered(body):
	if "Leapable".match(body.get_name()):
		state.can_leap_r = true
func _on_ColliderR_body_exited(body):
	if "Leapable".match(body.get_name()):
		state.can_leap_r = false

func _on_ColliderL_body_entered(body):
	emit_signal('test')
		
	if "Leapable".match(body.get_name()):
		state.can_leap_l = true
func _on_ColliderL_body_exited(body):
	if "Leapable".match(body.get_name()):
		state.can_leap_l = false

func _on_Timer_timeout():
	$AnimatedSprite.play('appear')
	if state.can_leap_r:
		translate(Vector2((2 * 32), 0))
		state.can_leap_r = false
	if state.can_leap_l:
		translate(Vector2((-1.5 * 32), 0))
		state.can_leap_l = false
	state.leaping = false
