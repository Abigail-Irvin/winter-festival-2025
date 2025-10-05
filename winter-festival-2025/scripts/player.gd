# Author: Abigail Irvin
extends CharacterBody2D


const SPEED: float = 200.0
var win_state: bool = false
var paused: bool = false
var timer: float = 0.0
@export var animatedRef: AnimatedSprite2D
@export var shadowRef: AnimatedSprite2D
	
func _input(event: InputEvent) -> void:
	if self.get_tree().get_root().get_child(0).get_paused():
		return
	if event.is_action_pressed("light"):
		print("light it up")
	elif event.is_action_pressed("special"):
		print("sees all tbh")

func _physics_process(delta: float) -> void:
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
		velocity.x = x_axis * SPEED
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
		velocity.y = y_axis * SPEED
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
