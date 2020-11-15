function anyEnabled()
    for i=3,32 do
        if input.getBool(i) then
            return true
        end
    end
    return false
end

timer = 0
disable_delay = property.getNumber("Disable Delay (ticks)")
disabled = false

function onTick()
    local primary_enabled = input.getBool(1)
    if not primary_enabled or input.getBool(2) then
        disabled = false
    end

    local result = (not disabled) and primary_enabled
    local any_enabled = anyEnabled()
    
    if result then
        if not any_enabled then
            if timer > disable_delay then
                result = false
                disabled = true
                timer = 0
            else
                timer = timer + 1
            end
        else
            result = true
            timer = 0
        end
    end

    output.setBool(1, result)
    output.setBool(2, disabled)
end
