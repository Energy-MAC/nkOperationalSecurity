function add_flows(m::JuMP.Model, netinjection, branches::Array{<:Branch}) 

    fbr = m[:fbr]
    branch_name_index = m[:fbr].axes[1]

    for t in time_index, (ix,branch) in enumerate(branch_name_index)

        !isassigned(netinjection.var_active,sys.branches[ix].connectionpoints.from.number) ? netinjection.var_active[sys.branches[ix].connectionpoints.from.number] = -fbr[branch] : JuMP.add_to_expression!(netinjection.var_active[sys.branches[ix].connectionpoints.from.number],-fbr[branch])
        !isassigned(netinjection.var_active,sys.branches[ix].connectionpoints.to.number) ? netinjection.var_active[sys.branches[ix].connectionpoints.to.number] = fbr[branch,t] : JuMP.add_to_expression!(netinjection.var_active[sys.branches[ix].connectionpoints.to.number],fbr[branch])

    end


end


function varnetinjectiterate!(netinjection::A, variable::JumpVariable, devices::Array{<: PowerSystems.Generator}) 
    for d in devices

        isassigned(netinjection,  d.bus.number,t) ? JuMP.add_to_expression!(netinjection[d.bus.number,t], variable[d.name, t]) : netinjection[d.bus.number,t] = variable[d.name, t];

    end

end

function varnetinjectiterate!(netinjection::A, variable::JumpVariable, devices::Array{T <: PowerSystems.ElectricLoad}})

    for d in devices

        isassigned(netinjection,  d.bus.number,t) ? JuMP.add_to_expression!(netinjection[d.bus.number,t], -1*variable[d.name, t]) : netinjection[d.bus.number,t] = -1*variable[d.name, t];

    end

end

function nodal_balance(m::JuMP.Model, buses, branches, generators, loads)
    
    d_netinjection_p =  JumpAffineExpressionArray(undef, length(buses))
    
    bus_name_index = [b.name for b in buses]
        
    varnetinjectiterate!(d_netinjection_p, m[:P_th], generators)
    varnetinjectiterate!(d_netinjection_p, m[:D], loads)
    
    add_flows(m, d_netinjection_p, branches)
    
    pf_balance = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(bus_name_index)), bus_name_index)

    for (ix,bus) in enumerate(bus_name_index)

        pf_balance[bus,t] = @constraint(m, d_netinjection_p[ix] == 0)
        
    end

    JuMP.register_object(m, :NodalFlowBalance, pf_balance)

end