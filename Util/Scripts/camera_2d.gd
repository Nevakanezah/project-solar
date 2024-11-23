extends Camera2D

@export var shake_strength := 30.0
@export var onhit_shake_fade := 5.0

@export var sizzle_fadein := 4.0
@export var sizzle_fadeout := 8.0

var rng = RandomNumberGenerator.new()

var is_sizzle := false
var sizzle_strength := 15.0

var onhit_value := 0.0
var sizzle_value := 0.0

func camera_shake_onhit():
	onhit_value = shake_strength

func camera_start_sizzle(sizzle_input : float = 5.0):
	is_sizzle = true
	sizzle_strength = sizzle_input
	
func camera_end_sizzle():
	is_sizzle = false
	
func _process(delta):
	if is_sizzle:
		sizzle_value = lerpf(0.0,sizzle_strength,sizzle_fadein * delta)
	else:
		sizzle_value = lerpf(sizzle_value,0.0, sizzle_fadeout * delta)
	
	if onhit_value > 0.0:
		onhit_value = lerpf(onhit_value,0.0,onhit_shake_fade * delta)
		
	if sizzle_value + onhit_value > 0.0:
		offset = _getOffset(sizzle_value + onhit_value)
	else:
		offset = Vector2.ZERO
	
func _getOffset(displacement : float) -> Vector2:
	return Vector2(rng.randf_range(-displacement, displacement), randf_range(-displacement, displacement))
