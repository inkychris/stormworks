dofile "util/io_mock.lua"
dofile "util/input_smoothing/src.lua"


tests = {
	{input=0, expected_output={0, 0, 0, 0, 0}},
	{input=1, expected_output={0.250, 0.438, 0.578, 0.684, 0.763}},
	{input=0, expected_output={0.572, 0.429, 0.322, 0.241, 0.181}},
	{input=-1, expected_output={-0.114, -0.336, -0.502, -0.626, -0.720}},
	{input=1, expected_output={-0.290, 0.033, 0.274, 0.456, 0.592}},
	{input=0, expected_output={0.444, 0.333, 0.250, 0.187, 0.140}},
}

sensitivity = 50
axis = Smooth(sensitivity)
for col_index,collection in ipairs(tests) do
	for out_index,expected in ipairs(collection.expected_output) do
		local actual = axis:smooth(collection.input)
		assert(math.abs(actual - expected) < 0.001, string.format("expected value %f, got %f in test [%d,%d]",expected, actual, col_index, out_index))
	end
end
print("All assersions passed!")
