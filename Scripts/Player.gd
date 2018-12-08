extends KinematicBody2D

const GRAVITY = 10
const SLIDE = 5
const LEAP_X = 170
const LEAP_Y = -150
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
	can_leap_r = false,
	can_leap_l = false,
	leap_timer_tick = false,
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
	$Debug.text = str(state.can_leap_r) + "\n" + str(state.can_leap_l) + "\n" + state.facing
	
	if Input.is_key_pressed(KEYS.A):
		state.moving = true
		state.facing = 'l'
		velocity.x = -movespeed
		$AnimatedSprite.play('walk')
		$AnimatedSprite.flip_h = true
		
	elif Input.is_key_pressed(KEYS.D):
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
		velocity.x = 0
		$AnimatedSprite.play('focus')

	elif Input.is_key_pressed(KEYS.W) and not state.leaping and (state.can_leap_l or state.can_leap_r):
		state.leaping = true
		state.leap_timer_tick = false
		$Timer.start()
		if state.can_leap_r:
			$AnimatedSprite.play('leap')
			velocity.y = LEAP_Y
			velocity.x = LEAP_X
			state.can_leap_r = false
		if state.can_leap_l:
			$AnimatedSprite.play('leap')
			velocity.y = LEAP_Y
			velocity.x = -LEAP_X
			state.can_leap_l = false
	elif not Input.is_key_pressed(KEYS.W) and state.leaping:
		state.leaping = false

	else:
		state.moving = false
		state.blending = false
		state.focusing = false
		if velocity.x > 0:
			velocity.x -= SLIDE
		elif velocity.x < 0:
			velocity.x += SLIDE
		else:
			$AnimatedSprite.play('idle')

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
	
	if state.leaping:
		$PlayerCollider.disabled = true
	if state.leap_timer_tick:
		$PlayerCollider.disabled = false
	
	move_and_slide(velocity)

func _on_ColliderR_body_entered(body):
	if "Leapable".match(body.get_name()):
		state.can_leap_r = true
func _on_ColliderR_body_exited(body):
	if "Leapable".match(body.get_name()):
		state.can_leap_r = false

func _on_ColliderL_body_entered(body):
	if "Leapable".match(body.get_name()):
		state.can_leap_l = true
func _on_ColliderL_body_exited(body):
	if "Leapable".match(body.get_name()):
		state.can_leap_l = true

func _on_Timer_timeout():
	state.leap_timer_tick = true
