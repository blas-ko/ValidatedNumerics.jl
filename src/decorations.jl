using ValidatedNumerics

import ValidatedNumerics.AbstractInterval

@enum DECORATION ill=0 trv=1 def=2 dac=3 com=4
# < and min work automatically!

macro I_str(ex)
    @interval ex
end


type DecoratedInterval{T <: AbstractFloat} <: AbstractInterval
    interval::Interval{T}
    decoration::DECORATION
end

interval(x::DecoratedInterval) = x.interval
decoration(x::DecoratedInterval) = x.decoration

Base.show(io::IO, x::DecoratedInterval) = print(io, x.interval, "_", x.decoration)


type Box{T <: AbstractInterval}
    components::Vector{T}
end

Box(a...) = Box([a...])

#Box(DecoratedInterval(I"1", com), DecoratedInterval(I"2", com))



# Define sin(::DecoratedInterval)

decay(a::DECORATION, b::DECORATION) = min(a, b)
decay(xx::DecoratedInterval, a::DECORATION) = min(decoration(xx), a)

function Base.sign{T}(xx::DecoratedInterval{T})
    x = interval(xx)

    if zero(T) ∉ x
        return DecoratedInterval(sign(x), decay(xx, com))
    end

    return DecoratedInterval(sign(x), decay(xx, def))

end

function Base.sqrt{T}(xx::DecoratedInterval{T})
    x = interval(xx)

    domain = Interval{T}(zero(T), convert(T, ∞))

    if x ⊆ domain

        if isunbounded(x)
            DecoratedInterval(sqrt(x), decay(xx, dac))
        else
            return DecoratedInterval(sqrt(x), decay(xx, com))
        end

    end

    DecoratedInterval(sqrt(x ∩ domain), decay(xx, trv))
end
