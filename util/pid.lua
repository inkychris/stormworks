PID = {}
function PID:Create(t)
	local this = {
		kP = t.kP or 1,
		kI = t.kI or 0,
		kD = t.kD or 0,
		min = t.min or 0,
		max = t.max or 1,
		_previous_err = 0,
		_integral = 0
	}
	function this:process(setpoint, pv)
		local err = setpoint - pv
		local p_out = self.kP * err
		self._integral = self._integral + (err / 60)
		local i_out = self.kI * self._integral
		local d_out = self.kD * (err - self._previous_err) * 60
		local result = p_out + i_out - d_out
		if result > self.max then
			self._integral = self._integral - (err / 60)
			result = self.max
		elseif result < self.min then
			self._integral = self._integral - (err / 60)
			result = self.min
		end
		self._previous_err = err
		return result
	end
	return this
end
