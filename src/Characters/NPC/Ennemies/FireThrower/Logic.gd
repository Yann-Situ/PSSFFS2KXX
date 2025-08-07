extends StatusLogic

####################################################################################################
## Ball holding system 
# The call are as follows:
# 	- the holder wants to pickup the ball and call ball.pick(holder)
# 	- pick(holder) check if the holder is able to pickup the ball.
# 		If yes, it returns true and update the current_holder and 
#		call holder._pick(ball), which will emit a signal
# 	- Then ball call holder._process_ball(ball, delta) and
# 		holder._physics_process_ball(ball, delta) each frames,
#		which will emit a signal each time
# 	- To get out, call ball.release() or ball.throw(pos,vel), it will call
# 		holder._release(ball), which will emit a signal
