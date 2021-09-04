dofile "util/io_mock.lua"
dofile "util/control_input/src.lua"


tests = {
	{input=0, expected_output={0, 0, 0, 0, 0}},
	{input=1, expected_output={0.250, 0.438, 0.578, 0.684, 0.763}},
	{input=0, expected_output={0.572, 0.429, 0.322, 0.241, 0.181}},
	{input=-1, expected_output={-0.114, -0.336, -0.502, -0.626, -0.720}},
	{input=1, expected_output={-0.290, 0.033, 0.274, 0.456, 0.592}},
	{input=0, expected_output={0.444, 0.333, 0.250, 0.187, 0.140}},
}

channel = 1
sensitivity = 50
axis = CtlInput(channel, sensitivity)
for col_index,collection in ipairs(tests) do
	input.setNumber(channel, collection.input)
	for out_index,expected in ipairs(collection.expected_output) do
		axis:tick()
		local actual = axis:smooth()
		assert(math.abs(actual - expected) < 0.001, string.format("expected value %f, got %f in test [%d,%d]",expected, actual, col_index, out_index))
		if collection.input ~= 0 then
			assert(axis:is_active(), string.format("expected input %d to result in is_active=true, but got false", collection.input))
		end
	end
end
print("All assersions passed!")
