
-- Put your global variables here
MAX_VELOCITY = 15
PROXIMITY_THRESHOLD = 0.1
MAXRANGE = 30

W = 0.1
S = 0.01
PSmax = 0.99
PWmin = 0.005
alpha = 0.1
beta = 0.05

stopped = false

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
	if stopped then
		robot.range_and_bearing.set_data(1,1)
	else 
		robot.range_and_bearing.set_data(1,0)
	end

	N = CountRAB()
	Ps = math.min(PSmax, S + alpha*N)
	Pw = math.max(PWmin, W - beta*N)
	
	t = robot.random.uniform()
	if stopped then
		if t <= Pw then
			goAway()
			stopped = false
		end
    else
    	if t <= Ps then
			stop()
			stopped = true
		else 
			goAway()
		end
    end
    
	
end

-- Count the number of stopped robots sensed close to the robot
function CountRAB()
	number_robot_sensed = 0
	for i = 1, #robot.range_and_bearing do
		-- for each robot seen, check if it is close enough.
		if robot.range_and_bearing[i].range < MAXRANGE and
			robot.range_and_bearing[i].data[1]==1 then
			number_robot_sensed = number_robot_sensed + 1
		end
	end
	return number_robot_sensed
end

function goAway()
		-- check obstable
	sensors = {3, 2, 1, 24, 23, 22}
    avoid_obstacle = false
    for i = 1, #sensors do
		index = sensors[i]
		if robot.proximity[index].value > PROXIMITY_THRESHOLD then
			avoid_obstacle = true
			break
		end
	end
    
    if avoid_obstacle then
        robot.wheels.set_velocity(MAX_VELOCITY, -MAX_VELOCITY)   -- Giro immediato in senso orario o antiorario
        robot.leds.set_all_colors("red") -- Indica che è in evasione ostacolo
    else
    	local forward_velocity = math.random(5, MAX_VELOCITY)
        local turn_velocity = math.random(-MAX_VELOCITY, MAX_VELOCITY)
        robot.wheels.set_velocity(forward_velocity + turn_velocity, forward_velocity - turn_velocity)
        robot.leds.set_all_colors("green") -- Movimento normale
    end
end

function stop()
	robot.wheels.set_velocity(0,0)
	robot.leds.set_all_colors("black")
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
