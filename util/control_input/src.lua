function CtlInput(chan,sensitivity)
	local t = {raw=0,_v=0}
	function t:tick() self.raw=input.getNumber(chan) end
	function t:smooth()
		self._v=self._v+(self.raw-self._v)*(sensitivity/100)^2
		return self._v
	end
	function t:is_active() return math.abs(self.raw) > 0.9 end
	return t
end
