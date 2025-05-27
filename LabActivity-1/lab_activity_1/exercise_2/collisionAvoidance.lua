-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 10
PROXIMITY_THRESHOLD = 0.1

n_steps = 0

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
	
	proximity_sensors = {}
	sensors = {4, 3, 2, 1, 24, 23, 22, 21}
	for i = 1, #sensors do
		proximity_sensors[i] = robot.proximity[sensors[i]].value
	end
	
	obstacle_detected, index = max(proximity_sensors)
	
	if obstacle_detected > PROXIMITY_THRESHOLD then
		if index <= 4 then
			-- obstacle to the left
			log("obstacle to the left")
			robot.wheels.set_velocity(MAX_VELOCITY, -MAX_VELOCITY)
			robot.leds.set_all_colors("green")
		else
			log("ostacle to the right")
			robot.wheels.set_velocity(-MAX_VELOCITY, MAX_VELOCITY)
			robot.leds.set_all_colors("red")
		end
	else
		-- random walk
		if n_steps % MOVE_STEPS == 0 then
			left_v = robot.random.uniform(0,MAX_VELOCITY)
			right_v = robot.random.uniform(0,MAX_VELOCITY)
		end
		robot.wheels.set_velocity(left_v,right_v)
		robot.leds.set_all_colors("black")
	end
	
	
end


function max(list)
    if #list == 0 then
        return nil
    end

    local max_value = list[1]
    local index = 1
    for i = 2, #list do
        if list[i] > max_value then
            max_value = list[i]
            index = i
        end
    end
    return max_value, index 
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
