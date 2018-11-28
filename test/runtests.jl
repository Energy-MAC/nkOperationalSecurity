using Test
@test try include("../src/nKOS.jl"); true finally end;

include("../src/nKOS.jl");

@testset "Run basics" begin
    for k in 1:14
    @test try        
        s = setdiff!(collect(1:length(branches14)), [k])
        branches_k = branches14[s]
        PP = primal_problem(generators14, nodes14, branches_k, loads14, with_optimizer(GLPK.Optimizer))
        DP = dual_problem(generators14, nodes14, branches_k, loads14, with_optimizer(GLPK.Optimizer))
        JuMP.optimize!(PP)
        JuMP.optimize!(DP)
        println(isapprox(JuMP.objective_value(PP), JuMP.objective_value(DP), atol=1e-1)) 
        isapprox(JuMP.objective_value(PP), JuMP.objective_value(DP), atol=1e-1)
        finally
        end
    end
end

@testset "Run N-K Versions" begin
    @test try   BM = bigM_version(generators14, nodes14, branches14, loads14, 5000, 0.7); JuMP.optimize!(BM); true finally end
    @test try  NL = NL_version(generators14, nodes14, branches14, loads14, 0.7); JuMP.optimize!(NL); true finally end
end