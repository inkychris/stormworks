dofile "../util/clamp.lua"

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
mode = property.getNumber("Enable Behaviour")
min_rain = property.getNumber("Min Rain")

rgb_r = property.getNumber("RGB R") / 255
rgb_g = property.getNumber("RGB G") / 255
rgb_b = property.getNumber("RGB B") / 255

Intensity = {On = 1, Off = 0}
Channel = {
    In = {
        Num = {Time = 1, Rain = 2},
        Bool = {Enabled = 1}
    },
    Out = {
        Num = {
            R = 1, G = 2, B = 3,
            Intensity = 4
        },
        Bool = {Enabled = 1}
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
    local enabled = input.getBool(Channel.In.Bool.Enabled)
    local rain = input.getNumber(Channel.In.Num.Rain)
    local rain_intensity = clamp((rain - min_rain) / (1 - min_rain), 0, 1)

    local intensity = Intensity.Off

    local time = input.getNumber(Channel.In.Num.Time)

    if mode == Mode.Default then
        if enabled then
            intensity = intensity_at(time, rain_intensity)
        end
    elseif mode == Mode.Override then
        if enabled then
            intensity = Intensity.On
        else
            intensity = intensity_at(time, rain_intensity)
        end
    elseif mode == Mode.Ignore then
        intensity = intensity_at(time, rain_intensity)
    end

    output.setNumber(Channel.Out.Num.Intensity, intensity)
    output.setNumber(Channel.Out.Num.R, intensity * rgb_r)
    output.setNumber(Channel.Out.Num.G, intensity * rgb_g)
    output.setNumber(Channel.Out.Num.B, intensity * rgb_b)
    output.setBool(Channel.Out.Bool.Enabled, intensity > 0)
end
