
-- Put your global variables here
MAX_VELOCITY = 15
PROXIMITY_THRESHOLD = 0.1
MAXRANGE = 30

W = 0.1
S = 0.01
PSmax = 0.99
PWmin = 0.005
Ds = 0.3
Dw = 0.2
alpha = 0.1
beta = 0.05

stopped = false

--[[ This function is executed every time you press the 'execute'
     button ]]
function init()
	left_v = robot.random.uniform(0,MAX_VELOCITY)
	right_v = robot.random.uniform(0,MAX_VELOCITY)
	robot.wheels.set_velocity(left_v,right_v)
	robot.leds.set_all_colors("black")
end

--[[ This function is executed at each time step
     It must contain the logic of your controller ]]
function step()
	on_black_spot = isOnBlackSpot()
	N = CountRAB()
	
	Ps = math.min(PSmax, S + alpha*N + (on_black_spot and Ds or 0))
	Pw = math.max(PWmin, W - beta*N - (on_black_spot and Dw or 0))
	
	robot.range_and_bearing.set_data(1, stopped and 1 or 0)
	
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
    if detect_obstacle() then
        robot.wheels.set_velocity(MAX_VELOCITY, -MAX_VELOCITY)
        robot.leds.set_all_colors("red")
    else
    	local forward_velocity = robot.random.uniform(5, MAX_VELOCITY)
        local turn_velocity = robot.random.uniform(-MAX_VELOCITY, MAX_VELOCITY)
        robot.wheels.set_velocity(forward_velocity + turn_velocity, forward_velocity - turn_velocity)
        robot.leds.set_all_colors("green")
    end
end

function isOnBlackSpot()
    local g = robot.motor_ground
    return g[1].value < 0.2 and g[2].value < 0.2
end

function detect_obstacle()
	sensors = {3, 2, 1, 24, 23, 22}
    for _, i in pairs(sensors) do
		if robot.proximity[i].value > PROXIMITY_THRESHOLD then
			return true
		end
	end
	return false
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
	init()
end



--[[ This function is executed only once, when the robot is removed
     from the simulation ]]
function destroy()
   -- put your code here
end
