dofile "util/clamp.lua"

Mode = {
    Default = 0,
    Override = 1,
    Ignore = 2,
}

transition = property.getNumber("Transition Time")
sunrise_start = property.getNumber("Sunrise")
sunrise_end = sunrise_start + transition
sunset_end = property.getNumber("Sunset")
sunset_start = sunset_end - transition
min_weather = property.getNumber("Min Weather")

Intensity = {On = 1, Off = 0}
Channel = {
    In = {
        Num = {Time = 1, Rain = 2, Fog = 3}
    },
    Out = {
        Num = {Port = 1, Starboard = 2, Rear = 3}
    }
}

function intensity_at(time, min_override)
    local _intensity_off = Intensity.Off
    Intensity.Off = min_override
    local intensity_delta = Intensity.On - Intensity.Off
    local result = 0

    if (time <= sunrise_start) or (time >= sunset_end) then
        result = Intensity.On
    elseif time > sunrise_start and time < sunrise_end then
        result = Intensity.On - ((time - (sunrise_start)) / transition) * intensity_delta
    elseif time > sunset_start and time < sunset_end then
        result = Intensity.Off + ((time - (sunset_start)) / transition) * intensity_delta
    else
        result = Intensity.Off
    end
    Intensity.Off = _intensity_off
    return result
end

function onTick()
    local weather = math.max(input.getNumber(Channel.In.Num.Rain), input.getNumber(Channel.In.Num.Fog))
    local weather_intensity = clamp((weather - min_weather) / (1 - min_weather), 0, 1)

    local time = input.getNumber(Channel.In.Num.Time)
    local intensity = intensity_at(time, weather_intensity)

    output.setNumber(Channel.Out.Num.Port, intensity)
    output.setNumber(Channel.Out.Num.Starboard, intensity)
    output.setNumber(Channel.Out.Num.Rear, intensity)
end
