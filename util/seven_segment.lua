_seven_seg_map = {
	[-1] = 80,
	[0] = 6,
	[1] = 91,
	[2] = 79,
	[3] = 102,
	[4] = 109,
}

function writeSevenSegment(start_channel, value)
	val = _seven_seg_map[value]
	if val == nil then
		val = 0
	end
	for i = 1,7 do
		valmod = val % (2^i)
		output.setBool(i + start_channel - 1, valmod >= (2^i)/2 and valmod <= (2^i))
	end
end
