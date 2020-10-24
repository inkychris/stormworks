-- clamp

Clutch = {}
function Clutch:Create(min_rps, increment)
	local this = {
		value = 0,
		min_rps = min_rps,
		increment = increment,
	}

	function this:reset()
		self.value = 0
	end

	function this:process(input_rps, target_rate)
		local below_min = input_rps.current < self.min_rps
		if target_rate:is_incrementing() then
			local increment = math.abs(input_rps.current - self.min_rps) * self.increment
			if below_min then
				self.value = self.value - increment
			else
				self.value = self.value + increment
			end
		elseif target_rate:is_decrementing() then
			if below_min then
				self:reset()
			end
		end
		self.value = clamp(self.value, 0 , 1)
		return self.value
	end

	return this
end
