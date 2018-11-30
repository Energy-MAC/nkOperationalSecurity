function dual_bilinear_constraints_i(m, branches)
    
    set_branches = [ell.name for ell in branches];
    z = m[:z]
    
    @variable(m, z_h, lower_bound = 0.0, upper_bound = 1.0)
    
    @constraint(m, z_h >= sum(z[i] for i in set_branches) - length(set_branches) +1)
    
    for b in branches
        relaxation_bilinear_i(m, m[:η][b.name], m[:z][b.name], m[:w][b.name], z_h)
    end
    
end


function relaxation_bilinear_i(m, x, z, w, z_h)
    x_ub = 80
    x_lb = -80

    L = @variable(m, [1:2],upper_bound = 1.0, lower_bound = 0.0)

    w_val = [x_lb 
             x_ub]

    @constraint(m, w == sum(w_val[i]*L[i] for i in 1:2))
    @constraint(m, x <= (L[1])*x_lb +
                        (L[2])*x_ub +x_ub*(1 - z_h) )
    @constraint(m, x >= (L[1])*x_lb +
                        (L[2])*x_ub + +x_lb*(1 - z_h))
    @constraint(m, z_h <= z)
    @constraint(m, sum(L) == z_h)
    
    
    
end