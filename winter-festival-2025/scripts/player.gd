# Author: Abigail Irvin
extends CharacterBody2D


const SPEED: float = 300.0
var win_state: bool = false
var paused: bool = false
var timer: float = 0.0

func _physics_process(delta: float) -> void:
	# Description
	# ----------
	# Basic physics process that handles basic movement for player.
	#
	# Parameters
	# ----------
	# delta : float
	#	represents the time between frames, used to do time-based calculations	
	var x_axis := Input.get_axis("left", "right")
	var y_axis := Input.get_axis("up", "down")
	if x_axis:
		# moving left / right
		velocity.x = x_axis * SPEED
		if y_axis == 0:
			if x_axis > 0:
				pass
				#animation_sprite.play("right")
			else:
				pass
				#animation_sprite.play("left")
	else:
		# slowing down
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if y_axis:
		# moving up / down
		velocity.y = y_axis * SPEED
		if y_axis > 0:
			pass
			#animation_sprite.play("down")
		else:
			pass
			#animation_sprite.play("up")
	else:
		# slowing down
		velocity.y = move_toward(velocity.y, 0, SPEED)
		
	move_and_slide()
	timer += delta
