function Smooth(sensitivity)
	local t = {_v=0}
	function t:smooth(v)
		self._v=self._v+(v-self._v)*(sensitivity/100)^2
		return self._v
	end
	return t
end
