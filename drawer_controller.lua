Toggle = {}

function Toggle:Create()
	local this = {
		_previous = false,
		value = false,
	}

	function this:process(val)
		if val and not self._previous then
			self.value = not self.value
		end
		self._previous = val
	end

	return this
end

drawer_count = 4
drawer_speed = 0.3
drawers = {}

for i = 1,drawer_count do
	drawers[i] = Toggle:Create()
end

function onTick()
	for i = 1,drawer_count do
		drawers[i]:process(input.getBool(i))
		if drawers[i].value then
			output.setNumber(i, drawer_speed)
			for j = 1,drawer_count do
				if i ~= j then
					drawers[j].value = false
				end
			end
		else
			output.setNumber(i, -drawer_speed)
		end
	end
end
