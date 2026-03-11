class_name MainUI
extends Control

enum Menu { MAIN, SETTINGS, LEVEL_PICK, PAUSE, COMPLETION }

# -- Signals forwarded to Main --

signal level_load_requested(id: int)
signal main_menu_requested
signal next_level_requested
signal resume_requested

var _menus: Dictionary
var _stack: Array[Menu] = []


func _ready() -> void:
	_menus = {
		Menu.MAIN: get_node("MainMenu"),
		Menu.SETTINGS: get_node("SettingsMenu"),
		Menu.LEVEL_PICK: get_node("LevelPickMenu"),
		Menu.PAUSE: get_node("PauseMenu"),
		Menu.COMPLETION: get_node("CompletionMenu"),
	}

	for menu in _menus.values():
		menu.hide()

	_menus[Menu.MAIN].open_submenu.connect(push)
	_menus[Menu.PAUSE].open_submenu.connect(push)
	_menus[Menu.PAUSE].resume_requested.connect(resume_requested.emit)
	_menus[Menu.PAUSE].main_menu_requested.connect(main_menu_requested.emit)
	_menus[Menu.SETTINGS].close_requested.connect(pop)
	_menus[Menu.COMPLETION].main_menu_requested.connect(main_menu_requested.emit)
	_menus[Menu.COMPLETION].next_level_requested.connect(next_level_requested.emit)
	_menus[Menu.LEVEL_PICK].level_load_request.connect(level_load_requested.emit)


# -- ESC handling for sub-menus; root menu ESC is handled by Main --

## Pops sub-menu on ESC; ignores if at root (handled by Main)
func _input(event: InputEvent) -> void:
	if not visible: return
	if not event.is_action_pressed("ui_cancel"): return
	if _stack.size() <= 1: return
	pop()
	get_viewport().set_input_as_handled()


# -- Public API for Main --

func show_main_menu() -> void:
	new_stack(Menu.MAIN)

func show_pause_menu() -> void:
	new_stack(Menu.PAUSE)

func show_completion_menu() -> void:
	new_stack(Menu.COMPLETION)


# -- Stack navigation --

func push(menu: Menu) -> void:
	if _stack.size() > 0:
		_menus[_stack.back()].hide()
	_stack.append(menu)
	_menus[menu].show()

func pop() -> void:
	if _stack.size() <= 1: return
	_menus[_stack.back()].hide()
	_stack.pop_back()
	_menus[_stack.back()].show()

## Clears navigation history and starts fresh from root menu
func new_stack(root: Menu) -> void:
	while _stack.size() > 0:
		_menus[_stack.back()].hide()
		_stack.pop_back()
	push(root)
