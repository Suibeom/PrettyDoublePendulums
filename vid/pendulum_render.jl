include("pendulums_mod.jl")
using UUIDs, FileIO, ProgressMeter

function get_fractal(pendulums::Pendulums.PendulumCollection{2})
    return Pendulums.get_color.(pendulums.θ_1s, pendulums.θ_2s)
end
function init_angle_linspace_grid(
    size::Int,
    min_angle::Float64,
    max_angle::Float64,
)::Pendulums.PendulumCollection{2}
    grid_mesh::Float64 = 1 / size
    angle(k) = (max_angle - min_angle) * grid_mesh * k + min_angle
    θ_1s = zeros(Float64, size, size)
    θ_2s = zeros(Float64, size, size)
    for i = 1:size
        for j = 1:size
            θ_1s[i, j] = angle(j)
            θ_2s[i, j] = angle(i)
        end
    end
    return Pendulums.InitPendulums(θ_1s, θ_2s)
end
size = parse(Int, ARGS[1])
frame_count = parse(Int, ARGS[2])
step_size = parse(Float64, ARGS[3])

pendulums = init_angle_linspace_grid(size, Float64(-π), Float64(π))
run_id = string(UUIDs.uuid4())

pendulum_next = pendulums
@showprogress for i = 0:frame_count
    global pendulum_next = Pendulums.step(pendulum_next, step_size)

    save(
        "./" * run_id * "/frames/" * string(i, pad = 6) * ".png",
        get_fractal(pendulum_next),
    )

end
print(run_id)