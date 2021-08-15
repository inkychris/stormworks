dofile "util/clamp/src.lua"

for i=-2,2,0.1 do
    print(i, clamp(i,-0.6,1))
end