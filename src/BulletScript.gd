extends Spatial

const KILL_TIMER : int = 4

var bullet_speed : int = 70
var bullet_damage : int = 15
var timer : float = 0
var has_hit_something : bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area.connect("body_entered", self, "collided")


func _physics_process(delta : float) -> void:
	var forward_dir = global_transform.basis.z.normalized()
	global_translate(forward_dir * bullet_speed * delta)
	timer += delta
	if timer >= KILL_TIMER:
		queue_free()


func collided(body) -> void:
	if has_hit_something == false:
		if body.has_method("bullet_hit"):
			body.bullet_hit(bullet_damage, global_transform)
	has_hit_something = true
	queue_free()
