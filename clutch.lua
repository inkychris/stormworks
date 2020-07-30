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
    min_input_rps = property.getNumber("Minimum RPS") * 1.1,
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
    if (target_rate:is_decrementing() and (input_rps.current_value < self.min_input_rps)) then
        self:disengage()
    elseif target_rate:is_incrementing() then
        if (input_rps:is_incrementing() and (input_rps.current_value > self.min_input_rps)) then
            self.value = self.value + (math.abs(input_rps.current_value - self.min_input_rps) * self.increment)
            if self.value < self.threshold then
                self.value = self.threshold
            end
        elseif (input_rps:is_decrementing() or (input_rps.current_value < self.min_input_rps)) then
            self.value = self.value - (self.increment / (0.000001 + math.abs(input_rps.current_value - self.min_input_rps)))
        end
    end
    self:clamp_value()
end

engine_rps = NumberValue:Create()
target_rate = NumberValue:Create()
ignition_rps = property.getNumber("Ignition RPS")

function onTick()
    enabled = input.getBool(1)
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

    clutch:adjust(engine_rps, target_rate)
    clutch:update()
end
