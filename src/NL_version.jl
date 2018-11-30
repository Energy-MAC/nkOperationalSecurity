function NL_version(generators, nodes, branches, loads, min_load_percent, optimizer = with_optimizer(Ipopt.Optimizer))
                
    DM = Model(optimizer)
            
    dual_variables(DM, generators, nodes, branches, loads)
    
    set_branches = [ell.name for ell in branches];
    @variable(m, z[set_branches],lower_bound = 0.0,upper_bound = 1.0);
    
    dual_gens(DM, λ, μ_plus, set_buses, generators)
    dual_loads(DM, λ, β_plus, set_buses, loads)                
    dual_branches(DM, λ, η, α_plus, α_minus, set_buses, branches)                
    dual_balance_zvar(DM, nodes, branches, generators, loads)
    dual_balance_bus1_zvar(DM, nodes, branches, generators, loads)            
    dual_demand_bound(DM, α_plus, α_minus, μ_plus, β_plus, ν_plus, ν_minus, branches, generators, loads, nodes, min_load_percent)
    
    @objective(DM, Min, sum(z[i] for i in set_branches))
                    
    return(DM)
                
end