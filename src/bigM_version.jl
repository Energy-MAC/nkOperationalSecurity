function bigM_version(generators, nodes, branches, loads, bigM, min_load_percent, optimizer = with_optimizer(GLPK.Optimizer, msg_lev = GLPK.MSG_ALL))
    
    FP = Model(optimizer)
    
    dual_variables(FP, generators, nodes, branches, loads)
    
    set_branches = [ell.name for ell in branches];
    @variable(FP, z[set_branches], Bin);
    @variable(FP, y[set_branches], lower_bound = -bigM, upper_bound = bigM);
                            
    dual_gens(FP, nodes, generators)
    dual_loads(FP,  nodes, loads)                
    dual_branches(FP, nodes, branches)              
    dual_balance_bigM(FP, nodes, branches, generators, loads)
    dual_balance_bus1_bigM(FP, nodes, branches, generators, loads)
    bigM_constraints(FP, branches, bigM)
    dual_demand_bound(FP, branches, generators, loads, nodes, min_load_percent)
       
    @objective(FP, Min, sum(z[i] for i in set_branches))                       
                    
    return(FP)
                
end

