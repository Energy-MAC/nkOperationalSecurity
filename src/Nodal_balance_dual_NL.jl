function dual_balance_zvar(m::JuMP.Model, buses, branches, generators, loads)
    
    dual_bal =  JumpQuadExpressionArray(undef, length(buses))

    bus_name_index = [b.name for b in buses]

    for n in buses

        !isassigned(dual_bal,n.number) ? dual_bal[n.number] = JuMP.GenericQuadExpr{Float64,VariableRef}() : true

        JuMP.add_to_expression!(dual_bal[n.number], (m[:ν_plus][n.name] - m[:ν_minus][n.name]) )

    end

    for b in branches

       !isassigned(dual_bal,b.connectionpoints.from.number) ? dual_bal[b.connectionpoints.from.number] = JuMP.GenericQuadExpr{Float64,VariableRef}() : true 

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.from.number],((m[:z][b.name]-1)*m[:η][b.name]*(1/b.x) ))

       !isassigned(dual_bal,b.connectionpoints.to.number) ? dual_bal[b.connectionpoints.to.number] = JuMP.GenericQuadExpr{Float64,VariableRef}() : true     

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.to.number],(-(m[:z][b.name]-1)*m[:η][b.name]*(1/b.x) ))

    end
    
    
    dual_balance = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(bus_name_index)), bus_name_index)

    for (ix,bus) in enumerate(bus_name_index[2:end])

        dual_balance[bus] = @constraint(m, dual_bal[ix] == 0)
        
    end

    JuMP.register_object(m, :Dual_Balance, dual_balance)

end
            


function dual_balance_bus1_zvar(m::JuMP.Model, buses, branches, generators, loads)
    dual_bal_bus1 =  JuMP.GenericQuadExpr{Float64,VariableRef}()

    bus_name_index = buses[1].name
    
    for b in [br for br in branches if br.connectionpoints.from.number == 1]
        JuMP.add_to_expression!(dual_bal_bus1,((m[:z][b.name]-1)*m[:η][b.name]*(1/b.x) ))
    end

    dual_balance_bus1 = @constraint(m, dual_bal_bus1 + m[:ζ] == 0)

    JuMP.register_object(m, :Dual_Balance_Bus1, dual_balance_bus1)
                
end