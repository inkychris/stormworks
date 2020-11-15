FIR = {}
function FIR:Create(coefs)
	local this = {
        size = #coefs,
        _coefs = coefs,
		_buf = {},
		_i = 1,
	}
	for i=1,this.size do this._buf[i] = 0 end
	local _INT16_MAX = 2^16
	function this:process(value)
		self._buf[self._i] = value
		local result = 0
		local index = self._i
		for i = 1,self.size do
			result = result + self._coefs[i] * self._buf[index]
			index = index - 1
			if index < 1 then index = self.size end
		end
		self._i = self._i + 1
		if self._i > self.size then self._i = 1 end
		return result / _INT16_MAX
	end
	return this
end
