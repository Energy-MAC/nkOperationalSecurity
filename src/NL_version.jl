function NL_version(generators, nodes, branches, loads, min_load_percent, optimizer = with_optimizer(Ipopt.Optimizer))
                
    DM = Model(optimizer)
            
       total_load = 0.0
    for l in loads
        total_load=total_load+l.maxactivepower
    end
    set_gens = [g.name for g in generators if g.available];
    set_loads = [l.name for l in loads if l.available];
    set_buses = [b.name for b in nodes];
    set_branches = [ell.name for ell in branches];
                
    @variable(DM, μ_plus[set_gens], lower_bound = 0.0,start=0.0);
    @variable(DM, β_plus[set_loads], lower_bound = 0.0,start=0.0);
    @variable(DM, α_plus[set_branches], lower_bound = 0.0,start=0.0);
    @variable(DM, α_minus[set_branches], lower_bound = 0.0,start=0.0);
    @variable(DM, ν_plus[set_buses], lower_bound = 0.0,start=0.0);
    @variable(DM, ν_minus[set_buses], lower_bound = 0.0,start=0.0);
    @variable(DM, λ[set_buses], start=0.0);
    @variable(DM, η[set_branches], lower_bound=-2*total_load, upper_bound=2*total_load, start=0.5);
    @variable(DM, ζ, start=0.0);
    
    set_branches = [ell.name for ell in branches];
    @variable(DM, z[set_branches],lower_bound = 0.0,upper_bound = 1.0, start = 0.5);
    
    dual_gens(DM, nodes, generators)
    dual_loads(DM,  nodes, loads)                
    dual_branches(DM, nodes, branches)               
    dual_balance_zvar(DM, nodes, branches, generators, loads)
    dual_balance_bus1_zvar(DM, nodes, branches, generators, loads)            
    dual_demand_bound(DM, branches, generators, loads, nodes, min_load_percent)
    
    @objective(DM, Min, sum(z[i] for i in set_branches))
                    
    return(DM)
                
end