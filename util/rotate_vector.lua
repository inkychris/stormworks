function rotate_vector(v, angle)
	local cos = math.cos(angle)
	local sin = math.sin(angle)
	return {x=(v.x*cos)-(v.y*sin), y=(v.x*sin)+(v.y*cos)}
end
