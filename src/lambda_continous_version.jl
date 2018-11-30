function lambda_c_version(generators, nodes, branches, loads, min_load_percent, optimizer = with_optimizer(GLPK.Optimizer, msg_lev = GLPK.MSG_ALL))
    
    FP = Model(optimizer)
    
    dual_variables(FP, generators, nodes, branches, loads)
    
    set_branches = [ell.name for ell in branches];
    
    @variable(FP, z[set_branches],lower_bound = 0.0,upper_bound = 1.0);
    
    @variable(FP, w[set_branches]);  
    
    dual_gens(FP, nodes, generators)
    dual_loads(FP,  nodes, loads)                
    dual_branches(FP, nodes, branches)                
    dual_balance_bilinear(FP, nodes, branches, generators, loads)
    dual_balance_bus1_bilinear(FP, nodes, branches, generators, loads)
    dual_bilinear_constraints(FP, branches)
    dual_demand_bound(FP, branches, generators, loads, nodes, min_load_percent)
       
    @objective(FP, Min, sum(z[i] for i in set_branches))                       
                    
    return(FP)
                
    end 