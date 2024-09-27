extends Node


# TODO: neuer modloader der PCK / ZIP datein nutzt um mods zu laden





const mods_dir = "user://mods"

var test

var mod_files = files.new()
var game_files = files.new()

signal loading_mods_finished

class files:
	var file_name : Array 
	var file_path : Array

func _ready():
	DirAccess.make_dir_absolute("user://mods")
	DirAccess.make_dir_absolute("user://temp")







func load_files(backup_files : bool, files_dir : String = "user://mods", load_files : files = mod_files):
	for directory in DirAccess.get_directories_at(mods_dir):
		#print_rich("[b]" + directory + "[/b]")
		for file in DirAccess.get_files_at(files_dir + "/" + directory):
			#print(file)
			load_files.file_name.append(file)
			load_files.file_path.append(files_dir + '/' + directory + '/' + file)
	
	#print("")
	#print("### printing game files ###")
	#print("")
	
	for directory in DirAccess.get_directories_at("res://"):
		#print_rich("[b]" + directory + "[/b]")
		for file in DirAccess.get_files_at("res://" + directory):
			#print(file)
			game_files.file_name.append(file)
			game_files.file_path.append("res://" + directory + '/' + file)
	
	for i in load_files.file_name.size():
		if game_files.file_name.has(load_files.file_name[i]):
			var mod_file_path = load_files.file_path[i]
			var game_file_path = game_files.file_path[game_files.file_name.find(load_files.file_name[i])]
			
			
			if backup_files:
				var game_image = Image.new()
				game_image.load(game_file_path)
				
				var game_t = ImageTexture.new()
				game_t.set_image(game_image)
				
				game_image.save_png("user://temp/" + mod_files.file_name[i])
						
			var image = Image.new()
			image.load(mod_file_path)
			
			var t = ImageTexture.new()
			t.set_image(image)
			
			load(game_file_path).load(mod_file_path)
			
			ResourceSaver.save(t, game_file_path)
	loading_mods_finished.emit()
