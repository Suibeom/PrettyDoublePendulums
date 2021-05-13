### A Pluto.jl notebook ###
# v0.14.5

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 6f86bb34-b32e-11eb-060c-313ebd8c1ab0
begin
	using Colors, Images
    struct PendulumCollection{N}
        theta_1s::Array{Float64,N}
        d_theta_1s::Array{Float64,N}
        length_1s::Array{Float64,N}
        mass_1s::Array{Float64,N}
        theta_2s::Array{Float64,N}
        d_theta_2s::Array{Float64,N}
        length_2s::Array{Float64,N}
        mass_2s::Array{Float64,N}
        gravity::Float64
    end
    function InitPendulums(
        theta_1s::Array{Float64},
        theta_2s::Array{Float64},
    )::PendulumCollection
        return PendulumCollection(
            theta_1s,
            zeros(size(theta_1s)),
            ones(size(theta_1s)),
            ones(size(theta_1s)),
            theta_2s,
            zeros(size(theta_1s)),
            ones(size(theta_1s)),
            ones(size(theta_1s)),
            9.8,
        )
    end
    function step(pendulums::PendulumCollection, delta_t::Float64)::PendulumCollection
        bottom =
            2 * pendulums.mass_1s +
            pendulums.mass_2s .* (1 .- cos.(2 * (pendulums.theta_1s - pendulums.theta_2s)))
        dd_theta_1s =
            (
                -pendulums.gravity * (2 * pendulums.mass_1s + pendulums.mass_2s) .*
                sin.(pendulums.theta_1s) -
                pendulums.gravity * pendulums.mass_2s .*
                sin.(pendulums.theta_1s - 2 * pendulums.theta_2s) -
                2 * sin.(pendulums.theta_1s - pendulums.theta_2s) .* pendulums.mass_2s .* (
                    pendulums.d_theta_2s .^ 2 .* pendulums.length_2s +
                    pendulums.d_theta_1s .^ 2 .* pendulums.length_1s .*
                    cos.(pendulums.theta_1s - pendulums.theta_2s)
                )
            ) ./ (pendulums.length_1s .* bottom)
        dd_theta_2s =
            (
                2 * sin.(pendulums.theta_1s - pendulums.theta_2s) .* (
                    pendulums.d_theta_1s .^ 2 .* pendulums.length_1s .*
                    (pendulums.mass_1s + pendulums.mass_2s) +
                    pendulums.gravity * (pendulums.mass_1s + pendulums.mass_2s) .*
                    cos.(pendulums.theta_1s) +
                    pendulums.d_theta_2s .^ 2 .* pendulums.length_2s .* pendulums.mass_2s .*
                    cos.(pendulums.theta_1s - pendulums.theta_2s)
                )
            ) ./ (pendulums.length_2s .* bottom)
        d_theta_1s = pendulums.d_theta_1s + delta_t * dd_theta_1s
        d_theta_2s = pendulums.d_theta_2s + delta_t * dd_theta_2s
        theta_1s = pendulums.theta_1s + delta_t * pendulums.d_theta_1s
        theta_2s = pendulums.theta_2s + delta_t * pendulums.d_theta_2s
        return PendulumCollection(
            theta_1s,
            d_theta_1s,
            pendulums.length_1s,
            pendulums.mass_1s,
            theta_2s,
            d_theta_2s,
            pendulums.length_2s,
            pendulums.mass_2s,
            pendulums.gravity,
        )
    end
    function get_color(theta, phi)
        return RGB(
             0.5+ 0.5*sin(theta) * cos(phi),
           0.5+ 0.5*sin(theta) * sin(phi),
           0.5+ 0.5* cos(theta),
        )
    end
	function get_fractal(pendulums::PendulumCollection{2})
		return get_color.(pendulums.theta_1s, pendulums.theta_2s)
    end
	function init_angle_linspace_grid(size::Int, min_angle::Float64, max_angle::Float64)::PendulumCollection{2}
		grid_mesh::Float64 = 1/size
		angle(k) = (max_angle - min_angle) * grid_mesh * k + min_angle
		theta_1s = zeros(Float64, size,size)
		theta_2s = zeros(Float64, size, size)
		for i in 1:size
			for j in 1:size
				theta_1s[i,j] = angle(i)
				theta_2s[i,j] = angle(j)
			end
		end
		return InitPendulums(theta_1s, theta_2s)
	end



end


# ╔═╡ 77bfd02b-c70f-4eec-858d-d34e5701a5c0
pendulums = init_angle_linspace_grid(1000, Float64(-π), Float64(π))

# ╔═╡ c070b2ea-4e1d-40b3-8447-69d4b15990f7
@bind frame_count html"<input type='number' value='15'>"

# ╔═╡ 9a160d4a-d44c-49af-99bc-ad8d36b8f49a
begin
	frames = []
	pendulum_next = pendulums
	for i in 0:frame_count
		push!(frames, get_fractal(pendulum_next))
		pendulum_next = step(pendulum_next, 0.05)
	end
end

# ╔═╡ 62cbd3df-54ea-428c-905a-d84837f9e57e
@bind frame HTML("<input type='range' value='1' min='1' max='"*string(frame_count)*"'>")

# ╔═╡ eb20c155-b742-4f41-9bf4-45767edfd75e
frames[min(frame, frame_count)]

# ╔═╡ Cell order:
# ╠═6f86bb34-b32e-11eb-060c-313ebd8c1ab0
# ╠═77bfd02b-c70f-4eec-858d-d34e5701a5c0
# ╠═c070b2ea-4e1d-40b3-8447-69d4b15990f7
# ╠═9a160d4a-d44c-49af-99bc-ad8d36b8f49a
# ╠═62cbd3df-54ea-428c-905a-d84837f9e57e
# ╠═eb20c155-b742-4f41-9bf4-45767edfd75e
