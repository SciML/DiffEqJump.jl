# Set up a spatial gene expression model and solve it
using DiffEqJump, DiffEqBase

tf           = 1000.0
u0           = [1,0,0,0]

reactstoch = [
    [1 => 1],
    [2 => 1],
    [2 => 1],
    [3 => 1],
    [1 => 1, 3 => 1],
    [4 => 1]
]
netstoch = [
    [2 => 1],
    [3 => 1],
    [2 => -1],
    [3 => -1],
    [1 => -1, 3 => -1, 4 => 1],
    [1 => 1, 3 => 1, 4 => -1]
]
spec_to_dep_jumps = [[1,5],[2,3],[4,5],[6]]
jump_to_dep_specs = [[2],[3],[2],[3],[1,3,4],[1,3,4]]
rates = [.5, (20*log(2.)/120.), (log(2.)/120.), (log(2.)/600.), .025, 1.]
majumps = MassActionJump(rates, reactstoch, netstoch)
prob = DiscreteProblem(u0, (0.0, tf), rates)
jump_prob_gene_expr = JumpProblem(prob, NRM(), majumps, vartojumps_map=spec_to_dep_jumps, jumptovars_map=jump_to_dep_specs)

# Graph setup for gene expression model
num_nodes = 3
connectivity_list = [[mod1(i-1,num_nodes),mod1(i+1,num_nodes)] for i in 1:num_nodes] # this is a cycle graph

diff_rates_for_edge = Array{Float64,1}(undef,length(jump_prob_gene_expr.prob.u0))
diff_rates_for_edge[1] = 0.01
diff_rates_for_edge[2] = 0.01
diff_rates_for_edge[3] = 1.0
diff_rates_for_edge[4] = 1.0
diff_rates = [[diff_rates_for_edge for j in 1:length(connectivity_list[i])] for i in 1:num_nodes]

spatial_gene_expr = to_spatial_jump_prob(connectivity_list, diff_rates, jump_prob_gene_expr)