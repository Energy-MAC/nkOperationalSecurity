function dual_variables(m, generators, nodes, branches, loads)
   total_load = 0.0
    for l in loads
        total_load=total_load+l.maxactivepower
    end
    set_gens = [g.name for g in generators if g.available];
    set_loads = [l.name for l in loads if l.available];
    set_buses = [b.name for b in nodes];
    set_branches = [ell.name for ell in branches];
                
    @variable(m, μ_plus[set_gens], lower_bound = 0.0);
    @variable(m, β_plus[set_loads], lower_bound = 0.0);
    @variable(m, α_plus[set_branches], lower_bound = 0.0);
    @variable(m, α_minus[set_branches], lower_bound = 0.0);
    @variable(m, ν_plus[set_buses], lower_bound = 0.0);
    @variable(m, ν_minus[set_buses], lower_bound = 0.0);
    @variable(m, λ[set_buses]);
    @variable(m, η[set_branches], lower_bound=-2*total_load, upper_bound=2*total_load);
    @variable(m, ζ);
    
end

function dual_gens(m, nodes, devices)
    
    λ = m[:λ] 
    μ_plus = m[:μ_plus] 
    
    set_buses = [b.name for b in nodes];
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
            
            
function dual_loads(m, nodes, devices)
    
    λ = m[:λ]
    β_plus = m[:β_plus]   
        
    set_buses = [b.name for b in nodes];    
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
            
            
function dual_branches(m, nodes, devices)
            
    λ = m[:λ]
    η = m[:η]
            
    α_plus = m[:α_plus]
    α_minus = m[:α_minus]        

    set_buses = [b.name for b in nodes];           
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

    
function dual_objective(m, branches, generators, loads, nodes)
                
    α_plus = m[:α_plus]
    α_minus = m[:α_minus] 

    μ_plus = m[:μ_plus]            
    
    β_plus = m[:β_plus]
                
    ν_plus = m[:ν_plus]
    ν_minus = m[:ν_minus]                
                
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
            
function dual_demand_bound(m, branches, generators, loads, nodes, min_load_percent)
        total_load = 0.0
                
        α_plus = m[:α_plus]
        α_minus = m[:α_minus] 

        μ_plus = m[:μ_plus]            

        β_plus = m[:β_plus]

        ν_plus = m[:ν_plus]
        ν_minus = m[:ν_minus]            
                
        for l in loads
            total_load=total_load+l.maxactivepower
        end

        dual_obj = dual_objective(m, branches, generators, loads, nodes)
                
        dual_obj_constraint = @constraint(m, Dual_obj_constraint, dual_obj <= min_load_percent*total_load)
end
                