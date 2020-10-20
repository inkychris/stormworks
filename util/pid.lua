-- source https://gist.github.com/bradley219/5373998

-- clamp

PID = {}
function PID:Create()
	local this = {
		kP = 0,
		kI = 0,
		kD = 0,
		clamp_ouput = false,
		min = 0,
		max = 1,
		_previous_err = 0,
		_integral = 0
	}

	function this:process(setpoint, pv)
		err = setpoint - pv
		p_out = self.kP * err
		self._integral = self._integral + err / 60
		i_out = self.kI * self._integral
		d_out = self.kD * ((err - self._previous_err) * 60)
		result = p_out + i_out + d_out
		if self.clamp then
			result = clamp(result, self.min, self.max)
		end
		self._previous_err = err
		return result
	end

	return this
end
