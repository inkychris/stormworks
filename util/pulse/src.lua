function Pulse()
    local this = {
        prev = false,
        val = false}
    function this:update(val)
        self.prev = self.val
        self.val = val
    end
    function this:off_on() return self.val and not self.prev end
    function this:on_off() return self.prev and not self.val end
    function this:always() return self.prev ~= self.val end
    return this
end
