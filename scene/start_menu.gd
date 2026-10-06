extends Control
# Title screen. Builds its own UI in code.

const BG := "res://asset/bg/00f33a6b-4c20-4d32-9f00-7996c9c7ddc7.jpg"

func _ready() -> void:
	get_tree().paused = false
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	if ResourceLoader.exists(BG):
		var bg := TextureRect.new()
		bg.texture = load(BG)
		bg.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		bg.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(bg)
		bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	else:
		var solid := ColorRect.new()
		solid.color = Color(0.1, 0.15, 0.2)
		add_child(solid)
		solid.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 14)
	center.add_child(box)

	box.add_child(_label("HUNT 2D", 56))
	var goals := " / ".join(Game.TARGETS.map(func(n): return str(n)))
	box.add_child(_label("Hit %s targets in 60 seconds to clear each stage" % goals, 16))
	box.add_child(_label("A / D  move      Left click  shoot", 16))

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 16)
	box.add_child(spacer)

	var start := _button("Start Game")
	start.pressed.connect(Game.restart_game)
	box.add_child(start)
	start.grab_focus()

	var quit := _button("Quit")
	quit.pressed.connect(func(): get_tree().quit())
	box.add_child(quit)


func _label(text: String, size: int) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)
	return l


func _button(text: String) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(240, 48)
	return b
