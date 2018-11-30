function dual_bilinear_constraints_i(m, branches)
    
    for b in branches
        relaxation_bilinear_i(m, m[:η][b.name], m[:z][b.name], m[:w][b.name])
    end
    
end


function relaxation_bilinear_i(m, x, z, w)
    x_ub = 5000
    x_lb = -5000

    L = @variable(m, [1:2],upper_bound = 1.0, lower_bound = 0.0)

    w_val = [x_lb 
             x_ub]

    @constraint(m, w == sum(w_val[i]*L[i] for i in 1:2))
    
    @constraint(m, x <= (L[1])*x_lb +
                        (L[2])*x_ub +x_ub*(1 - z) )
    @constraint(m, x >= (L[1])*x_lb +
                        (L[2])*x_ub + +x_lb*(1 - z))
    @constraint(m, sum(L) == z)
    
    
end