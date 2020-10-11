extends Spatial

const DAMAGE : int = 15
const IDLE_ANIMATION_NAME = "Pistol_idle"
const FIRE_ANIMATION_NAME = "Pistol_fire"

var is_weapon_enabled : bool = false
var bullet_scene = preload("BulletScene.tscn")
var player_node = null

func fire_weapon():
	var clone = bullet_scene.instance()
	var scene_root = get_tree().root.get_children()[0]
	scene_root.add_child(clone)
	clone.global_transform = self.global_transform
	clone.scale = Vector3(4, 4, 4)
	clone.bullet_damage = DAMAGE


func equip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIMATION_NAME:
		is_weapon_enabled = true
		return true
	if player_node.animation_manager.current_state == "Idle_unarmed":
		player_node.animation_manager.set_animation("Pistol_equip")
	return false


func unequip_weapon():
	if player_node.animation_manager.current_state == IDLE_ANIMATION_NAME:
		if player_node.animation_manager.current_state != "Pistol_unequip":
			player_node.animation_manager.set_animation("Pistol_unequip")
	if player_node.animation_manager.current_state == "Idle_unarmed":
		is_weapon_enabled = false
		return true
	else:
		return false
