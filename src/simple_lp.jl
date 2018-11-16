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

function get_solution(m::JuMP.Model)
    #assumes the variables are named x 
    if JuMP.primal_status(m) != 1 
        @error("the model is not properly solved")
    end
    
    for var in m[:x]
        println(var, JuMP.value(var))
    end
end