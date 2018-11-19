function dual_balance_zvar(m::JuMP.Model, buses, branches, generators, loads)
    
    dual_bal =  JumpAffineExpressionArray(undef, length(buses))

    bus_name_index = [b.name for b in buses]

    for n in buses

        !isassigned(dual_bal,n.number) ? dual_bal[n.number] = AffExpr(0.0) : true

        JuMP.add_to_expression!(dual_bal[n.number], (-m[:ν_minus _plus][n.name] + m[:ν_minus][n.name]) )

    end

    for b in branches

       !isassigned(dual_bal,b.connectionpoints.from.number) ? dual_bal[b.connectionpoints.from.number] = AffExpr(0.0) : true 

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.from.number],((z[b.name]-1)*m[:η][b.name]*(1/b.x) ))

       !isassigned(dual_bal,b.connectionpoints.to.number) ? dual_bal[b.connectionpoints.to.number] = AffExpr(0.0) : true     

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.to.number],(-(z[b.name]-1)*m[:η][b.name]*(1/b.x) ))

    end
    
    
    dual_balance = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(bus_name_index)), bus_name_index)

    for (ix,bus) in enumerate(bus_name_index[2:end])

        dual_balance[bus] = @constraint(m, dual_bal[ix] == 0)
        
    end

    JuMP.register_object(m, :Dual_Balance, dual_balance)

end
            
function dual_balance_bus1(m::JuMP.Model, buses, branches, generators, loads)
    dual_bal_bus1 =  AffExpr(0.0)

    bus_name_index = buses[1].name

    JuMP.add_to_expression!(dual_bal_bus1, m[:ζ] )
    
    for b in [br for br in branches if b.connectionpoints.from.number == 1]
        JuMP.add_to_expression!(dual_bal_bus1,( (z[b.name]-1)*m[:η][b.name]*(1/b.x) ))
    end
    

    dual_balance_bus1 = @constraint(m, dual_bal_bus1 == 0)

    JuMP.register_object(m, :Dual_Balance_Bus1, dual_balance_bus1)
                
end


    
function dual_balance_no_z(m::JuMP.Model, buses, branches, generators, loads)
    
    dual_bal =  JumpAffineExpressionArray(undef, length(buses))

    bus_name_index = [b.name for b in buses]

    for n in buses

        !isassigned(dual_bal,n.number) ? dual_bal[n.number] = AffExpr(0.0) : true

        JuMP.add_to_expression!(dual_bal[n.number], (m[:ν_plus][n.name] - m[:ν_minus][n.name]) )

    end

    for b in branches

       !isassigned(dual_bal,b.connectionpoints.from.number) ? dual_bal[b.connectionpoints.from.number] = AffExpr(0.0) : true 

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.from.number],((0-1)*m[:η][b.name]*(1/b.x) ))

       !isassigned(dual_bal,b.connectionpoints.to.number) ? dual_bal[b.connectionpoints.to.number] = AffExpr(0.0) : true     

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.to.number],(-(0-1)*m[:η][b.name]*(1/b.x) ))

    end
    
    
    dual_balance = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(bus_name_index)), bus_name_index)

    for (ix,bus) in enumerate(bus_name_index[2:end])

        dual_balance[bus] = @constraint(m, dual_bal[ix] == 0)
        
    end

    JuMP.register_object(m, :Dual_Balance, dual_balance)

end
        

function dual_balance_bus1_no_z(m::JuMP.Model, buses, branches, generators, loads)
    dual_bal_bus1 =  AffExpr(0.0)

    bus_name_index = buses[1].name

    JuMP.add_to_expression!(dual_bal_bus1, m[:ζ] )
    
    br_aux = [br for br in branches if br.connectionpoints.from.number == 1]
    
    for b in br_aux
        JuMP.add_to_expression!(dual_bal_bus1,( (0-1)*m[:η][b.name]*(1/b.x) ))
    end
    

    dual_balance_bus1 = @constraint(m, dual_bal_bus1 == 0)

    JuMP.register_object(m, :Dual_Balance_Bus1, dual_balance_bus1)
                
end

                