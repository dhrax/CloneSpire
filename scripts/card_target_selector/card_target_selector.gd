extends Node2D

const ARC_POINTS := 8

@onready var area_2d = $Area2D
@onready var card_arc = $CanvasLayer/CardArc

var current_card: CardUI
var targetting := false

func _ready():
	Events.card_aim_started.connect(_on_card_aim_started)
	Events.card_aim_ended.connect(_on_card_aim_ended)

func _process(delta: float):
	if not targetting:
		return
		
	area_2d.position = get_local_mouse_position()
	card_arc.points = _get_points()
	
func _get_points() -> Array:
	var points := []
	var start := current_card.global_position
	start.x += (current_card.size.x / 2)
	var target := get_local_mouse_position()
	var distance := target - start
	
	for i in range(ARC_POINTS):
		var t := (1.0 / ARC_POINTS) * i
		var x := start.x + (distance.x / ARC_POINTS) * i
		var y := start.y + _ease_out_cubic(t) * distance.y
		points.append(Vector2(x, y))
	points.append(target)
	
	return points
	
func _ease_out_cubic(number: float) -> float:
	# 1 - (1-x)^3
	return 1.0 - pow(1.0 - number, 3.0)

func _on_card_aim_started(card_ui: CardUI):
	if not card_ui.card.is_single_targeted():
		return
	
	targetting = true
	area_2d.monitoring = true
	area_2d.monitorable = true
	current_card = card_ui

func _on_card_aim_ended(card_ui: CardUI):
	targetting = false
	area_2d.position = Vector2.ZERO
	area_2d.monitoring = false
	area_2d.monitorable = false
	current_card = null
	card_arc.clear_points()

func _on_area_2d_area_entered(area: Area2D):
	if not current_card or not targetting:
		return
		
	if not current_card.targets.has(area):
		current_card.targets.append(area)

func _on_area_2d_area_exited(area: Area2D):
	if not current_card or not targetting:
		return
		
	current_card.targets.erase(area)
