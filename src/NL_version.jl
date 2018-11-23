function NL_version(generators, nodes, branches, loads)
    set_gens = [g.name for g in generators if g.available];
    set_loads = [l.name for l in loads if l.available];
    set_buses = [b.name for b in nodes];
    set_branches = [ell.name for ell in branches];
                
    DM = Model(with_optimizer(Ipopt.Optimizer))
                
    @variable(DM, μ_plus[set_gens], lower_bound = 0, start = 0.0);
    #@variable(DM, μ_minus[set_gens], lower_bound = 0);
    @variable(DM, β_plus[set_loads], lower_bound = 0, start = 1.0);
    #@variable(DM, β_minus[set_loads], lower_bound = 0);
    @variable(DM, α_plus[set_branches], lower_bound = 0, start = 0.0);
    @variable(DM, α_minus[set_branches], lower_bound = 0, start = 0.0);
    @variable(DM, ν_plus[set_buses], lower_bound = 0, start = 0.0);
    @variable(DM, ν_minus[set_buses], lower_bound = 0, start = 0.0);
    @variable(DM, λ[set_buses], start = 0.0);
    @variable(DM, η[set_branches], start = 0.0);
    @variable(DM, ζ, start = 0.0);
    @variable(DM, z[set_branches], lower_bound = 0.0, upper_bound = 1.0, start = 1.0);
    
    dual_gens(DM, λ, μ_plus, set_buses, generators14)
    dual_loads(DM, λ, β_plus, set_buses, loads14)                
    dual_branches(DM, λ, η, α_plus, α_minus, set_buses, branches14)                
    dual_balance_zvar(DM, nodes14, branches14, generators14, loads14)
    dual_balance_bus1_zvar(DM, nodes14, branches14, generators14, loads14)            
    dual_demand_bound(DM, α_plus, α_minus, μ_plus, β_plus, ν_plus, ν_minus, branches, generators, loads, nodes)                       
    
    @objective(DM, Min, sum(z[i] for i in set_branches))
                    
    return(DM)
                
end