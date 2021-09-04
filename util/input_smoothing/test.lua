dofile "util/input_smoothing/src.lua"

val = PGain(50)

for _=1,20 do print(val:process(0)) end
for _=1,20 do print(val:process(1)) end
for _=1,20 do print(val:process(0)) end
for _=1,20 do print(val:process(-1)) end
for _=1,20 do print(val:process(1)) end
for _=1,20 do print(val:process(0)) end
