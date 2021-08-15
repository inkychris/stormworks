dofile "util/continuous_heading_sensor/src.lua"

heading = Heading()

for i=0,3,0.25 do
    heading:update((i % 1) - 0.5, 1)
    print(heading._heading.cur, heading:rads())
end

for i=3,-3,-0.25 do
    heading:update((i % 1) - 0.5, -1)
    print(heading._heading.cur, heading:rads())
end