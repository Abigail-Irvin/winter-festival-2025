extends Node
@export var abiRef: TextureRect
@export var isaRef: TextureRect
@export var effect: GPUParticles2D
@export var ui_mixer: AudioStreamPlayer
var anim_timer = 0.0
var anim_flip_time = 0.25
var isa_angles = [-15, 15]
var abi_angles = [15, -15]
var cur_idx = 0

func _process(delta: float) -> void:
	if not self.visible:
		return
	anim_timer += delta
	if anim_timer >= anim_flip_time:
		effect.modulate = Color(randf(), randf(), randf(), 1.0)
		anim_timer = 0
		if cur_idx:
			cur_idx = 0
		else:
			cur_idx = 1
		abiRef.rotation_degrees = abi_angles[cur_idx]
		isaRef.rotation_degrees = isa_angles[cur_idx]
		


func _on_button_pressed() -> void:
	self.visible = false
	GlobalData.paused = false
	ui_mixer.play()


func _on_button_mouse_entered() -> void:
	ui_mixer.play()
