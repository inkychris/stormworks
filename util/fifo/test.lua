dofile "util/fifo/src.lua"

fifo = FIFO(3)

function assert_fifo_positive(t)
    for i = 1,fifo.size do
        assert(fifo:get(i) == t[i])
    end
end

function assert_fifo_negative(t)
    for i = 1,fifo.size do
        assert(fifo:get(-i) == t[i])
    end
end

assert_fifo_positive{nil,nil,nil}
assert_fifo_negative{nil,nil,nil}
assert(fifo:get(0) == nil)

fifo:push(1)
assert_fifo_positive{nil,nil,1}
assert_fifo_negative{1,nil,nil}
assert(fifo:get(0) == 1)

fifo:push(2)
assert_fifo_positive{nil,1,2}
assert_fifo_negative{2,1,nil}
assert(fifo:get(0) == 2)

fifo:push(3)
assert_fifo_positive{1,2,3}
assert_fifo_negative{3,2,1}
assert(fifo:get(0) == 3)

print("All assertions passed!")
