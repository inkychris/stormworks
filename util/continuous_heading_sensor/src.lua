function Heading()
	local this = {
		_r = 0,
		_h = {cur=0, prev=0}
	}
	function this:update(heading, angular_speed)
		if heading<0 and this._h.prev>0 and angular_speed<0 then
			this._r = this._r+1
		elseif heading>0 and this._h.prev<0 and angular_speed>0 then
			this._r = this._r-1
		end
		this._h.cur = heading
		this._h.prev = heading
	end
	function this:rads()
		return math.pi+(this._r+this._h.cur-0.5)*2*math.pi
	end
	return this
end
