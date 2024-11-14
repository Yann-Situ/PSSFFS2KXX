extends StatusLogic

@export var fetcher : Area2D

var ball : Node2D = null

func _on_ball_fetcher_body_entered(body):
	ball = body
	print("ball fetched: "+ball.name)

func _on_ball_fetcher_body_exited(body):
	if ball == body:
		print("ball defetched... "+ball.name)
		ball = null
	if ball == null:
		var bodies = fetcher.get_overlapping_bodies()
		if not bodies.is_empty():
			ball = bodies[0]
			print("ball fetched: "+ball.name)

func found_ball() -> bool:
	return ball != null
