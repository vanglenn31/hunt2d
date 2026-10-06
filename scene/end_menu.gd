extends CanvasLayer
# Builds a simple pause-style menu in code: dark overlay, title, and buttons.
# Usage: menu.show_menu("Title", [["Button text", callable], ...])

func show_menu(title: String, buttons: Array) -> void:
	layer = 100
	process_mode = Node.PROCESS_MODE_ALWAYS   # keep working while the game is paused
	get_tree().paused = true                   # freeze enemies, arrows, spawner

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.6)
	add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 12)
	center.add_child(box)

	var label := Label.new()
	label.text = title
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 6)
	box.add_child(label)

	var first: Button = null
	for b in buttons:
		var btn := Button.new()
		btn.text = b[0]
		btn.custom_minimum_size = Vector2(220, 44)
		btn.pressed.connect(b[1])
		box.add_child(btn)
		if first == null:
			first = btn
	if first:
		first.grab_focus()   # so Enter/Space also works
