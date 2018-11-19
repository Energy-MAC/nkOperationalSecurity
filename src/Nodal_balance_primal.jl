function add_flows(m::JuMP.Model, netinjection, branches::Array{<:Branch}) 

    fbr = m[:fbr]
    branch_name_index = m[:fbr].axes[1]




end


function nodal_balance(m::JuMP.Model, buses, branches, generators, loads)
    
    netinjection =  JumpAffineExpressionArray(undef, length(buses))

    bus_name_index = [b.name for b in buses]

    for d in generators

        !isassigned(netinjection,d.bus.number) ? netinjection[d.bus.number] = AffExpr(0.0) : true

        JuMP.add_to_expression!(netinjection[d.bus.number], m[:P_th][d.name])

    end

    for d in loads

        !isassigned(netinjection,d.bus.number) ? netinjection[d.bus.number] = AffExpr(0.0) : true

        JuMP.add_to_expression!(netinjection[d.bus.number], -1*m[:D][d.name])

    end
    
    for b in branches

       !isassigned(netinjection,b.connectionpoints.from.number) ? netinjection[b.connectionpoints.from.number] = AffExpr(0.0) : true 

       JuMP.add_to_expression!(netinjection[b.connectionpoints.from.number],-m[:fl][b.name])

       !isassigned(netinjection,b.connectionpoints.to.number) ? netinjection[b.connectionpoints.to.number] = AffExpr(0.0) : true     

       JuMP.add_to_expression!(netinjection[b.connectionpoints.to.number],m[:fl][b.name])

    end
    
    
    pf_balance = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(bus_name_index)), bus_name_index)

    for (ix,bus) in enumerate(bus_name_index)

        pf_balance[bus] = @constraint(m, netinjection[ix] == 0)
        
    end

    JuMP.register_object(m, :NodalFlowBalance, pf_balance)

end