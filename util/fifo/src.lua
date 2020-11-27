function FIFO(size)
	local this = {
		data = {},
		size = size,
		i = 0}
	function this:push(val)
		self.i = self.i%self.size +1
		self.data[self.i] = val
	end
	function this:set_all(val)
		for i=1,self.size do self:push(val) end
	end
	function this:get(i)
		if i < 0 then return self:get(self.size+i+1) end
		return self.data[(self.i+i-1)%self.size +1]
	end
	return this
end
