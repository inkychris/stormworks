Colour = {
	bg = {21,21,21},
	sep = {40,40,40},
	select1 = {30,30,30},
	select2 = {60,60,60},
	fore = {80,80,80},
	g = {2,82,0},
	r = {86,9,0},
	y = {100,62,0}
}

function setColour(val)
	screen.setColor(table.unpack(val))
end

function drawRectF(col, t)
	setColour(col)
	for i=1,#t do
		screen.drawRectF(table.unpack(t[i]))
	end
end

function void() end

ButtonMode = {On1=1,On2=2,Off=3}
function Button(x1,y1,x2,y2)
	local this = {
		x1=x1,y1=y1,x2=x2,y2=y2,
		w=x2-x1,h=y2-y1,
		on={false,false},
		prev={false,false},
		toggle={false,false},
		draw=void,tick=void}
	function this:reset()
		for i=1,2 do self.on[i] = false end
	end
	function this:process()
		for i=1,2 do
			local val = input.getBool(i)
			if val then
				local x,y = input.getNumber(2*i+1), input.getNumber(2*i+2)
				if self.x1 <= x and x < self.x2 and self.y1 <= y and y < self.y2 then
					if not self.toggle[i] then self.on[i] = true
					elseif not self.prev[i] then
						self.on[i] = not self.on[i]
					end
				end
			elseif not self.toggle[i] then self.on[i] = false end
			self.prev[i] = val
		end
		self:tick()
	end
	function this:pulse(i)
		return self.on[i] and not self.prev[i]
	end
	return this
end

button = {
	pgL = Button(0,0,9,9),
	pgR = Button(55,0,64,9),
}

function button.pgL:draw()
	if self.on[1] then
		setColour(Colour.select1)
		screen.drawRectF(self.x1, self.y1, self.w, self.h)
	end
	setColour(Colour.fore)
	screen.drawTriangleF(self.x2-3,self.y1+2, self.x2-6,self.y1+5, self.x2-3,self.y1+8)
end

function button.pgR:draw()
	if self.on[1] then
		setColour(Colour.select1)
		screen.drawRectF(self.x1, self.y1, self.w, self.h)
	end
	setColour(Colour.fore)
	screen.drawTriangleF(self.x1+3,self.y1+2, self.x1+6,self.y1+5, self.x1+3,self.y1+8)
end

function drawHeading(txt)	
	setColour(Colour.fore)
	screen.drawTextBox(11,0,42,9,txt,0,0)
end

function drawCommon()
	setColour(Colour.bg)
	screen.drawClear()
	drawRectF(Colour.sep, {
		{9,0,2,9},
		{53,0,2,9},
		{0,9,64,2},
		{31,11,2,24},
		{0,35,64,2}
	})
	button.pgL:draw()
	button.pgR:draw()
end

function drawHome()
	drawHeading("anchor")
	drawRectF(Colour.sep, {{31,37,2,27}})
end

function drawFore()
	drawHeading("fore")
end

function drawAft()
	drawHeading("aft")
end
drawPage = drawHome
function button.pgR:tick()
	if not self:pulse() then return end
	if drawPage == drawHome then
		drawPage = drawFore
	elseif drawPage == drawFore then
		drawPage = drawAft
	else drawPage = drawHome end
end
function button.pgL:tick()
	if not self:pulse() then return end
	if drawPage == drawHome then
		drawPage = drawAft
	elseif drawPage == drawFore then
		drawPage = drawHome
	else drawPage = drawFore end
end

function onTick()
	button.pgL:process()
	button.pgR:process()
end

function onDraw()
	drawCommon()
	drawPage()
end
