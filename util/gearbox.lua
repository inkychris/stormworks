-- clamp

Gearbox = {}
function Gearbox:Create(max_gear)
	local this = {
		gear = 0,
		_previous_gear = 0,
		max_gear = max_gear,
		anti_repeat_ticks = 80,
		_shift_timer = nil,
		allow_upshift = true,
		shift_up_rps = 10,
		min_rps = 4,
		shift_down_rps = 6,
	}

	function this:tick()
		if self._shift_timer then
			self._shift_timer = self._shift_timer + 1
			if self._shift_timer > self.anti_repeat_ticks then
				self._shift_timer = nil
			end
		end
	end

	function this:_shift(val)
		self._previous_gear = self.gear
		self.gear = clamp(self.gear + val, 0, self.max_gear)
		if self._previous_gear ~= self.gear then
			self._shift_timer = 0
		end
	end

	function this:reset() self:shift(-self.max_gear) end
	function this:shift_up() self:_shift(1) end
	function this:shift_down() self:_shift(-1) end

	function this:process(input_rps, target_rate)
		if self._shift_timer then return self.gear end

		if self.allow_upshift and target_rate:is_incrementing() and (input_rps.current > self.shift_up_rps) then
			self:shift_up()
		elseif
		(input_rps.current < self.min_rps) or
		(target_rate:is_decrementing() and (input_rps.current < self.shift_down_rps)) then
			self:shift_down()
		end
		return self.gear
	end

	return this
end
