using Test
@test try include("../src/nKOS.jl"); true finally end;


@testset "Run basics" begin
    for k in 1:14
    @test try        
        s = setdiff!(collect(1:14), [k])
        branches_k = branches14[s]
        PP = primal_problem(generators14, nodes14, branches_k, loads14, with_optimizer(GLPK.Optimizer, msg_lev = GLPK.MSG_ALL))
        DP = dual_problem(generators14, nodes14, branches_k, loads14, with_optimizer(GLPK.Optimizer, msg_lev = GLPK.MSG_ALL))
        JuMP.optimize!(PP)
        println(JuMP.primal_status(PP), " ", JuMP.objective_value(PP))
        JuMP.optimize!(DP)
        println(JuMP.primal_status(DP), " ", JuMP.objective_value(DP))
        @assert isapprox(JuMP.objective_value(PP), JuMP.objective_value(DP))
        end
    end
end


include("../src/nKOS.jl");
@testset "Run N-K Versions" begin
    @test try   BM = bigM_version(generators14, nodes14, branches14, loads14, 5000, 0.7); JuMP.optimize!(BM); true finally end
    @test try  NL = NL_version(generators14, nodes14, branches14, loads14, 0.7); JuMP.optimize!(NL); true finally end
end