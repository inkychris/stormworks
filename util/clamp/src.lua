function clamp(val,min,max)
	if val>max then val=max
	elseif val<min then val=min end
	return val
end
