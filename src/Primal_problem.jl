function generators_limits(m::JuMP.Model, P_th, devices)
 
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
    
function demand_limits(m::JuMP.Model, D, devices)
 
    name_index = D.axes[1]

    D_max = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index)

    for (ix, name) in enumerate(name_index)

        if name == devices[ix].name
            D_max[name] = @constraint(m, D[name] <= devices[ix].maxactivepower)

        else
            error("Bus name in Array and variable do not match")
        end

    end
    
    JuMP.register_object(m, :D_max, D_max)
        
end    
    
function thermalflowlimits(m::JuMP.Model, fbr, devices::Array{B,1}) where {B <: PowerSystems.Branch}

    name_index = fbr.axes[1]

    Flow_max_tf = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index)
    Flow_max_ft = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index)

    for (ix, name) in enumerate(name_index)
        if name == devices[ix].name
            Flow_max_tf[name] = @constraint(m, fbr[name] <= devices[ix].rate)
            Flow_max_ft[name] = @constraint(m, fbr[name] >= -devices[ix].rate)
        else
            error("Branch name in Array and variable do not match")
        end
    end

    JuMP.register_object(m, :Flow_max_ToFrom, Flow_max_tf)
    JuMP.register_object(m, :Flow_max_FromTo, Flow_max_ft)
        
end     
        
function anglelimits(m::JuMP.Model, θ, devices::Array{B,1}) where {B <: PowerSystems.Bus}

    name_index = θ.axes[1]

    θ_max = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index)
    θ_min = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index)

    for (ix, name) in enumerate(name_index)
        θ_max[name] = @constraint(m, θ[name] <= 1.04)
        θ_min[name] = @constraint(m, θ[name] >= -1.04)
    end

    JuMP.register_object(m, :θ_max, θ_max)
    JuMP.register_object(m, :θ_min, θ_min)
        
end      
            
function branch_flows(m::JuMP.Model, branches)            

    fl = m[:fl]

    name_index = fl.axes[1]

    flow_bal = JuMP.JuMPArray(Array{ConstraintRef}(undef, length(name_index)), name_index)

    for br in branches 

        flow_bal[br.name] = @constraint(m, fl[br.name] == (1/br.x)*(m[:θ][br.connectionpoints.from.name]-m[:θ][br.connectionpoints.to.name]))

    end      
   
    JuMP.register_object(m, :flow_bal, flow_bal)                    

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
    @variable(PM, P_th[set_gens], lower_bound = 0, start=0.0)
    @variable(PM, D[set_loads], lower_bound =  0) 
        
    for (ix,d) in enumerate(PM[:D])
        JuMP.set_start_value(d,loads[ix].maxactivepower)
    end

    @variable(PM, fl[set_lines], start=0.0) 

    #@variable(PM, z[set_lines] == 0.0, start=0.0) # add the Bin tag Later in order to make this code run with Ipopt

    @variable(PM, θ[set_buses], start=0.0);  
        
    for name in θ.axes[1][2:end]
        JuMP.set_lower_bound(θ[name],-1.57)
        JuMP.set_upper_bound(θ[name],1.57)
    end
        
    JuMP.fix(θ["Bus 1"],0.0)     
    
    #Constraints            
    generators_limits(PM, P_th, generators)
    thermalflowlimits(PM, fl, branches)
    anglelimits(PM, θ, buses)
    demand_limits(PM, D, loads)
    nodal_balance(PM, buses, branches, generators, loads) 
    branch_flows(PM, branches)             
                
    @objective(PM, Max, sum(D[i] for i in set_loads))            
                 
    return PM 
                
end 