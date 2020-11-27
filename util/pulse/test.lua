dofile "util/io_mock.lua"

property.setNumber("Start Number", 4)

dofile "util/pulse/src.lua"

test = Pulse()

test:update(true)
assert(not test:on_off())
assert(test:off_on())
assert(test:always())

test:update(false)
assert(test:on_off())
assert(not test:off_on())
assert(test:always())

test:update(false)
assert(not test:on_off())
assert(not test:off_on())
assert(not test:always())

print("All assertions passed!")
