class_name CharacterBase extends KinematicBody2D

const hitboxes = {
	'middle': preload('res://Scenes/boxes/MeleeHitbox.tscn'),
}

const UP 			= Vector2(0,-5)
const GRAVITY 		= 20
const SPEED 		= 300
const JUMP_HEIGHT 	= -610
const BASIC_DAMAGE	= 10

enum stateMachine {
	#movements / simple states
	IDLE, WALKING, JUMP, FALL, TAKE_DAMAGE
	#middle attacks
	IDDLE_MIDDLE_FIST_ATTACK, IDDLE_MIDDLE_LEG_ATTACK,
	#bottom attacks

	#on_air attacks
	JUMP_LEG_ATTACK
}

var isStaticEnemy = false
var isReceivingDamage = false
var isAttacking = false
var motion = Vector2()
var animation = ''
var isPlayer2 = false
var direction = 0 #FALSE para direita & TRUE para esquerda
var state = stateMachine.IDLE
var enteredState = true
var temporary_direction = null

onready var animatedSprite : AnimatedSprite = get_node('AnimatedSprite')

func _physics_process(_delta: float):
	motion = move_and_slide(motion, UP)
	if !isPlayer2:
		direction = Input.get_axis('ui_left', 'ui_right')
	else:
		direction = Input.get_axis('ui_left_p2', 'ui_right_p2')

func _move_and_slide():
	if get_tree().has_network_peer():
		Server._get_player_pos(motion, direction, get_node('/root/Main/Main/Player').get_instance_id())
	else:
		motion.x = direction * SPEED

func _apply_gravity():
  motion.y += GRAVITY

func _set_animation(anim: String):
	if animation != anim:
		animation = anim
		animatedSprite.play(animation)

func _stop_movement():
  motion.x = 0

func _set_flip():
	if direction && !isStaticEnemy:
		animatedSprite.flip_h = false if direction > 0 else true

func _load_hitbox( hbtype ):
	var hitbox = hitboxes[hbtype].instance()
	animatedSprite.add_child( hitbox )

func _kill_hitbox( hbtype ):
	var hitbox
	match hbtype:
		'middle': hitbox = animatedSprite.get_node('MeleeHitbox')

	animatedSprite.remove_child(hitbox)

func _enter_state( newState ):
	if state != newState:
		state = newState
		enteredState = true

func _get_player_number():
	return self.isPlayer2
