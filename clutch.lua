clutch = {
    value = 0,
    threshold = property.getNumber("Clutch Threshold")
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
	self:update()
end

function clutch:increase(value)
    self.value = self.value + value
    if self.value < self.threshold then
        self.value = self.threshold
    end
    self:clamp_value()
    self:update()
end

function clutch:decrease(value)
    self.value = self.value - value
    if self.value < self.threshold then
        self.value = 0
    end
    self:clamp_value()
    self:update()
end

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

engine_rps = NumberValue:Create()
clutch_rps = NumberValue:Create()
target_rate = NumberValue:Create()
min_engine_rps = property.getNumber("Minimum RPS")
clutch_bite_rps = property.getNumber("Clutch Bitepoint RPS")
ignition_rps = property.getNumber("Ignition RPS")
clutch_engagement_p_gain = property.getNumber("Clutch Engagement P Gain")
clutch_disengagement_p_gain = property.getNumber("Clutch Disengagement P Gain")

function onTick()
    enabled = input.getBool(1)
    engine_rps:set(input.getNumber(1))
    target_rate:set(input.getNumber(2))

    if enabled and (engine_rps.current_value < ignition_rps) then
        output.setBool(1, true)
    else
        output.setBool(1, false)
    end

	if (not enabled) or (target_rate:is_decrementing() and (engine_rps.current_value < clutch_bite_rps)) then
		clutch:disengage()
		return
    end

    if target_rate:is_incrementing() then
        if (engine_rps.current_value > clutch_bite_rps) and (engine_rps:is_incrementing()) then
            clutch:increase(clutch_engagement_p_gain * (engine_rps.current_value - clutch_bite_rps))
        elseif (engine_rps.current_value < clutch_bite_rps) then
            clutch:decrease(clutch_disengagement_p_gain * (clutch_bite_rps - engine_rps.current_value))
        end
        return
    end
end
