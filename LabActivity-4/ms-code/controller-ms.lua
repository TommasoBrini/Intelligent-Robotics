-- import vector
local vector = require "vector"


-- Put your global variables here


MOVE_STEPS = 15
MAX_VELOCITY = 15



--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	robot.wheels.set_velocity(MAX_VELOCITY,MAX_VELOCITY)
	L = robot.wheels.axis_length
	n_steps = 0
	robot.leds.set_all_colors("black")
end


--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	n_steps = n_steps + 1
	
	-- schema for the light
	light_vector = {length = 0.0, angle = 0.0}
	
	max_light = 0
	
	for i=1, #robot.light do
		sensor = robot.light[i]
		if sensor.value > max_light then
			max_light = sensor.value
			light_vector.length = 1 - sensor.value
			light_vector.angle = sensor.angle
		end
	end
	
	-- schema for the obstacle
	obstacle_vector = {length = 0.0, angle = 0.0}
	
	for i=1, #robot.proximity do
		sensor = robot.proximity[i]
		obstacle_vector.length = obstacle_vector.length + sensor.value
		obstacle_vector.angle = obstacle_vector.angle + sensor.angle * sensor.value
	end
	
	if obstacle_vector.length > 0 then
		obstacle_vector.angle = obstacle_vector.angle / obstacle_vector.length
		obstacle_vector.length = - obstacle_vector.length
	end
	
	-- sum
	result = vector.vec2_polar_sum(light_vector, obstacle_vector)
	
	-- matrix for calculate wheels velocity
	v = result.length * MAX_VELOCITY
	w = result.angle / 2
	
	vl = v - L/2 * w
	vr = v + L/2 * w
	
	robot.wheels.set_velocity(vl, vr)
	
end
	


--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	robot.wheels.set_velocity(MAX_VELOCITY,MAX_VELOCITY)
	L = robot.wheels.axis_length
	n_steps = 0
	robot.leds.set_all_colors("black")
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
