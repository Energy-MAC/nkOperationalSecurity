function bilinear_version(generators, nodes, branches, loads, min_load_percent, optimizer = with_optimizer(GLPK.Optimizer, msg_lev = GLPK.MSG_ALL))
    
    FP = Model(optimizer)
    
    dual_variables(DM, generators, nodes, branches, loads)
    
    set_branches = [ell.name for ell in branches];
    
    @variable(m, z[set_branches],lower_bound = 0.0,upper_bound = 1.0);
    
    @variable(m, w[set_branches]);  
    
    dual_gens(FP, λ, μ_plus, set_buses, generators)
    dual_loads(FP, λ, β_plus, set_buses, loads)                
    dual_branches(FP, λ, η, α_plus, α_minus, set_buses, branches)                
    dual_balance_bilinear(FP, nodes, branches, generators, loads)
    dual_balance_bus1_bilinear(FP, nodes, branches, generators, loads)
    dual_bilinear_constraints(FP, branches)
    dual_demand_bound(FP, α_plus, α_minus, μ_plus, β_plus, ν_plus, ν_minus, branches, generators, loads, nodes, min_load_percent)
       
    @objective(FP, Min, sum(z[i] for i in set_branches))                       
                    
    return(FP)
                
    end 