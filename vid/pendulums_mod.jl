module Pendulums
using Images, Colors
export PendulumCollection, InitPendulums, step, get_color
struct PendulumCollection{N}
    θ_1s::Array{Float64,N}
    d_θ_1s::Array{Float64,N}
    length_1s::Array{Float64,N}
    mass_1s::Array{Float64,N}
    θ_2s::Array{Float64,N}
    d_θ_2s::Array{Float64,N}
    length_2s::Array{Float64,N}
    mass_2s::Array{Float64,N}
    gravity::Float64
end
function InitPendulums(θ_1s::Array{Float64}, θ_2s::Array{Float64})::PendulumCollection
    return PendulumCollection(
        θ_1s,
        zeros(size(θ_1s)),
        ones(size(θ_1s)),
        ones(size(θ_1s)),
        θ_2s,
        zeros(size(θ_1s)),
        ones(size(θ_1s)),
        ones(size(θ_1s)),
        9.8,
    )
end
function step(pendulums::PendulumCollection, delta_t::Float64)::PendulumCollection
    bottom =
        2 * pendulums.mass_1s +
        pendulums.mass_2s .* (1 .- cos.(2 * (pendulums.θ_1s - pendulums.θ_2s)))
    dd_θ_1s =
        (
            -pendulums.gravity * (2 * pendulums.mass_1s + pendulums.mass_2s) .*
            sin.(pendulums.θ_1s) -
            pendulums.gravity * pendulums.mass_2s .*
            sin.(pendulums.θ_1s - 2 * pendulums.θ_2s) -
            2 * sin.(pendulums.θ_1s - pendulums.θ_2s) .* pendulums.mass_2s .* (
                pendulums.d_θ_2s .^ 2 .* pendulums.length_2s +
                pendulums.d_θ_1s .^ 2 .* pendulums.length_1s .*
                cos.(pendulums.θ_1s - pendulums.θ_2s)
            )
        ) ./ (pendulums.length_1s .* bottom)
    dd_θ_2s =
        (
            2 * sin.(pendulums.θ_1s - pendulums.θ_2s) .* (
                pendulums.d_θ_1s .^ 2 .* pendulums.length_1s .*
                (pendulums.mass_1s + pendulums.mass_2s) +
                pendulums.gravity * (pendulums.mass_1s + pendulums.mass_2s) .*
                cos.(pendulums.θ_1s) +
                pendulums.d_θ_2s .^ 2 .* pendulums.length_2s .* pendulums.mass_2s .*
                cos.(pendulums.θ_1s - pendulums.θ_2s)
            )
        ) ./ (pendulums.length_2s .* bottom)
    d_θ_1s = pendulums.d_θ_1s + delta_t * dd_θ_1s
    d_θ_2s = pendulums.d_θ_2s + delta_t * dd_θ_2s
    θ_1s = pendulums.θ_1s + delta_t * pendulums.d_θ_1s
    θ_2s = pendulums.θ_2s + delta_t * pendulums.d_θ_2s
    return PendulumCollection(
        θ_1s,
        d_θ_1s,
        pendulums.length_1s,
        pendulums.mass_1s,
        θ_2s,
        d_θ_2s,
        pendulums.length_2s,
        pendulums.mass_2s,
        pendulums.gravity,
    )
end
function get_color(θ, phi)
    return RGB(
        0.5 + 0.5 * sin(θ) * cos(phi),
        0.5 + 0.5 * sin(θ) * sin(phi),
        0.5 + 0.5 * cos(θ),
    )
end
end

