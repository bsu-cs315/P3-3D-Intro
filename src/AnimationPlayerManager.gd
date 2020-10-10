extends AnimationPlayer

var states = {
	"idle_unarmed" : ["knife_equip", "pistol_equip", "rifle_equip", "idle_unarmed"],
	
	"pistol_equip" : ["pistol_idle"],
	"pistol_fire" : ["pistol_idle"],
	"pistol_idle" : ["pistol_fire", "pistol_reload", "pistol_unequip", "pistol_idle"],
	"pistol_reload" : ["pistol_idle"],
	"pistol_unequip" : ["idle_unarmed"],
	
	"rifle_equip" : ["rifle_idle"],
	"rifle_fire" : ["rifle_idle"],
	"rifle_idle" : ["rifle_fire", "rifle_reload", "rifle_unequip", "rifle_idle"],
	"rifle_reload" : ["rifle_idle"],
	"rifle_unequip" : ["idle_unarmed"],
	
	"knife_equip" : ["knife_idle"],
	"knife_fire" : ["knife_idle"],
	"knife_idle" : ["knife_fire", "knife_reload", "knife_unequip", "knife_idle"],
	"knife_unequip" : ["idle_unarmed"],
}
var animation_speeds = {
	"idle_unarmed" : 1,
	
	"pistol_equip" : 1.4,
	"pistol_fire" : 1.8,
	"pistol_idle" : 1,
	"pistol_reload" : 1,
	"pistol_unequip" : 1.4,
	
	"rifle_equip" : 2,
	"rifle_fire" : 6,
	"rifle_idle" : 1,
	"rifle_reload" : 1.45,
	"rifle_unequip" : 2,
	
	"knife_equip" : 1,
	"knife_fire" : 1.35,
	"knife_idle" : 1,
	"knife_unequip" : 1,
}
var current_state = null
var callback_function = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_animation("idle_animation")
	connect("animation_finished", self, "animation_ended")


func set_animation(animation_name : String) -> bool:
	if animation_name == current_state:
		print("AnimationPlayerManager.gd -- WARNING animation is already ", animation_name)
		return true
	if has_animation(animation_name):
		if current_state != null:
			var possible_animations = states[current_state]
			if animation_name in possible_animations:
				current_state = animation_name
				play(animation_name, -1, animation_speeds[animation_name])
				return true
			else:
				print("AnimationPlayerManager.gd -- WARNING: Cannot change to ", animation_name, " from ", current_state)
				return false
		else:
			current_state = animation_name
			play(animation_name, -1, animation_speeds[animation_name])
			return true
	return false


func animation_ended(animation_name : String) -> void:
	if current_state == "idle_unarmed":
		pass
	elif current_state == "knife_equip":
		set_animation("knife_idle")
	elif current_state == "knife_idle":
		pass
	elif current_state == "knife_fire":
		set_animation("knife_idle")
	elif current_state == "knife_unequip":
		set_animation("idle_unarmed")
	elif current_state == "pistol_equip":
		set_animation("pistol_idle")
	elif current_state == "pistol_idle":
		pass
	elif current_state == "pistol_fire":
		set_animation("pistol_idle")
	elif current_state == "pistol_unequip":
		set_animation("idle_unarmed")
	elif current_state == "pistol_reload":
		set_animation("pistol_idle")
	elif current_state == "rifle_equip":
		set_animation("rifle_idle")
	elif current_state == "rifle_idle":
		pass;
	elif current_state == "rifle_fire":
		set_animation("rifle_idle")
	elif current_state == "rifle_unequip":
		set_animation("idle_unarmed")
	elif current_state == "rifle_reload":
		set_animation("rifle_idle")


func animation_callback() -> void:
	if callback_function == null:
		print("AnimationPlayerManager.gd -- WARNING: No callback function for the animation to call!")
	else:
		callback_function.call_func()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
