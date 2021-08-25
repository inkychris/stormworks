function clamp(v,min,max)
	if v>max then v=max
	elseif v<min then v=min end
	return v
end
