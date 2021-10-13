extends Node

var directory = Directory.new()
var expressions = []
var parameters = {}
var fileName = "/Save.sav"
var folderName = OS.get_executable_path().get_base_dir().plus_file("Save")

func Save():
	var world = get_node("/root/World")
	expressions.clear()
	expressions.push_back(world.equasionX)
	expressions.push_back(world.equasionY)
	expressions.push_back(world.equasionZ)
	var file =  File.new()
	if !directory.dir_exists(folderName):
		directory.make_dir_recursive(folderName)
		directory.change_dir(folderName)
	var error 
	error = file.open(folderName + fileName, File.WRITE)
	if error == OK:
		for i in range(3):
			file.store_line(expressions[i] + "\r")
	else:
		print("Couldn't open file for writing. Error: " + error)
		return

	parameters.clear()
	var UI = get_node("/root/World/UI")
	for p in UI.parameterUIs:
		if p.active:
			parameters[p.parameterName] = p.parameterValueLineEdit.text
	file.store_line(to_json(parameters))
	file.close()


func Load():
	var world = get_node("/root/World")
	expressions.clear()
	var file = File.new()
	if !directory.dir_exists(folderName):
		return
	var error
	error = file.open(folderName + fileName, File.READ)
	if error == OK:
			for i in range(3):
				expressions.push_back(file.get_line())
			world.LoadEquasions(expressions)
	else:
		print("Couldn't open file for reading. Error: " + str(error))
		return
	
	parameters.clear()
	var temp = parse_json(file.get_line())
	if !temp:
		file.close()
		return
	parameters = temp
	var UI = get_node("/root/World/UI")
	for i in parameters.size():
		UI.CreateParameter(parameters.keys()[i], parameters.values()[i])
	for p in UI.parameterUIs:
		if p.active:
			p.ParseExpression()
	file.close()
