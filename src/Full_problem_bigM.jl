function full_objective_bigM(m, z, branches)
    obj_func = AffExpr(0.0)
    
    for b in branches
       JuMP.add_to_expression!(obj_func, z[b.name])
    end
    
    return obj_func
end

function full_problem_bigM(generators, nodes, branches, loads, bigM)
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
                
    obj = full_objective_bigM(FP, z, branches)           
    
    @objective(FP, Min, obj)                        
                    
    return(FP)
                
end

