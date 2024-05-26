extends CardState

var played: bool

func enter() -> void:
	visual_update(Color.DARK_VIOLET, "RELEASED")
	
	played = false
	if not card_ui.targets.is_empty():
		played = true
		print("play card for target(s) ", card_ui.targets)
		
func on_input(event: InputEvent):
	if played:
		return
	transition_requested.emit(self, CardState.State.BASE)
