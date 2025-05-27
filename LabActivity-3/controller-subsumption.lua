-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 15
LIGHT_THRESHOLD = 0.05
OBSTACLE_THRESHOLD = 0.1

n_steps = 0
finish = false

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	finish = false
	n_steps = 0
	robot.leds.set_all_colors("black")
end



--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	if finish then
		return
	end
	
	n_steps = n_steps + 1
	
	lv = robot.random.uniform(0, MAX_VELOCITY)
    rv = robot.random.uniform(0, MAX_VELOCITY)
    color = "black"
    handler = false

	-- LEVEL 3 Stop under light
	lv, rv, color, finish, handler = stop(lv, rv, color, finish, handler)
	
	-- LEVEL 2 Avoid Obstacle
	lv, rv, color, handler = avoid_obstacles(lv, rv, color, handler)
	
	-- LEVEL 1 Find Light --
	lv, rv, color, handler = find_light(lv, rv, color, handler)
	
	-- LEVEL 0 Move Random --
	lv, rv, color, handler = move_random(lv, rv, color, handler)	
	
	robot.wheels.set_velocity(lv, rv)
	robot.leds.set_all_colors(color)
		
end
	
-- Level 0 -- Random walk
function move_random(lv, rv, color, handler)
	if handler then
		return lv, rv, color, handler
	end
	
	if n_steps % MOVE_STEPS == 0 then
		lv = robot.random.uniform(0, MAX_VELOCITY)
		rv = robot.random.uniform(0, MAX_VELOCITY)
	end
	
	log("move_random")
	return lv, rv, color, handler

end

-- Level 1 -- phototaxis
function find_light(lv, rv, color, handler)	
	if handler then
		return lv, rv, color, handler
	end
	total_light = 0
	weighted_direction = 0
	 
    for i = 1, #robot.light do
    	intensity = robot.light[i].value
    	total_light = total_light + intensity
    	weighted_direction = weighted_direction + intensity * (i - 1)
    end
    
    if total_light >= LIGHT_THRESHOLD then
	    avg_sensor = weighted_direction / total_light
	    angle = (avg_sensor / (#robot.light - 1)) * math.pi * 2
    
	    lv = MAX_VELOCITY * (1 - math.sin(angle))
	    rv = MAX_VELOCITY * (1 + math.sin(angle))
	    color = "yellow"
	    handler = true
    
	    log("Find light")
	end
	return lv, rv, color, handler
end

-- Level 2 - Avoid obstacles
function avoid_obstacles(lv, rv, color, handler)
	if handler then
		return lv, rv, color, handler
	end
	sensors = {1, 2, 24, 23}
    closest_obstacle_distance = math.huge
    direction = nil
	for i = 1, #sensors do
        index = sensors[i]
        proximity_value = robot.proximity[index].value
        if proximity_value > OBSTACLE_THRESHOLD and proximity_value < closest_obstacle_distance then
                closest_obstacle_distance = proximity_value
                direction = i
        end
    end
	
	if direction then
		if direction <= 2 then
			lv = MAX_VELOCITY
            rv = -MAX_VELOCITY 
		else
			lv = -MAX_VELOCITY 
            rv = MAX_VELOCITY
		end
		color = "blue"
		handler = true
		log("avoid obstacle")
	end	
	return lv, rv, color, handler
end

-- Level 3 - Stop
function stop(lv, rv, color, finish, handler)
	if handler then
		return lv, rv, color, handler
	end
    ground_value = robot.motor_ground[1].value
    if ground_value == 0 then
        lv = 0
        rv = 0
        color = "red"
        finish = true
        handler = true
        log("Stop")
    end
    return lv, rv, color, finish, handler
end
	

--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	n_steps = 0
	finish = false
	robot.leds.set_all_colors("black")
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
