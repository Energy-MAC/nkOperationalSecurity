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
    
function primal_problem(generators, buses, lines, loads)    
    #Instantiate Model
    ED = Model(with_optimizer(Ipopt.Optimizer))
    
    set_gens = [g.name for g in  generators14 if g.available]
    set_loads = [ld.name for ld in loads14 if ld.available] 
    set_lines = [ln.name for ln in branches14 if ln.available]
    set_buses = [b.name for b in nodes14]