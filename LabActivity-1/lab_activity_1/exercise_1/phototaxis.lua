-- Put your global variables here

MOVE_STEPS = 50
MAX_VELOCITY = 10
LIGHT_THRESHOLD = 0.001

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
	
    -- Read the light sensors
    light_sensors = {} -- Initialize the light_sensors table
    total_light = 0
    for i = 1, #robot.light do
        light_sensors[i] = robot.light[i].value
        total_light = total_light + light_sensors[i]
    end
    
    -- Check which direction has the most light
    -- We will consider the robot's front, left, and right sensors
    left_light = light_sensors[5] + light_sensors[6] + light_sensors[7] + light_sensors[8] -- Left side
    front_light = light_sensors[23] + light_sensors[24] + light_sensors[1] + light_sensors[2] -- Front side
    right_light = light_sensors[17] + light_sensors[18] + light_sensors[19] + light_sensors[20] -- Right side
    
    -- Choose the direction with the most light
    if total_light < LIGHT_THRESHOLD then
        -- If no significant light is detected, move randomly
        -- Random walk
        if n_steps % MOVE_STEPS == 0 then
        	left_v = robot.random.uniform(0,MAX_VELOCITY)
        	right_v = robot.random.uniform(0,MAX_VELOCITY)
        end
        robot.wheels.set_velocity(left_v,right_v)
        robot.leds.set_all_colors("black") -- No light detected, random movement
        log("random")
    elseif front_light > left_light and front_light > right_light then
        -- Move forward if the front has the most light
        robot.wheels.set_velocity(MAX_VELOCITY,MAX_VELOCITY)
        robot.leds.set_all_colors("yellow") -- Light detected in front
        log("Front")
    elseif left_light > front_light and left_light > right_light then
        -- Turn left if the left side has the most light
        robot.wheels.set_velocity(-MAX_VELOCITY, MAX_VELOCITY)
        robot.leds.set_all_colors("blue") -- Light detected on the left
        log("left")
    elseif right_light > front_light and right_light > left_light then
        -- Turn right if the right side has the most light
        robot.wheels.set_velocity(MAX_VELOCITY, -MAX_VELOCITY)
        robot.leds.set_all_colors("green") -- Light detected on the right
        log("right")
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
