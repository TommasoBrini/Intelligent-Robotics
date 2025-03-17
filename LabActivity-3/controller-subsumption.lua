-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 15
LIGHT_THRESHOLD = 0.1
OBSTACLE_THRESHOLD = 0.1

n_steps = 0
behaviour_active = false

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end



--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	n_steps = n_steps + 1
	behavior_active = false

	-- LEVEL 2 Avoid Obstacle
	avoid_obstacles()
	
	-- LEVEL 1 Find Light --
	find_light()
	
	-- LEVEL 0 Move Random --
	move_random()	
	
	robot.wheels.set_velocity(left_v, right_v)
		
end
	
-- Level 0 --
function move_random()
	if behavior_active then 
		return
	end
	
	if n_steps % MOVE_STEPS == 0 then
		left_v = robot.random.uniform(0, MAX_VELOCITY)
		right_v = robot.random.uniform(0, MAX_VELOCITY)
	end
	
	log("move_random")
	
	robot.leds.set_all_colors("black")
	
end

-- Level 1 -- 
function find_light()

	if behavior_active then 
		return
	end
	
	total_light = 0
	weighted_direction = 0
	 
    for i = 1, #robot.light do
    	intensity = robot.light[i].value
    	total_light = total_light + intensity
    	weighted_direction = weighted_direction + intensity * (i - 1)
    end
    
    if total_light < LIGHT_THRESHOLD then
    	return
    end
    
    avg_sensor = weighted_direction / total_light
    angle = (avg_sensor / (#robot.light - 1)) * math.pi * 2
    
    left_v = MAX_VELOCITY * (1 - math.sin(angle))
    right_v = MAX_VELOCITY * (1 + math.sin(angle))
    
    robot.leds.set_all_colors("yellow")
    
    log("Find light")
    behavior_active = true
end

function avoid_obstacles()
	
	if behavior_active then 
		return
	end
	
	sensors = {3, 2, 1, 24, 23, 22}
	obstacle_detected = false
	for i = 1, #sensors do
		index = sensors[i]
		if robot.proximity[index].value > OBSTACLE_THRESHOLD then
			obstacle_detected = true
			direction = i
			break
		end
	end
	
	if obstacle_detected then
		log("avoid_obstacle")
		behavior_active = true
		if direction == 1 or direction == 2 or direction == 3 then
			left_v = -MAX_VELOCITY
			right_v = MAX_VELOCITY
		else
			left_v = MAX_VELOCITY
			right_v = -MAX_VELOCITY
		end
	end	
	
end

--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	n_steps = 0
	robot.leds.set_all_colors("black")
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
