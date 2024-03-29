function PID(t)
	local this={
		kP=t.kP or 1,
		kI=t.kI or 0,
		kD=t.kD or 0,
		min=t.min or 0,
		max=t.max or 1,
		offset=t.offset or 0,
		_err=0,
		_integral=0
	}
	function this:reset()
		self._err=0
		self._integral=0
	end
	function this:process(setpoint, pv)
		local err=setpoint-pv
		local p_out=self.kP*err
		self._integral=self._integral+(err/60)
		local i_out=self.kI*self._integral
		local d_out=self.kD*(err-self._err)*60
		local r=p_out+i_out+d_out+self.offset
		if r>self.max then
			self._integral=self._integral-(err/60)
			r=self.max
		elseif r<self.min then
			self._integral=self._integral-(err/60)
			r=self.min
		end
		self._err=err
		return r
	end
	return this
end
