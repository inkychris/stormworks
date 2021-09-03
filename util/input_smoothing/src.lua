function Smooth(sensitivity)
    local this = {_s=sensitivity,_v=0}
    function this:process(v)
        this._v=this._v+(v-this._v)*(this._s/100)^2
        return this._v
    end
    return this
end
