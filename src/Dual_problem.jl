function dual_gens(m, λ, μ_plus, set_buses, devices)
    name_index = μ_plus.axes[1]
    dual_gen = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index) 

    for (ix, name) in enumerate(name_index)

        if name == devices[ix].name
            dual_gen[name] = @constraint(m, λ[set_buses[devices[ix].bus.number]] + μ_plus[name] >=0)
        else
            error("Bus name in Array and variable do not match gens")
        end
    end
    JuMP.register_object(m, :dual_gen, dual_gen)
end
            
            
function dual_loads(m, λ, β_plus, set_buses, devices)
    name_index = β_plus.axes[1] 
    dual_load = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index) 

    for (ix, name) in enumerate(name_index)

        if name == devices[ix].name
            dual_load[name] = @constraint(m, -λ[set_buses[devices[ix].bus.number]] + β_plus[name] >=1)
        else
            error("Bus name in Array and variable do not match loads")
        end
    end
    JuMP.register_object(m, :dual_load, dual_load)
end
            
            
function dual_branches(m, λ, α_plus, α_minus, set_buses, devices)
    name_index = α_plus.axes[1]
    dual_branch = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index) 

    for (ix, name) in enumerate(name_index)

        if name == devices[ix].name
            dual_branch[name] = @constraint(m, -λ[set_buses[devices[ix].connectionpoints.from.number]]
                + λ[set_buses[devices[ix].connectionpoints.to.number]] + α_plus[name] - α_minus[name]
                + η[name] == 0)
        else
            error("Bus name in Array and variable do not match branches")
        end
    end
    JuMP.register_object(m, :dual_branch, dual_branch)
end

    
function dual_objective(m, α_plus, α_minus, μ_plus, β_plus, ν_plus, ν_minus, branches, generators, loads, nodes)
    obj_func = AffExpr(0.0)
    
    for b in branches
       JuMP.add_to_expression!(obj_func, (α_plus[b.name] + α_minus[b.name])*b.rate)
    end
    for g in generators
       JuMP.add_to_expression!(obj_func, μ_plus[g.name]*g.tech.activepowerlimits.max)
    end
    for d in loads
       JuMP.add_to_expression!(obj_func, β_plus[d.name]*d.maxactivepower)
    end
    for i in nodes
       JuMP.add_to_expression!(obj_func, 1.57*(ν_plus[i.name]+ν_minus[i.name]))
    end
    
    return obj_func
end


function dual_problem(generators, nodes, branches, loads)
    set_gens = [g.name for g in generators if g.available];
    set_loads = [l.name for l in loads if l.available];
    set_buses = [b.name for b in nodes];
    set_branches = [ell.name for ell in branches];
    z = zeros(length(set_branches))
                
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
    #@variable(DM, z[set_branches], Bin);
    
    dual_gens(DM, λ, μ_plus, set_buses, generators14)
    dual_loads(DM, λ, β_plus, set_buses, loads14)                
    dual_branches(DM, λ, α_plus, α_minus, set_buses, branches14)                
    dual_balance_no_z(DM, nodes14, branches14, generators14, loads14)
    dual_balance_bus1_no_z(DM, buses, branches14, generators14, loads14)            
                
    obj = dual_objective(DM, α_plus, α_minus, μ_plus, β_plus, ν_plus, ν_minus, branches, generators, loads, nodes)           
    
    @objective(DM, Min, obj)                        
                    
    return(DM)
                
end