-- Gearbox
-- Variable

gearbox = Gearbox:Create(property.getNumber("Max Gear"))
gearbox.min_rps = property.getNumber("Min Engine RPS")
gearbox.shift_up_rps = property.getNumber("Shift-up RPS")
gearbox.shift_down_rps = property.getNumber("Shift-down RPS")
target_rate = Variable:Create()
engine_rps = Variable:Create()

function onTick()
	local enabled = input.getBool(1)
	local reverse = input.getBool(2)
	local clutch = input.getNumber(3)
	engine_rps:set(input.getNumber(1))
	target_rate:set(input.getNumber(2))
	gearbox:tick()
	gearbox.allow_upshift = clutch == 1

	if enabled and reverse then
		output.setNumber(1, -1)
	elseif enabled then
		output.setNumber(1, gearbox:process(engine_rps, target_rate))
	else
		output.setNumber(1, 0)
	end
end
