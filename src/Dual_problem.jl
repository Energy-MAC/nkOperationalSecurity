function dual_problem(generators, nodes, branches, loads, optimizer=with_optimizer(Ipopt.Optimizer))
    DM = Model(optimizer)
                
    dual_variables(DM, generators, nodes, branches, loads)
    
    set_branches = [ell.name for ell in branches];
    @variable(m, z[set_branches],lower_bound = 0.0,upper_bound = 1.0);
    
    dual_gens(DM, λ, μ_plus, set_buses, generators)
    dual_loads(DM, λ, β_plus, set_buses, loads)                
    dual_branches(DM, λ, η, α_plus, α_minus, set_buses, branches)                
    dual_balance_no_z(DM, nodes, branches, generators, loads)
    dual_balance_bus1_no_z(DM, nodes, branches, generators, loads)            
                
    obj = dual_objective(DM, α_plus, α_minus, μ_plus, β_plus, ν_plus, ν_minus, branches, generators, loads, nodes)           
    
    @objective(DM, Min, obj)                        
                    
    return(DM)
                
end


function dual_problem_test(generators, nodes, branches, loads, z, optimizer=with_optimizer(Ipopt.Optimizer))
    
    dual_variables(DM, generators, nodes, branches, loads)
    
    set_branches = [ell.name for ell in branches];
    @variable(m, z[set_branches],lower_bound = 0.0,upper_bound = 1.0);
    
    dual_gens(DM, λ, μ_plus, set_buses, generators)
    dual_loads(DM, λ, β_plus, set_buses, loads)                
    dual_branches(DM, λ, η, α_plus, α_minus, set_buses, branches)                
    dual_balance_fixed_z(DM, nodes, branches, generators, loads,z)
    dual_balance_bus1_fixed_z(DM, nodes, branches, generators, loads,z)            
                
    obj = dual_objective(DM, α_plus, α_minus, μ_plus, β_plus, ν_plus, ν_minus, branches, generators, loads, nodes)           
    
    @objective(DM, Min, obj)                        
                    
    return(DM)
                
end