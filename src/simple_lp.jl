function simple_lp(flag::Bool = false)
    lp = Model(with_optimizer(Cbc.CbcOptimizer))
    set1 = 1:10
    set2 = 3:5
    @variable(lp, x[set1] >= 0)
    @constraint(lp, constraint_lp[i = set2], x[i] >= 5)
    @constraint(lp, sum_constrain_lp, sum(3*x[k] for k in set2) >= 13)
    @constraint(lp, constraint_lp2[i = setdiff(set1, set2)], x[i] <= 3)
    @objective(lp, Min, (sum(x[i] for i in set2) - sum(x[i] for i in setdiff(set1, set2))))
    optimize!(lp)
    return lp
end

function get_solution(m::JuMP.Model)
    #assumes the variables are named x 
    if JuMP.primal_status(model) != 1 
        @error("the model is not properly solved")
    end
    
    for var in m[:x]
        prinln(var)
    end
end
    
function simple_lp(flag::Bool = true)
    c = [1; 3; 5; 2] 

    A= [
         1 1 9 5;
         3 5 0 8;
         2 0 6 13
        ]

    b = [7; 3; 5] 

    m, n = size(A); # m = number of rows of A, n = number of columns of A

    model = JuMP.Model(with_optimizer(GLPK.Optimizer))
    @variable(model, x[1:n] >= 0) 
    @constraint(model, [i=1:m], sum(A[i,j]*x[j] for j in 1:n) == b[i])
    @objective(model, Min, sum(c[j]*x[j] for j in 1:n)) 
    optimize!(model)
    return model
end