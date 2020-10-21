-- clamp

gearbox = {}
function gearbox:Create(max_gear)
	local this = {
		gear = 0,
		max_gear = max_gear,
		_anti_repeat_ticks = 120,
		_shift_timer = nil,
		shift_up_rps = 10,
		min_rps = 4,
		shift_down_rps = 6,
	}

	function this:tick()
		if self._shift_timer then
			self._shift_timer = self._shift_timer + 1
			if self._shift_timer > self._anti_repeat_ticks then
				self._shift_timer = nil
			end
		end
	end

	function this:reset()
		self.gear = 0
	end

	function this:shift_up()
		self.gear = clamp(self.gear + 1, 0, self.max_gear)
		self._shift_timer = 0
	end

	function this:shift_down()
		self.gear = clamp(self.gear - 1, 0, self.max_gear)
		self._shift_timer = 0
	end

	function this:process(input_rps, target_rate)
		if input_rps.current < self.min_rps then
			self:shift_down()
		elseif not self._shift_timer then
			if target_rate:is_increasing() and (input_rps.current > self.shift_up_rps) then
				self:shift_up()
			elseif target_rate:is_decreasing() and (input_rps.current < self.shift_down_rps) then
				self:shift_down()
			end
		end
		return self.gear
	end

	return this
end
