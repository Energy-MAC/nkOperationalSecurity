function add_flows(m::JuMP.Model, netinjection, branches::Array{<:Branch}) 

    fbr = m[:fbr]
    branch_name_index = m[:fbr].axes[1]

    for t in time_index, (ix,branch) in enumerate(branch_name_index)

        !isassigned(netinjection.var_active,sys.branches[ix].connectionpoints.from.number) ? netinjection.var_active[sys.branches[ix].connectionpoints.from.number] = -fbr[branch] : JuMP.add_to_expression!(netinjection.var_active[sys.branches[ix].connectionpoints.from.number],-fbr[branch])
        !isassigned(netinjection.var_active,sys.branches[ix].connectionpoints.to.number) ? netinjection.var_active[sys.branches[ix].connectionpoints.to.number] = fbr[branch,t] : JuMP.add_to_expression!(netinjection.var_active[sys.branches[ix].connectionpoints.to.number],fbr[branch])

    end


end


function varnetinjectiterate!(netinjection::A, variable::JumpVariable, time_periods::Int64, devices::Array{T}) where {A <: JumpExpressionMatrix, T <: PowerSystems.Generator}

    for t in 1:time_periods, d in devices

        isassigned(netinjection,  d.bus.number,t) ? JuMP.add_to_expression!(netinjection[d.bus.number,t], variable[d.name, t]) : netinjection[d.bus.number,t] = variable[d.name, t];

    end

end

function varnetinjectiterate!(netinjection::A, variable::JumpVariable, time_periods::Int64, devices::Array{T}) where {A <: JumpExpressionMatrix, T <: PowerSystems.ElectricLoad}

    for t in 1:time_periods, d in devices

        isassigned(netinjection,  d.bus.number,t) ? JuMP.add_to_expression!(netinjection[d.bus.number,t], -1*variable[d.name, t]) : netinjection[d.bus.number,t] = -1*variable[d.name, t];

    end

end

function nodal_balance(m::JuMP.Model, buses, branches, generators, loads)
    
    d_netinjection_p =  JumpAffineExpressionArray(undef, length(buses))
    
    bus_name_index = [b.name for b in buses]
    
    add_flows(m, d_netinjection_p, branches)
    
    pf_balance = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(bus_name_index)), bus_name_index)

    for (ix,bus) in enumerate(bus_name_index)

        pf_balance[bus,t] = @constraint(m, d_netinjection_p[ix] == 0)
        
    end

    JuMP.register_object(m, :NodalFlowBalance, pf_balance)

end
    
    
    
function nodalflowbalance(m::JuMP.Model, netinjection::BalanceNamedTuple, system_formulation::Type{S}, sys::PowerSystems.PowerSystem) where {S <: AbstractDCPowerModel}

    time_index = 1:sys.time_periods
    bus_name_index = [b.name for b in sys.buses]

    add_flows(m, netinjection, system_formulation, sys)

    pf_balance = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(bus_name_index), sys.time_periods), bus_name_index, time_index)

        for t in time_index, (ix,bus) in enumerate(bus_name_index)

            isassigned(netinjection.var_active,ix, t) ? true : error("Islanded Bus in the system")

            pf_balance[bus,t] = @constraint(m, netinjection.var_active[ix, t] == netinjection.timeseries_active[ix, t])
        
        end

        JuMP.register_object(m, :NodalFlowBalance, pf_balance)

    return m
    
end    