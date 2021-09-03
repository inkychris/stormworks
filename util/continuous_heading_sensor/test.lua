dofile "util/continuous_heading_sensor/src.lua"

heading = Heading()

for i=0,-4,-0.1 do
    heading:update((i%1)-0.5, 1)
    print(heading._h, heading._r, heading:rads())
end

for i=-4,4,0.1 do
    heading:update((i%1)-0.5, 0)
    print(heading._h, heading._r, heading:rads())
end
