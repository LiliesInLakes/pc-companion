extends Node2D

var speed = 200
var direction = Vector2(1, 1)
var screen_size = Vector2()
var window_size = Vector2(200, 200)
var idle_timer = 0.0
var is_idling = false
var is_dragging = false
var drag_offset = Vector2()


@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area = $Area2D

func _on_area_input(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			var mouse_pos = Vector2(DisplayServer.mouse_get_position())
			var win_pos = Vector2(DisplayServer.window_get_position())
			drag_offset = mouse_pos - win_pos
		else:
			is_dragging = false

func _ready():
	screen_size = Vector2(DisplayServer.screen_get_size())
	if animated_sprite:
		animated_sprite.play("fly")
	area.input_event.connect(_on_area_input)

func maybe_idle():
	if randf() < 0.3:
		is_idling = true
		idle_timer = randf_range(1.0, 3.0)
		var r = randi()%3
		if r == 0 and animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")
			speed = 0
func _physics_process(delta: float) -> void:
	if is_dragging:
		var mouse_pos = Vector2(DisplayServer.mouse_get_position())
		var new_win_pos = mouse_pos - drag_offset
		DisplayServer.window_set_position(Vector2i(new_win_pos))
		return
	if is_idling:
		idle_timer -= delta
		if idle_timer <=0:
			is_idling = false
			speed = 200
			animated_sprite.play("fly")
		return 
	var window_pos = Vector2(DisplayServer.window_get_position())
	if window_pos.x <= 0 or window_pos.x >= screen_size.x - window_size.x:
		direction.x *= -1
		animated_sprite.flip_h = !animated_sprite.flip_h
		if(randf() <0.5):
			direction.y *= -1
		else:
			direction.y = 0
		maybe_idle()
	if window_pos.y <= 0 or window_pos.y >= screen_size.y - window_size.y:
		direction.y *= -1
		maybe_idle()
		if(randf() <0.5):
			direction.x *= -1
		else:
			direction.x = 0
	window_pos += direction *speed *delta
	window_pos.x = clamp(window_pos.x, 0, screen_size.x - window_size.x)
	window_pos.y = clamp(window_pos.y, 0, screen_size.y - window_size.y)
	DisplayServer.window_set_position(Vector2i(window_pos))
	
