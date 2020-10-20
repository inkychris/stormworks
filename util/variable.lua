Variable = {}
function Variable:Create()
	local this = {
		previous = 0,
		current = 0,
		incrementing = false,
		decrementing = false,
	}

	function this:set(value)
		self.previous = self.current
		self.current = value
		if value > self.previous then
			self.incrementing = true
			self.decrementing = false
		elseif value < self.previous then
			self.incrementing = false
			self.decrementing = true
		end
	end

	function this:is_incrementing()
		return self.incrementing and not self.decrementing
	end

	function this:is_decrementing()
		return self.decrementing and not self.incrementing
	end

	function this:offset(value)
		self:set(self.current + value)
	end

	return this
end

-- minified

Variable={}function Variable:Create()local a={previous=0,current=0,incrementing=false,decrementing=false}function a:set(b)self.previous=self.current;self.current=b;if b>self.previous then self.incrementing=true;self.decrementing=false elseif b<self.previous then self.incrementing=false;self.decrementing=true end end;function a:is_incrementing()return self.incrementing and not self.decrementing end;function a:is_decrementing()return self.decrementing and not self.incrementing end;function a:offset(b)self:set(self.current+b)end;return a end
