
ignition_rps = property.getNumber("Ignition RPS")
max_gear = property.getNumber("Max Gear")
max_engine_rps = property.getNumber("Max Engine RPS")
min_engine_rps = property.getNumber("Minimum RPS")
shift_up_rps = property.getNumber("Shift-up RPS")
min_shift_down_rps = property.getNumber("Min Shift-down RPS")
slow_shift_down_rps = property.getNumber("Slow Shift-down RPS")
shift_latency = property.getNumber("Shift Latency (ticks)")

NumberValue = {}
function NumberValue:Create()
	local this = {
		previous_value = 0,
		current_value = 0,
		incrementing = false,
		decrementing = false,
	}

	function this:set(value)
		self.previous_value = self.current_value
		self.current_value = value
		if value > self.previous_value then
			self.incrementing = true
			self.decrementing = false
		elseif value < self.previous_value then
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

	return this
end

clutch = {
	value = 0,
	min_input_rps = min_engine_rps * 1.1,
	threshold = property.getNumber("Clutch Threshold"),
	increment = property.getNumber("Clutch Engagement Increment"),
}

function clutch:update()
	output.setNumber(1, self.value)
end

function clutch:clamp_value()
	if self.value > 1 then
		self.value = 1
	elseif self.value < 0 then
		self.value = 0
	end
end

function clutch:disengage()
	self.value = 0
end

function clutch:adjust(input_rps, target_rate)
	below_min = input_rps.current_value < self.min_input_rps
	if target_rate:is_incrementing() then
		if below_min then
			self.value = self.value - (self.increment / (0.000001 + math.abs(input_rps.current_value - self.min_input_rps)))
		else
			self.value = self.value + (math.abs(input_rps.current_value - self.min_input_rps) * self.increment)
		end

	elseif target_rate:is_decrementing() then
		if below_min then
			self:disengage()
		end
	end
	self:clamp_value()
end

engine_rps = NumberValue:Create()
target_rate = NumberValue:Create()
gear = 0

function set_gear(value)
	gear = value
	if gear < -1 then
		gear = -1
	elseif gear > max_gear then
		gear = max_gear
	end
	output.setNumber(2, gear)
end

ticks_since_last_gear_shift = 0
previous_reverse = false

function onTick()
	enabled = input.getBool(1)
	reverse = input.getBool(2)
	engine_rps:set(input.getNumber(1))
	target_rate:set(input.getNumber(2))

	if enabled and (engine_rps.current_value < ignition_rps) then
		clutch:disengage()
		output.setBool(1, true)
	else
		output.setBool(1, false)
	end

	if not enabled then
		clutch:disengage()
	end

	if reverse ~= previous_reverse then
		clutch:disengage()
		target_rate:set(0)
		gear = 0
	end

	clutch:adjust(engine_rps, target_rate)
	clutch:update()

	if (ticks_since_last_gear_shift > shift_latency) and 
			target_rate:is_incrementing() and 
			engine_rps:is_incrementing() and 
			(engine_rps.current_value > shift_up_rps) then
		ticks_since_last_gear_shift = 0
		set_gear(gear + 1)
	elseif (gear > 0) and
		(ticks_since_last_gear_shift > shift_latency) and
			(
				(engine_rps.current_value < min_shift_down_rps) or
				(engine_rps.current_value < slow_shift_down_rps and target_rate:is_decrementing())
			) then
		ticks_since_last_gear_shift = 0
		set_gear(gear - 1)
	end

	ticks_since_last_gear_shift = ticks_since_last_gear_shift + 1
	previous_reverse = reverse
end
