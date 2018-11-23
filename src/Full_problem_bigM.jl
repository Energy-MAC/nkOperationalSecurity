function bigM_version(generators, nodes, branches, loads, bigM)
    set_gens = [g.name for g in generators if g.available];
    set_loads = [l.name for l in loads if l.available];
    set_buses = [b.name for b in nodes];
    set_branches = [ell.name for ell in branches];
                    
    FP = Model(with_optimizer(GLPK.Optimizer))
                
    @variable(FP, μ_plus[set_gens], lower_bound = 0);
    @variable(FP, β_plus[set_loads], lower_bound = 0);
    @variable(FP, α_plus[set_branches], lower_bound = 0);
    @variable(FP, α_minus[set_branches], lower_bound = 0);
    @variable(FP, ν_plus[set_buses], lower_bound = 0);
    @variable(FP, ν_minus[set_buses], lower_bound = 0);
    @variable(FP, λ[set_buses]);
    @variable(FP, η[set_branches]);
    @variable(FP, ζ);
    @variable(FP, z[set_branches], Bin);
    @variable(FP, y[set_branches], lower_bound = 0, upper_bound = bigM);
                            
    dual_gens(FP, λ, μ_plus, set_buses, generators)
    dual_loads(FP, λ, β_plus, set_buses, loads)                
    dual_branches(FP, λ, η, α_plus, α_minus, set_buses, branches)                
    dual_balance_bigM(FP, nodes14, branches, generators, loads)
    dual_balance_bus1_bigM(FP, nodes, branches, generators, loads)
    bigM_constraints(FP, branches, bigM)
    dual_demand_bound(FP, α_plus, α_minus, μ_plus, β_plus, ν_plus, ν_minus, branches, generators, loads, nodes)           
       
    
    @objective(FP, Min, sum(z[i] for i in set_branches))                       
                    
    return(FP)
                
end

