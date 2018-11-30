function dual_problem(generators, nodes, branches, loads, optimizer=with_optimizer(Ipopt.Optimizer))
    DM = Model(optimizer)
                
    dual_variables(DM, generators, nodes, branches, loads)
    
    set_branches = [ell.name for ell in branches];
    @variable(DM, z[set_branches],lower_bound = 0.0,upper_bound = 1.0);
    
    dual_gens(DM, nodes, generators)
    dual_loads(DM,  nodes, loads)                
    dual_branches(DM, nodes, branches)                
    dual_balance_no_z(DM, nodes, branches, generators, loads)
    dual_balance_bus1_no_z(DM, nodes, branches, generators, loads)            
                
    obj = dual_objective(DM, branches, generators, loads, nodes)           
    
    @objective(DM, Min, obj)                        
                    
    return(DM)
                
end


function dual_problem_test(generators, nodes, branches, loads, z, optimizer=with_optimizer(Ipopt.Optimizer))
    DM = Model(optimizer)
    
    dual_variables(DM, generators, nodes, branches, loads)
    
    set_branches = [ell.name for ell in branches];
    
    dual_gens(DM, nodes, generators)
    dual_loads(DM, nodes, loads)                
    dual_branches(DM, nodes, branches)                
    dual_balance_fixed_z(DM, nodes, branches, generators, loads,z)
    dual_balance_bus1_fixed_z(DM, nodes, branches, generators, loads,z)            
                
    obj = dual_objective(DM, branches, generators, loads, nodes)           
    
    @objective(DM, Min, obj)                        
                    
    return(DM)
                
end