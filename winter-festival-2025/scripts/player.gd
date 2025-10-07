# Author: Abigail Irvin
extends CharacterBody2D

var sanity_mult = 1
const SPEED: float = 150.0
var win_state: bool = false
var paused: bool = false
var timer: float = 0.0
@export var animatedRef: AnimatedSprite2D
@export var shadowRef: AnimatedSprite2D
@export var snowRef: Node2D
@export var xray_arrow: Sprite2D
var lantern = load("res://scenes/jar.tscn")
var light_ref: Node2D
var lantern_timer = 0
var lantern_max = 15
var spawned_light = false

var xray = false
var xray_spawned = false
var xray_max = 15
var xray_delay = 5
var xray_sanity = 25
var xray_timer = 0

func update_sanity_mult(new_mult):
	"""Helper function for the player called by main to update the current player
	sanity, used in determining player speed.
	"""
	sanity_mult = new_mult

func reset_pos():
	"""Helper function called by the exit gate, used to reset the player to a known safe
	location, and then to reset the map.
	"""
	self.position.x = 35
	self.position.y = 35
	self.get_tree().get_root().get_child(0).advance_level()
	snowRef.visible = true

func _input(event: InputEvent) -> void:
	"""Basic input function for the player, used for the lantern and xray powers.
	"""
	if self.get_tree().get_root().get_child(0).get_paused():
		return
	if event.is_action_pressed("light") and not spawned_light:
		light_ref = lantern.instantiate()
		light_ref.position.x += 20
		light_ref.position.y += 20
		add_child(light_ref)
		spawned_light = true
	elif event.is_action_pressed("special") and not xray_spawned:
		xray_spawned = true
		xray = true
		var main_ref = self.get_tree().get_root().get_child(0)
		if main_ref.sanity - xray_sanity > 0:
			main_ref.sanity -= xray_sanity
		

func _process(delta: float) -> void:
	"""General update function for the player, for things that are not specifically physics
	related to be updated such as the various power cooldowns.
	"""
	if spawned_light:
		lantern_timer += delta
		if lantern_timer > lantern_max:
			light_ref.queue_free()
			spawned_light = false
			lantern_timer = 0

	if xray_spawned:
		if not xray:
			# disabled externally, reset cost
			xray_spawned = false
			xray_timer = 0
			var main_ref = self.get_tree().get_root().get_child(0)
			main_ref.sanity += 25
			
		xray_timer += delta
		if xray_timer > xray_delay:
			xray_timer = 0
			xray_spawned = false
			xray = false

func xray_look_at(coords: Vector2) -> void:
	"""Helper function to get the arrow to point at the closest object. The offset of 90 degrees
	is needed as it generally points up, but the default position should be pointing right.
	"""
	xray_arrow.visible = true
	xray_arrow.look_at(coords)
	xray_arrow.rotate(deg_to_rad(90))

func disable_xray() -> void:
	"""Helper function called by main to disable the xray and make the arrow non-visible.
	"""
	xray = false
	xray_arrow.visible = false

func _physics_process(delta: float) -> void:
	"""Primary update function for the player, handling all movement commands.
	"""
	# Description
	# ----------
	# Basic physics process that handles basic movement for player.
	#
	# Parameters
	# ----------
	# delta : float
	#	represents the time between frames, used to do time-based calculations	
	if self.get_tree().get_root().get_child(0).get_paused():
		animatedRef.stop()
		shadowRef.stop()
		return
	var x_axis := Input.get_axis("left", "right")
	var y_axis := Input.get_axis("up", "down")
	if x_axis:
		# moving left / right
		velocity.x = x_axis * SPEED * sanity_mult
		if y_axis == 0:
			if x_axis > 0:
				animatedRef.play("right")
				shadowRef.play("right")
			else:
				animatedRef.play("left")
				shadowRef.play("left")
	else:
		# slowing down
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if y_axis:
		# moving up / down
		velocity.y = y_axis * SPEED * sanity_mult
		if y_axis > 0:
			animatedRef.play("down")
			shadowRef.play("down")
		else:
			animatedRef.play("up")
			shadowRef.play("up")
	else:
		# slowing down
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	move_and_slide()
	if velocity.x == 0 and velocity.y == 0:
		animatedRef.stop()
		shadowRef.stop()
	timer += delta
