function clamp(value, min, max)
	if value > max then
		value = max
	elseif value < min then
		value = min
	end
	return value
end
