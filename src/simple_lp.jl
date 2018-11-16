function simple_lp(flag::Bool = false)
    lp = Model(with_optimizer(GLPK.Optimizer))
    set1 = 1:10
    set2 = 3:5
    @variable(lp, x[set1] >= 0)
    @constraint(lp, constraint_lp[i = set2], x[i] >= 5)
    @constraint(lp, sum_constrain_lp, sum(3*x[k] for k in set2) <= 13)
    @constraint(lp, constraint_lp2[i = setdiff(set1, set2)], x[i] <= 3)
    @objective(lp, Min, (sum(x[i] for i in set2) - sum(x[i] for i in setdiff(set1, set2))))
    optimize!(lp)
    return lp
end

function simple_ed()
   ED = Model(with_optimizer(Ipopt.Optimizer))
   set_gens = [g.name for g in  generators14 if g.available]
   @variable(ED, P_th[set_gens] >= 0)
   @constraint(ED, P_max[i = set_gens], P_th[i] <= [g.tech. activepowerlimits.max for g in generators14 if g.name == i][1])
   @constraint(ED, Balance, sum(P_th[i] for i in set_gens)== sum(loads14[j].maxactivepower for j in 1:length(loads14)))
   @objective(ED, Min, sum(generators14[i].econ.variablecost(P_th[generators14[i].name]) for i in 1:length(generators14)))
   JuMP.optimize!(ED)
   
   for var in ED[:P_th]
        println(var, JuMP.value(var))
   end
    
    
end