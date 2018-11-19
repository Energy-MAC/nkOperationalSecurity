function dual_balance_bigM(m::JuMP.Model, buses, branches, generators, loads)
    
    dual_bal =  JumpAffineExpressionArray(undef, length(buses))

    bus_name_index = [b.name for b in buses]

    for n in buses

        !isassigned(dual_bal,n.number) ? dual_bal[n.number] = AffExpr(0.0) : true

        JuMP.add_to_expression!(dual_bal[n.number], (-m[:ν_minus][n.name] + m[:ν_plus][n.name]) )

    end

    for b in branches

       !isassigned(dual_bal,b.connectionpoints.from.number) ? dual_bal[b.connectionpoints.from.number] = AffExpr(0.0) : true 

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.from.number],( (-1)*m[:η][b.name]*(1/b.x) + (1/b.x)*m[:y][b.name] ))

       !isassigned(dual_bal,b.connectionpoints.to.number) ? dual_bal[b.connectionpoints.to.number] = AffExpr(0.0) : true     

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.to.number],(m[:η][b.name]*(1/b.x) - (1/b.x)*m[:y][b.name] ))

    end
    
    
    dual_balance = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(bus_name_index)), bus_name_index)

    for (ix,bus) in enumerate(bus_name_index[2:end])

        dual_balance[bus] = @constraint(m, dual_bal[ix] == 0)
        
    end

    JuMP.register_object(m, :Dual_Balance, dual_balance)

end


function dual_balance_bus1_bigM(m::JuMP.Model, buses, branches, generators, loads)
    dual_bal_bus1 =  AffExpr(0.0)

    bus_name_index = buses[1].name

    JuMP.add_to_expression!(dual_bal_bus1, m[:ζ] )
    
    br_aux = [br for br in branches if br.connectionpoints.from.number == 1]
    
    for b in br_aux
        JuMP.add_to_expression!(dual_bal_bus1,( (-1)*m[:η][b.name]*(1/b.x) + (1/b.x)*m[:y][b.name] ))
    end
    

    dual_balance_bus1 = @constraint(m, dual_bal_bus1 == 0)

    JuMP.register_object(m, :Dual_Balance_Bus1, dual_balance_bus1)
                
end
            
function bigM_constraints(m::JuMP.Model, devices, bigM)
    name_index = m[:η].axes[1]
    
    dual_bigM_one = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index) 
    dual_bigM_two = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index) 
    dual_bigM_three = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(name_index)), name_index) 

    for (ix, name) in enumerate(name_index)

        if name == devices[ix].name
            dual_bigM_one[name] = @constraint(m, m[:y][name] <= bigM*m[:z][name])
            dual_bigM_two[name] = @constraint(m, m[:y][name] <= m[:η][name])
            dual_bigM_three[name] = @constraint(m, m[:y][name] >= m[:η][name] - bigM*(1-m[:z][name]))         
        else
            error("Bus name in Array and variable do not match branches in BigM constraints")
        end
    end
    JuMP.register_object(m, :dual_bigM_one, dual_bigM_one)
    JuMP.register_object(m, :dual_bigM_two, dual_bigM_two) 
    JuMP.register_object(m, :dual_bigM_three, dual_bigM_three)

end
            
            
function dual_demand_bound(m, α_plus, α_minus, μ_plus, β_plus, ν_plus, ν_minus, branches, generators, loads, nodes)
        dual_obj = dual_objective(m, α_plus, α_minus, μ_plus, β_plus, ν_plus, ν_minus, branches, generators, loads, nodes)
        dual_obj_constraint = @constraint(m, dual_obj <= 0.9*2.57)
        JuMP.register_object(m, :Dual_obj_constraint, dual_obj_constraint)        
end