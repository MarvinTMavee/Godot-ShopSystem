var items = {
	1 : {
		"name": "standard",
		"price": 0,
		"label": "PanelContainer/ScrollContainer/VBoxContainer/BallGrid/StandardBall/Price"
	},
	2: {
		"name": "red",
		"price": 250,
		"label": "PanelContainer/ScrollContainer/VBoxContainer/BallGrid/RedBall/Price"
	},
	3: {
		"name": "blue",
		"price": 750,
		"label": "PanelContainer/ScrollContainer/VBoxContainer/BallGrid/BlueBall/Price"
	},
	4: {
		"name": "gold",
		"price": 1500,
		"label": "PanelContainer/ScrollContainer/VBoxContainer/BallGrid/GoldBall/Price"
	}
}

func _ready():
	changeItemLabel()

#This shall be run every time, the buy button of an item is pressed (with the index of the item as the argument)
func buyBall(index):
	var raw_savedata = FileAccess.open("user://save.data", FileAccess.READ).get_as_text(true)
	var json_data = JSON.parse_string(raw_savedata)
	var item_name = items[index]["name"]
	print("item name: %s" % item_name)
	if json_data["items-bought"]["balls"]["%s" % item_name]: #Case: Item is already bought
		print("%s is already bought" % item_name)
		var duplicated_data = json_data.duplicate()
		duplicated_data["selected"] = index
		var overwrite_data = FileAccess.open("user://save.data", FileAccess.WRITE)
		overwrite_data.store_string("%s" % JSON.stringify(duplicated_data))
		await JSON.stringify(FileAccess.open("user://save.data", FileAccess.READ).get_as_text(true)) == JSON.stringify(duplicated_data)
		selectBall(index)
		changeItemLabel()
		print("Overwritten selected item to index %s" % duplicated_data["selected"])
	elif not json_data["items-bought"]["balls"]["%s" % item_name]: #Case: Item is not already bought
		if json_data["coins"] >= items[index]["price"]:
			print("Bought %s for %s coins" % [item_name, items[index]["price"]])
			var duplicate_data = json_data.duplicate()
			duplicate_data["items-bought"]["balls"]["%s" % item_name] = true
			duplicate_data["coins"] = duplicate_data["coins"] - items[index]["price"]
			print("Subtracted %s coins. Balance now: %s" % [items[index]["price"], duplicate_data["coins"]])
			print("Overwriting %s" % duplicate_data)
			var overwrite_data = FileAccess.open("user://save.data", FileAccess.WRITE)
			overwrite_data.store_string(" ")
			overwrite_data.store_string("%s" % JSON.stringify(duplicate_data))
			print("Overwriting complete!")
			var item_label_text = "%s" % items[index]["label"]
			var item_label = get_node("%s" % item_label_text)
			item_label.text = "OWNED"
			print("Changed label")
		else:
			print("Not enough money lol")


func selectBall(index):
	var item_id = int(index)
	print("%s" % item_id)
	var item_label = "%s" % items[item_id]["label"]
	var label_path = get_node("%s" % item_label)
	label_path.text = "SELECTED"
	print("%s" % item_label)
	print("Selected label assigned to id %s with the label path of: %s" % [item_id, item_label])
	

func changeItemLabel():
	await get_tree().create_timer(get_process_delta_time()).timeout
	var file = FileAccess.open("user://save.data", FileAccess.READ).get_as_text(true)
	var json_data = JSON.parse_string(file)
	for key in items.keys():
		var item = items[key]
		var item_name = item["name"]
		var item_label = item["label"]
		var label_node = get_node("%s" % item_label)
		var item_bought = json_data["items-bought"]["balls"]["%s" % item_name]
		if item_bought:
			label_node.text = "OWNED"
		elif not item_bought:
			label_node.text = "%s" % item["price"]
	var label_node = get_node("%s" % items[int(json_data["selected"])]["label"])
	label_node.text = "SELECTED"