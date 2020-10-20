-- source https://gist.github.com/bradley219/5373998
PID = {}
function PID:Create()
	local this = {
		interval = 1/60,
		kP = 0,
		kI = 0,
        kD = 0,
        min = 0,
        max = 1,
        clamp = false,
        _previous_err = 0,
        _integral = 0
	}

    function this:process(setpoint, pv)
        err = setpoint - pv
        p_out = self.kP * err
        self._integral = self._integral + err * self.interval
        i_out = self.kI * self._integral
        d_out = self.kD * ((err - self._previous_err) / self.interval)
        result = p_out + i_out + d_out
        if self.clamp and (result > self.max) then
            result = self.max
        elseif self.clamp and (result < self.min) then
            result = self.min
        end
        self._previous_err = err
        return result
	end
	return this
end
