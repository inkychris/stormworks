-- clamp

clutch = {}
function clutch:Create(min_rps, increment)
	local this = {
		value = 0,
		min_rps = min_rps,
		increment = increment,
	}

	function clutch:reset()
		self.value = 0
	end

	function clutch:adjust(input_rps, target_rate)
		local below_min = input_rps.current_value < self.min_rps
		if target_rate:is_incrementing() then
			local increment_value = math.abs(input_rps.current_value - self.min_rps) * self.increment
			if below_min then
				self.value = self.value - increment_value
			else
				self.value = self.value + increment_value
			end
		elseif target_rate:is_decrementing() then
			if below_min then
				self:reset()
			end
		end
		self.value = clamp(self.value, 0 , 1)
	end

	return this
end
