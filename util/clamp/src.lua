function clamp(val,min,max)
	if val>max then val=max
	elseif val<min then val=min end
	return val
end

function __scale_cos(val,xcross,other)
	return xcross+(other-xcross)*((1-math.cos(math.pi*val))/2)
end

function smooth_clamp(val,min,max)
	val = clamp(val,min,max)
	if val>0 and val<max then val=__scale_cos(val,0,max)
	elseif val<0 and val>min then val=__scale_cos(val,0,min) end
	return val
end
