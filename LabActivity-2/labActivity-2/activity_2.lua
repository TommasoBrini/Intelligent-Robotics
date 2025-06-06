-- Put your global variables here

MOVE_STEPS = 15
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 1.5
PROXIMITY_THRESHOLD = 0.1
LIGHT_RIGHT = 1
LIGHT_LEFT = 0

pos_light = LIGHT_LEFT


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
	-- Check obstacles
	sensors = {3, 2, 1, 24, 23, 22}
	obstacle_detected = false
	for i = 1, #sensors do
		index = sensors[i]
		if robot.proximity[index].value > PROXIMITY_THRESHOLD then
			obstacle_detected = true
			break
		end
	end
	
	if obstacle_detected then
		if pos_light == LIGHT_RIGHT then
			robot.wheels.set_velocity(MAX_VELOCITY, - MAX_VELOCITY)
		else
			robot.wheels.set_velocity(-MAX_VELOCITY, MAX_VELOCITY)
		end
		robot.leds.set_all_colors("red")  -- Obstacle detected
	else
		findLights()
	end
		
end

function findLights()
	-- Read the light sensors
    light_sensors = {}
    for i = 1, #robot.light do
        light_sensors[i] = robot.light[i].value
    end
    
	-- Choose the direction with the most light
    left_light = light_sensors[5] + light_sensors[6] + light_sensors[7] + light_sensors[8] -- Left side
    front_light = light_sensors[23] + light_sensors[24] + light_sensors[1] + light_sensors[2] -- Front side
    right_light = light_sensors[17] + light_sensors[18] + light_sensors[19] + light_sensors[20] -- Right side
    
    if front_light > left_light and front_light > right_light then
        -- Move forward if the front has the most light
        robot.wheels.set_velocity(MAX_VELOCITY, MAX_VELOCITY)
        robot.leds.set_all_colors("yellow") -- Light detected in front
    elseif left_light > front_light and left_light > right_light then
        -- Turn left if the left side has the most light
        robot.wheels.set_velocity(-MAX_VELOCITY, MAX_VELOCITY)
        pos_light = LIGHT_LEFT
        robot.leds.set_all_colors("blue") -- Light detected on the left
    elseif right_light > front_light and right_light > left_light then
        -- Turn right if the right side has the most light
        robot.wheels.set_velocity(MAX_VELOCITY, -MAX_VELOCITY)
        pos_light = LIGHT_RIGHT
        robot.leds.set_all_colors("green") -- Light detected on the right
    else
        -- Random walk
        left_v = robot.random.uniform(0, MAX_VELOCITY)
        right_v = robot.random.uniform(0, MAX_VELOCITY)
        robot.wheels.set_velocity(left_v, right_v)
        robot.leds.set_all_colors("black")
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
