extends Action

@export var interaction_handler : InteractionHandler

func move(delta):
	if interaction_handler:
		interaction_handler.interact()
	else:
		push_error("interaction_handler is null")
