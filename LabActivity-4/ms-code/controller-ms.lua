-- import vector
local vector = require "vector"

MAX_VELOCITY = 15
PRIORITY_LIGHT = 1.5
PRIORITY_OBSTACLE = 2.0

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	robot.wheels.set_velocity(MAX_VELOCITY,MAX_VELOCITY)
	L = robot.wheels.axis_length
	robot.leds.set_all_colors("black")
end


--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	
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
	
	-- priority for light
	light_vector.length = math.min(PRIORITY_LIGHT * light_vector.length, 1.0)
	--light_vector.length = PRIORITY_LIGHT * light_vector.length
	
	-- schema for the obstacle
	obstacle_vector = {length = 0.0, angle = 0.0}
	
	for i=1, #robot.proximity do
		sensor = robot.proximity[i]
		-- take only sensor 5,4,3,2,1,24,23,22,21,20
		if math.abs(sensor.angle) < 1.2 then
			log(i)
			obstacle_vector.length = obstacle_vector.length + sensor.value
			obstacle_vector.angle = obstacle_vector.angle + sensor.angle * sensor.value
		end
	end
	
	if obstacle_vector.length > 0 then
		obstacle_vector.angle = obstacle_vector.angle / obstacle_vector.length
		-- priority for obstacle avoidance
		obstacle_vector.length = -PRIORITY_OBSTACLE * obstacle_vector.length	
	end
	
	-- sum	
	result = vector.vec2_polar_sum(light_vector, obstacle_vector)
	
	--se ci sono ostacoli rallenta
	log(obstacle_vector.length)
	if obstacle_vector.length < 0 then
    local slowdown = math.max(0.3, 1.0 + obstacle_vector.length)  -- tra 0.3 e 1.0
    	result.length = result.length * slowdown
    end
	
	-- matrix for calculate wheels velocity
	v = result.length * MAX_VELOCITY
	w = result.angle / 2
	
	vl = v - L/2 * w
	vr = v + L/2 * w
	
	-- near light, stop
	if max_light > 0.55 then
		vl = 0
		vr = 0
		robot.leds.set_all_colors("green")
	else
       	robot.leds.set_all_colors("yellow")
    end
	
	robot.wheels.set_velocity(vl, vr)
	
end
	


--[[ This function is executed every time you press the 'reset'
     button in the GUI. It is supposed to restore the state
     of the controller to whatever it was right after init() was
     called. The state of sensors and actuators is reset
     automatically by ARGoS. ]]
function reset()
	robot.wheels.set_velocity(MAX_VELOCITY,MAX_VELOCITY)
	robot.leds.set_all_colors("black")
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
