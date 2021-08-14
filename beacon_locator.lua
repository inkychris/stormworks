function drawPointer(x,y,s,r,...)
    local a = ...
    a = (a or 30)*math.pi/360
    x = x+s/2*math.sin(r)
    y = y-s/2*math.cos(r)
    screen.drawTriangleF(x,y, x-s*math.sin(r+a), y+s*math.cos(r+a), x-s*math.sin(r-a), y+s*math.cos(r-a))
end

function FIFO(size)
	local this = {
		data = {},
		size = size,
		i = 0}
	function this:push(val)
		self.i = self.i%self.size +1
		self.data[self.i] = val
	end
	function this:set_all(val)
		for i=1,self.size do self:push(val) end
	end
	function this:get(i)
		if i < 0 then return self:get(self.size+i+1) end
		return self.data[(self.i+i-1)%self.size +1]
	end
	return this
end

function Position(x,y,r)
	return {x=x or 0,y=y or 0,r=r or 0}
end

pos = Position()
pos_history = FIFO(3)

function init_pos_history(t)
	for i = 1,pos_history.size do
		pos_history:push(Position(t.x,t.y,t.r))
	end
end
init_pos_history(pos)

function mapToScreen(world_pos)
	local x,y = map.mapToScreen(pos.x, pos.y, zoom, 160, 96, world_pos.x, world_pos.y)
	return Position(x,y,world_pos.r)
end

screen_pos = Position()
screen_pos_old = Position()

beacon_history = FIFO(5)
beacon_timer = 0
beacon_counter = 0

prev_point1 = Position()
prev_point2 = Position()
point = Position()

heading = 0
zoom = 1
function onTick()
	pos.x = input.getNumber(2)
	pos.y = input.getNumber(3)

	if pos.x == 0 then init_pos_history(pos) end

	heading = -input.getNumber(1) * math.pi * 2
	beacon_timer = beacon_timer + 1

	-- Distance calc
	if input.getBool(1) then
		beacon_history:push(beacon_timer)
		beacon_timer = 0
		beacon_counter = beacon_counter + 1
	end

	if beacon_counter == 5 then
		pos.r = 0
		for i =1,beacon_history.size do pos.r = pos.r + beacon_history:get(i) end
		pos.r = 50 * pos.r/beacon_history.size - 250
		beacon_counter = 0

		-- Circle Intersection
		pos_old = pos_history:get(1)
		pos_delta = Position(pos.x-pos_old.x, pos.y-pos_old.y)
		d=math.sqrt((pos_delta.x)^2 + (pos_delta.y)^2)

		a=(pos_old.r^2-pos.r^2+d^2)/(2*d)
		h=math.sqrt(pos_old.r^2 - a^2)
		x2=pos_old.x+a*(pos_delta.x)/d
		y2=pos_old.y+a*(pos_delta.y)/d

		point1 = Position(x2+h*(pos_delta.y)/d, y2-h*(pos_delta.x)/d)
		point2 = Position(x2-h*(pos_delta.y)/d, y2+h*(pos_delta.x)/d)

		if ((point1.x - prev_point1.x)^2 + (point1.y - prev_point1.y)^2) < ((point2.x - prev_point2.x)^2 + (point2.y - prev_point2.y)^2) then
			point = point1
		else
			point = point2
		end

		prev_point1 = Position(point1.x, point1.y)
		prev_point2 = Position(point2.x, point2.y)

		point = mapToScreen(point)
		screen_pos = mapToScreen(pos)
		screen_pos_old = mapToScreen(pos_old)
	end

	prev_pos = pos_history:get(-2)
	if (math.sqrt((pos.x-prev_pos.x)^2 + (pos.y-prev_pos.y)^2)) > (pos.r / 10) + 50 then
		pos_history:push(Position(pos.x, pos.y, pos.r))
	end

	if input.getBool(2) then
		zoom = zoom/1.02
	elseif input.getBool(3) then
		zoom = zoom*1.02
	end

	output.setNumber(1, pos.r)
	output.setNumber(2, beacon_history:get(1))
end

function onDraw()
	w = screen.getWidth()
	h = screen.getHeight()
	screen.drawMap(pos.x, pos.y, zoom)

	screen.setColor(0, 255, 0)			
	screen.drawCircle(screen_pos.x, screen_pos.y, (screen_pos.r/(zoom*6.2)))

	screen.setColor(255, 0, 0)			
	screen.drawCircle(screen_pos_old.x, screen_pos_old.y, (screen_pos_old.r/(zoom*6.2)))

	-- Direction Pointer
	screen.setColor(255, 0, 0)
	drawPointer(w/2, h/2,10,heading)

	--Location x
	screen.setColor(255, 255, 255)
	screen.drawLine(point.x-3, point.y-3, point.x+3, point.y+3)
	screen.drawLine(point.x+3, point.y-3, point.x-3, point.y+3)
	screen.setColor(255, 0, 0)
	screen.drawLine(w/2, h/2, point.x, point.y)
end
