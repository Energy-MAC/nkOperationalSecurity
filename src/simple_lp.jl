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
    @constraint(model, [i=1:m], sum(A[i,j]*x[j] for j in 1:n) <= b[i])
    @objective(model, Max, sum(c[j]*x[j] for j in 1:n)) 
    optimize!(model)
    return model
end


function get_solution(m::JuMP.Model)
    #assumes the variables are named x 
    if JuMP.primal_status(model) != 1 
        @error("the model is not properly solved")
    end
    
    for var in m[:x]
        println(Jump.value(var))
    end
end
 