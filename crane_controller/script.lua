time_const = property.getNumber("Controller Axis Time Constant") or 68.9676

ControlAxis = {
    Mode = {None = 0, Inc = 1, Dec = 2},
    Decay = 0.5 ^ (1 / time_const),
}
function ControlAxis:Create(t)
    local this = {
        channel = t.channel,
        increment = t.increment or 0.005,
        min = t.min or -1,
        max = t.max or 1,
        threshold = t.threshold or 0.01,
        --
        val = t.start or 0,
        prev_input = 0,
        mode = ControlAxis.Mode.None,
    }
    function this:delta()
        return self.val - self.prev_val
    end
    function this:process()
        local current_input = input.getNumber(self.channel)
        local expected = self.prev_input * ControlAxis.Decay

        if current_input > expected + self.threshold then
            self.mode = ControlAxis.Mode.Inc
        elseif current_input < expected - self.threshold then
            self.mode = ControlAxis.Mode.Dec
        else
            self.mode = ControlAxis.Mode.None
        end

        if self.mode ~= ControlAxis.Mode.None then
            local potential_val = self.val + self.increment
            if self.mode == ControlAxis.Mode.Inc and potential_val <= self.max then
                self.val = potential_val
            end
            potential_val = self.val - self.increment
            if self.mode == ControlAxis.Mode.Dec and potential_val >= self.min then
                self.val = potential_val
            end
        end
        self.prev_input = current_input
        return self.val
    end
    return this
end

input_threshold = property.getNumber("Input Threshold")

pivot = ControlAxis:Create{
    channel = 1,
    increment = property.getNumber("Pivot Increment"),
    threshold = input_threshold,
    min = property.getNumber("Pivot Min"),
    max = property.getNumber("Pivot Max"),
    start = property.getNumber("Pivot Start")
}

primary_hinge = ControlAxis:Create{
    channel = 2,
    increment = property.getNumber("Primary Hinge Increment"),
    threshold = input_threshold,
    min = property.getNumber("Primary Hinge Min"),
    max = property.getNumber("Primary Hinge Max"),
    start = property.getNumber("Primary Hinge Start")
}

secondary_hinge = ControlAxis:Create{
    channel = 4,
    increment = property.getNumber("Secondary Hinge Increment"),
    threshold = input_threshold,
    min = property.getNumber("Secondary Hinge Min"),
    max = property.getNumber("Secondary Hinge Max"),
    start = property.getNumber("Secondary Hinge Start")
}

function onTick()
	output.setNumber(1, pivot:process())
	output.setNumber(2, primary_hinge:process())
	output.setNumber(3, secondary_hinge:process())
end
