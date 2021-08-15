dofile "util/clamp/src.lua"

for i=-2,2,0.1 do
    print(smooth_clamp(i,-1,1))
end