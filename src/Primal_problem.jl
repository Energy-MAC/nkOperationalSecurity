function generators_limits(m, P_th, devices)
 
    name_index = P_th.axes[1]

    pmax_th = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index)
    pmin_th = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index)

    for (ix, name) in enumerate(name_index)

        if name == devices[ix].name

            pmin_th[name] = @constraint(m, P_th[name] >= devices[ix].tech.activepowerlimits.min)
            pmax_th[name] = @constraint(m, P_th[name] <= devices[ix].tech.activepowerlimits.max)

        else
            error("Bus name in Array and variable do not match")
        end

    end
    
    JuMP.register_object(m, :pmax_th, pmax_th)
    JuMP.register_object(m, :pmin_th, pmin_th)
        
end
    
    
    
function primal_problem(generators, buses, branches, loads)    
    #Instantiate Model
    PM = Model(with_optimizer(Ipopt.Optimizer))
    
    #make sets
    set_gens = [g.name for g in  generators if g.available]
    set_loads = [ld.name for ld in loads if ld.available] 
    set_lines = [ln.name for ln in branches if ln.available]
    set_buses = [b.name for b in buses]
    
    #generate variables     
    @variable(PM, P_th[set_gens], lower_bound = 0)
    @variable(PM, D[set_loads], lower_bound =  0) 
        
    for (ix,d) in enumerate(PM[:D])
        JuMP.set_start_value(d,loads14[ix].maxactivepower)
    end

    @variable(PM, fl[set_lines]) 

    @variable(PM, z[set_lines] == 0.0) # add the Bin tag Later in order to make this code run with Ipopt

    @variable(PM, θ[set_buses]);  
        
    for name in θ.axes[1][2:end]
        JuMP.set_lower_bound(θ[name],-1.57)
        JuMP.set_upper_bound(θ[name],1.57)
    end
        
    JuMP.fix(θ["Bus 1"],0.0)     
    
    generators_limits(PM, P_th, generators)        
end 