FIFO = {}
function FIFO:Create(size)
	local this = {
		_data = {},
		size = size,
		_i = 1,
	}
	for i=1,size do this._data[i]=0 end
	function this:push(val)
		self._i = (self._i % self.size) + 1
		self._data[self._i] = val
	end
	function this:get(i)
		return self._data[(self._i+i-1) % self.size + 1]
	end
	function this:last() return self:get(self.size) end
	return this
end
