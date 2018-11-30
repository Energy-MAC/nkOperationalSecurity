function dual_balance_bilinear(m::JuMP.Model, buses, branches, generators, loads)
    #get slack bus
    slackBus=0
    slackNum=0
    for b in buses
        if b.bustype=="SF"
            slackBus = b.name
        end
    end
    
    dual_bal =  JumpAffineExpressionArray(undef, length(buses))

    bus_name_index = [b.name for b in buses]

    for n in buses

        !isassigned(dual_bal,n.number) ? dual_bal[n.number] = AffExpr(0.0) : true

        JuMP.add_to_expression!(dual_bal[n.number], (-m[:ν_minus][n.name] + m[:ν_plus][n.name]) )

    end

    for b in branches

       !isassigned(dual_bal,b.connectionpoints.from.number) ? dual_bal[b.connectionpoints.from.number] = AffExpr(0.0) : true 

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.from.number],((m[:w][b.name]-m[:η][b.name])*(1/b.x) ))

       !isassigned(dual_bal,b.connectionpoints.to.number) ? dual_bal[b.connectionpoints.to.number] = AffExpr(0.0) : true     

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.to.number],(-(m[:w][b.name]-m[:η][b.name])*(1/b.x) ))

    end
    
    
    dual_balance = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(bus_name_index)), bus_name_index)

    for (ix,bus) in enumerate(bus_name_index[1:end])
        if bus != slackBus
            dual_balance[bus] = @constraint(m, dual_bal[ix] == 0)
        end
    end

    JuMP.register_object(m, :Dual_Balance, dual_balance)

end


function dual_balance_bus1_bilinear(m::JuMP.Model, buses, branches, generators, loads)
    dual_bal_bus1 =  AffExpr(0.0)
    #get slack bus
    slackBus=0
    slackNum=0
    for b in buses
        if b.bustype=="SF"
            slackBus = b.name
            slackNum = b.number
        end
    end
    bus_name_index = slackBus

    JuMP.add_to_expression!(dual_bal_bus1, m[:ζ] )
    
    br_aux = [br for br in branches if br.connectionpoints.from.number == slackNum]
    
    for b in br_aux
        JuMP.add_to_expression!(dual_bal_bus1,((m[:w][b.name]-m[:η][b.name])*(1/b.x) ))
    end
    

    dual_balance_bus1 = @constraint(m, dual_bal_bus1 == 0)

    JuMP.register_object(m, :Dual_Balance_Bus1, dual_balance_bus1)
                
end


function dual_bilinear_constraints_cont(m, branches)
    
    for b in branches
        relaxation_bilinear_cont(m, m[:η][b.name], m[:z][b.name], m[:w][b.name])
    end
    
end


function relaxation_bilinear_cont(m, x, z, w)
    x_ub = 5000
    x_lb = -5000

    L = @variable(m, [1:2], upper_bound = 1.0, lower_bound = 0.0)

    w_val = [x_lb 
             x_ub]
    
    @constraint(m, w == sum(w_val[i]*L[i] for i in 1:2))
    
    @constraint(m, x <= (L[1])*x_lb +
                        (L[2])*x_ub +x_ub*(1 - z) )
    @constraint(m, x >= (L[1])*x_lb +
                        (L[2])*x_ub + +x_lb*(1 - z))
    @constraint(m, sum(L) == z)
    
    
    
    
end