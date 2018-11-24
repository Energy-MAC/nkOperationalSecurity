function dual_problem(generators, nodes, branches, loads)
    set_gens = [g.name for g in generators if g.available];
    set_loads = [l.name for l in loads if l.available];
    set_buses = [b.name for b in nodes];
    set_branches = [ell.name for ell in branches];
                
    DM = Model(with_optimizer(Ipopt.Optimizer))
                
    @variable(DM, μ_plus[set_gens], lower_bound = 0);
    #@variable(DM, μ_minus[set_gens], lower_bound = 0);
    @variable(DM, β_plus[set_loads], lower_bound = 0);
    #@variable(DM, β_minus[set_loads], lower_bound = 0);
    @variable(DM, α_plus[set_branches], lower_bound = 0);
    @variable(DM, α_minus[set_branches], lower_bound = 0);
    @variable(DM, ν_plus[set_buses], lower_bound = 0);
    @variable(DM, ν_minus[set_buses], lower_bound = 0);
    @variable(DM, λ[set_buses]);
    @variable(DM, η[set_branches]);
    @variable(DM, ζ);
    
    dual_gens(DM, λ, μ_plus, set_buses, generators)
    dual_loads(DM, λ, β_plus, set_buses, loads)                
    dual_branches(DM, λ, η, α_plus, α_minus, set_buses, branches)                
    dual_balance_no_z(DM, nodes, branches, generators, loads)
    dual_balance_bus1_no_z(DM, nodes, branches, generators, loads)            
                
    obj = dual_objective(DM, α_plus, α_minus, μ_plus, β_plus, ν_plus, ν_minus, branches, generators, loads, nodes)           
    
    @objective(DM, Min, obj)                        
                    
    return(DM)
                
end