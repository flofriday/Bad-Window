extends Node

var hasMoved = false
var limit = Vector2()
var isEvil = true

var win_pos = Vector2()
var win_size = Vector2()
var mouse_pos = Vector2()
var screen_size = Vector2()


# Set the "mood" of the window. This however is just cosmetic and doesn't change the behavior
func set_mood(mood):
	if mood == "evil":
		$MarginContainer/VBoxContainer/WarningTexture.visible = false
		$MarginContainer/VBoxContainer/EvilTexture.visible = true
		$MarginContainer/VBoxContainer/NiceTexture.visible = false
		$MarginContainer/VBoxContainer/Label.text = "No way f***er,\nI will allways ESCape!"
		OS.set_window_title("Bye F***er")
	elif mood == "nice":
		$MarginContainer/VBoxContainer/WarningTexture.visible = false
		$MarginContainer/VBoxContainer/EvilTexture.visible = false
		$MarginContainer/VBoxContainer/NiceTexture.visible = true
		$MarginContainer/VBoxContainer/Label.text = "Sorry,\nhere i am "
		OS.set_window_title("Sorry")


func swap_evil():
	isEvil = !isEvil
	
	if isEvil: 
		set_mood("evil")
	else:
		set_mood("nice")


# Set the position of the window
func set_position(pos):
	pos.x = clamp(pos.x, 0, screen_size.x - win_size.x)
	pos.y = clamp(pos.y, 0, screen_size.y - win_size.y)
	
	win_pos = pos
	OS.set_window_position(win_pos)


func _ready():
	# Set the Window title
	OS.set_window_title("Error")
	
	# Set the window size
	screen_size = OS.get_screen_size(OS.get_current_screen())
	var smaller_side = min(screen_size.x, screen_size.y)
	win_size = Vector2(smaller_side, smaller_side)/10
	OS.set_window_size(win_size)
	win_size = OS.get_real_window_size()
	limit = win_size * 0.6
	
	# Set the window in the middle
	OS.center_window()
	win_pos = OS.get_window_position()


func _process(delta):
	# Prevent dragging
	if OS.get_window_position() != win_pos:
		OS.set_window_position(win_pos)
	OS.move_window_to_foreground()
	
	
	# Get the distance from the mouse to the window
	var distance = (win_pos + win_size/2) - mouse_pos
	
	# The window behaves different, depending on the mood
	if isEvil:
		if distance.length() < limit.length():
			# Remove the initial error state to evil if this was the first move
			if hasMoved == false:
				hasMoved = true
				set_mood("evil")
				
			# Set the new position (try to escape the the cursor)
			var move = distance.normalized()*(limit.length()-distance.length())
			move /= 2
			set_position(win_pos + move)
			
	else:
		if distance.length() > limit.length():
			# Set the new window position (try to follow the cursor)
			var move = distance.normalized()*(distance.length()-limit.length())
			move /= 10
			set_position(win_pos - move)


func _input(event):
	if event is InputEventMouseMotion:
       mouse_pos = win_pos + event.position
	elif event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
            swap_evil()