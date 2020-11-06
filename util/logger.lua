Logger = {}
function Logger:Create()
	local this = {
		_tick = 0,
		port = 8000,
		packet_length = 16,
		_data = {},
	}
	function this:tick()
		self._tick = self._tick + 1
	end
	function this:log(value)
		self._data[#self._data + 1] = string.format("%s:%s", tostring(self._tick), tostring(value))
		if #self._data > self.packet_length then
			self:send()
		end
	end
	function this:reset()
		self:send()
		if #self._data > 0 then self._data = {} end
	end
	function this:send()
		if #self._data == 0 then return end
    	async.httpGet(self.port, string.format("/log?packet=%s", table.concat(self._data, "|")))
		self._data = {}
	end
	return this
end
