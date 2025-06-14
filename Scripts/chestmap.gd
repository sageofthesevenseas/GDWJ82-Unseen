extends Node2D
class_name ChestMap

@export var chest_prefab: PackedScene
@export var number_of_chests: int = 20
var location_array = []
var chosen_spots = []
@onready var spawn_points: Node = %SpawnPoints
@onready var chests_spawned: Node = %ChestsSpawned

# LZB NOTE 15-06-25 - I have not completed this part yet, not sure how it should be finished
@export var story_item_prefab: Node
var weapon_item_prefab: Node
var util_item_prefab: Node
# LZB NOTE 15-06-25 - I have not completed this part yet, not sure how it should be finished
var possible_items = {
	"story item": story_item_prefab,
	"weapon item": weapon_item_prefab,
	"utility item": util_item_prefab
}

func _ready() -> void:
	spawn_chests()

func spawn_chests():
	await choose_chest_locations()
	for chest_location in chosen_spots:
		# LZB NOTE 15-06-25 - pick a random chest contents/typed
		#if the chosen type is a plot item, assign one of those and remove it from the plot item list
		
		#get the actual vector 2 location
		
		#spawn the hidden mine
		var chest = chest_prefab.instantiate()
		chests_spawned.add_child(chest)
		chest.position = chest_location.position
		#hand over the contents
		
	

func choose_chest_locations():
	collect_locators()
	for point in number_of_chests:
		# LZB NOTE 15-06-25 - choose locations from the array of possible spots, add them to the chosen spot list, then remove that from the original list so it doesnt pick the same one twice
		var random_pick = location_array.pick_random()
		chosen_spots.append(random_pick)
		location_array.erase(random_pick)
	#print(chosen_spots, "picked, ", chosen_spots.size(), " in total")

func collect_locators():
# LZB NOTE 15-06-25 - maybe doesnt need to be a function but whatever
	location_array = spawn_points.get_children()
	print(location_array.size())
