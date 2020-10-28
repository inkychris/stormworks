-- source https://gist.github.com/bradley219/5373998

-- clamp

PID = {}
function PID:Create()
	local this = {
		kP = 0,
		kI = 0,
		kD = 0,
		clamp_output = false,
		min = 0,
		max = 1,
		clamp_integral = false,
		integral_min = -1,
		integral_max = 1,
		_previous_err = 0,
		_integral = 0
	}

	function this:process(setpoint, pv)
		local err = setpoint - pv
		local p_out = self.kP * err
		self._integral = self._integral + err / 60
		if self.clamp_integral then
			self._integral = clamp(self._integral, self.integral_min, self.integral_max)
		end
		local i_out = self.kI * self._integral
		local d_out = self.kD * ((err - self._previous_err) * 60)
		local result = p_out + i_out + d_out
		if self.clamp_output then
			result = clamp(result, self.min, self.max)
		end
		self._previous_err = err
		return result
	end

	return this
end
