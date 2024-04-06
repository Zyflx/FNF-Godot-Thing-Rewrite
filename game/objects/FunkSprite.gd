class_name FunkSprite extends Sprite2D

# Sprite2D but with velocity and acceleration
# thanks flixel
# - Zyflx
 
# the velocity of this FunkSprite. Defaults to Vector2(0, 0)
var velocity:Vector2 = Vector2.ZERO
# the acceleration of this FunkSprite. Defaults to Vector2(0, 0)
var acceleration:Vector2 = Vector2.ZERO
# whether the sprite is active or not. Defaults to false.
# if false, all velocity and acceleration calculatons are canceled and
# if a sprite has acceleration or velocity set to them, no effect will take place.
var active:bool = false

func _process(delta:float) -> void:
	if (not active): pass
	
	var velocity_delta:Vector2 = Vector2(
		.5 * (_calc_velocity(velocity.x, acceleration.x, delta) - velocity.x),
		.5 * (_calc_velocity(velocity.y, acceleration.y, delta) - velocity.y)
	)
	
	velocity.x += velocity_delta.x * 2.0
	velocity.y += velocity_delta.y * 2.0
	position.x += velocity.x * delta
	position.y += velocity.y * delta
	
# calculates the velocity of this FunkSprite.
func _calc_velocity(_velocity:float, _acceleration:float, delta:float) -> float:
	return _velocity + (_acceleration * delta if _acceleration != 0.0 else 0.0)
