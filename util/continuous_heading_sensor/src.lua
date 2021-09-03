function Heading()
	local this = {
		_r = 0,
		_h = 0
	}
	function this:update(h)
		if h<-0.25 and this._h>0.25 then
			this._r = this._r+1
		elseif h>0.25 and this._h<-0.25 then
			this._r = this._r-1
		end
		this._h = h
	end
	function this:rads()
		return math.pi+(this._h+this._r-0.5)*2*math.pi
	end
	return this
end
