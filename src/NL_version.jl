function NL_version(generators, nodes, branches, loads, min_load_percent, optimizer = with_optimizer(Ipopt.Optimizer))
                
    DM = Model(optimizer)
            
    dual_variables(DM, generators, nodes, branches, loads)
    
    set_branches = [ell.name for ell in branches];
    @variable(DM, z[set_branches],lower_bound = 0.0,upper_bound = 1.0);
    
    dual_gens(DM, nodes, generators)
    dual_loads(DM,  nodes, loads)                
    dual_branches(DM, nodes, branches)               
    dual_balance_zvar(DM, nodes, branches, generators, loads)
    dual_balance_bus1_zvar(DM, nodes, branches, generators, loads)            
    dual_demand_bound(DM, branches, generators, loads, nodes, min_load_percent)
    
    @objective(DM, Min, sum(z[i] for i in set_branches))
                    
    return(DM)
                
end