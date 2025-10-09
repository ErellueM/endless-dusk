extends Node

var weapons = []

# Optional: max inventory size
@export var max_weapons = 6

# Add item to inventory
func add_weapon(weapon):
	if weapons.size() < max_weapons:
		weapons.append(weapon)
		print("Added weapon: ", weapon)
		return true
	else:
		print("Inventory full!")
		return false

# Remove weapon from inventory
func remove_weapon(weapon):
	if weapon in weapons:
		weapons.erase(weapon)
		print("Removed weapon: ", weapon)
		return true
	return false

# Check if item exists
func has_weapon(weapon):
	return weapon in weapons

# Get all items
func get_items():
	return weapons
