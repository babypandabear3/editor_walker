@tool
extends EditorPlugin

var scene_root
var editor_player

var editor_walker_ui 
var is_enabled = false

func _enter_tree():
	editor_player = get_tree().get_first_node_in_group("editor_player")
	if editor_player:
		get_editor_interface().edit_node(editor_player)
	
	editor_walker_ui = load("res://addons/bpb_editor_walker/ui/editor_walker_ui.tscn").instantiate()
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, editor_walker_ui)
	editor_walker_ui.plugin_main = self
	
func _exit_tree():
	editor_player = get_tree().get_first_node_in_group("editor_player")
	if editor_player:
		editor_player.editor_walker_active = false
	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, editor_walker_ui)
	pass

func _handles(object):
	return true
	
func _forward_3d_gui_input(viewport_camera, event):
	if not is_enabled:
		return
		
	editor_player = get_tree().get_first_node_in_group("editor_player")
	if not editor_player:
		return 
	editor_player.editor_walker_active = is_enabled
	editor_player.plugin_camera = viewport_camera
	
	
	if event is InputEventMouseMotion:
		editor_player.motion = event.relative
		
	return true
	
func toggled(button_pressed):
	is_enabled = button_pressed
	if not is_enabled:
		editor_player = get_tree().get_first_node_in_group("editor_player")
		if editor_player:
			editor_player.editor_walker_active = false
