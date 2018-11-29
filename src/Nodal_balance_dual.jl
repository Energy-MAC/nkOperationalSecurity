function dual_balance_no_z(m::JuMP.Model, buses, branches, generators, loads)
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

        JuMP.add_to_expression!(dual_bal[n.number], (m[:ν_plus][n.name] - m[:ν_minus][n.name]) )

    end

    for b in branches

       !isassigned(dual_bal,b.connectionpoints.from.number) ? dual_bal[b.connectionpoints.from.number] = AffExpr(0.0) : true 

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.from.number],((0-1)*m[:η][b.name]*(1/b.x) ))

       !isassigned(dual_bal,b.connectionpoints.to.number) ? dual_bal[b.connectionpoints.to.number] = AffExpr(0.0) : true     

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.to.number],(-(0-1)*m[:η][b.name]*(1/b.x) ))

    end
    
    
    dual_balance = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(bus_name_index)), bus_name_index)

    for (ix,bus) in enumerate(bus_name_index[1:end])
        if bus != slackBus
            dual_balance[bus] = @constraint(m, dual_bal[ix] == 0)
        else
           dual_balance[bus] = @constraint(m, 0.0 == 0.0)    
        end 
        
    end

    JuMP.register_object(m, :Dual_Balance, dual_balance)

end
        

function dual_balance_bus1_no_z(m::JuMP.Model, buses, branches, generators, loads)
    #get slack bus
    slackBus=0
    slackNum=0
    for b in buses
        if b.bustype=="SF"
            slackBus = b.name
            slackNum = b.number
        end
    end
    
    dual_bal_bus1 =  AffExpr(0.0)

    bus_name_index = slackBus

    
    br_aux = [br for br in branches if br.connectionpoints.from.number == slackNum]
    
    for b in br_aux
        JuMP.add_to_expression!(dual_bal_bus1,( (0-1)*m[:η][b.name]*(1/b.x) ))
    end
    

    dual_balance_bus1 = @constraint(m, dual_bal_bus1 + m[:ζ] == 0)

    JuMP.register_object(m, :Dual_Balance_Bus1, dual_balance_bus1)
                
end


            
            

            
function dual_balance_fixed_z(m::JuMP.Model, buses, branches, generators, loads,z)
    #get slack bus
    slackBus=0
    for b in buses
        if b.bustype=="SF"
            slackBus = b.name
        end
    end
    
    dual_bal =  JumpAffineExpressionArray(undef, length(buses))

    bus_name_index = [b.name for b in buses]

    for n in buses

        !isassigned(dual_bal,n.number) ? dual_bal[n.number] = AffExpr(0.0) : true

        JuMP.add_to_expression!(dual_bal[n.number], (m[:ν_plus][n.name] - m[:ν_minus][n.name]) )

    end

    for (ix,b) in enumerate(branches)

       !isassigned(dual_bal,b.connectionpoints.from.number) ? dual_bal[b.connectionpoints.from.number] = AffExpr(0.0) : true 

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.from.number],((z[ix]-1)*m[:η][b.name]*(1/b.x) ))

       !isassigned(dual_bal,b.connectionpoints.to.number) ? dual_bal[b.connectionpoints.to.number] = AffExpr(0.0) : true     

       JuMP.add_to_expression!(dual_bal[b.connectionpoints.to.number],(-(z[ix]-1)*m[:η][b.name]*(1/b.x) ))

    end
                
    
    
    dual_balance = JuMP.JuMPArray(Array{ConstraintRef}(undef,length(bus_name_index)), bus_name_index)

    for (ix,bus) in enumerate(bus_name_index[1:end])
        if bus != slackBus
            dual_balance[bus] = @constraint(m, dual_bal[ix] == 0)
        end 
        
    end

    JuMP.register_object(m, :Dual_Balance, dual_balance)

end
        

function dual_balance_bus1_fixed_z(m::JuMP.Model, buses, branches, generators, loads,z)
    #get slack bus
    slackBus=0
    for b in buses
        if b.bustype=="SF"
            slackBus = b.name
        end
    end
    
    dual_bal_bus1 =  AffExpr(0.0)

    bus_name_index = slackBus

    
    br_aux = [br for br in branches if br.connectionpoints.from.number == 1]
    ix_aux = [ix for (ix,br) in enumerate(branches) if br.connectionpoints.from.number == 1]
    
                                        
    for i in range(1, length= length(br_aux))
        JuMP.add_to_expression!(dual_bal_bus1,( (z[ix_aux[i]]-1)*m[:η][br_aux[i].name]*(1/br_aux[i].x) ))
    end
    

    dual_balance_bus1 = @constraint(m, dual_bal_bus1 + m[:ζ] == 0)

    JuMP.register_object(m, :Dual_Balance_Bus1, dual_balance_bus1)
                
end

