function Logger(t)
	local this = {
		_i = 0,
		port = t.port or 8000,
		packet_size = t.packet_size or 16,
		data = {},
	}
	function this:tick()
		self._i = self._i + 1
	end
	function this:log(a)
		self.data[#self.data + 1] = string.format("%s:%s", tostring(self._i), tostring(a))
		if #self.data > self.packet_size then
			self:send()
		end
	end
	function this:reset()
		self:send()
		if #self.data > 0 then self.data = {} end
	end
	function this:send()
		if #self.data == 0 then return end
    	async.httpGet(self.port, string.format("/log?packet=%s", table.concat(self.data, "|")))
		self.data = {}
	end
	return this
end
