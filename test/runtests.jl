using Test
@test try include("../src/nKOS.jl"); true finally end;

#=
@testset "Run basics" begin
    @test try   BM = bigM_version(generators14, nodes14, branches14, loads14, 5000); JuMP.optimize!(BM); true finally end
    @test try  NL = NL_version(generators14, nodes14, branches14, loads14); JuMP.optimize!(NL); true finally end
end
=#

include("../src/nKOS.jl");
@testset "Run N-K Versions" begin
    @test try   BM = bigM_version(generators14, nodes14, branches14, loads14, 5000, 0.7); JuMP.optimize!(BM); true finally end
    @test try  NL = NL_version(generators14, nodes14, branches14, loads14, 0.7); JuMP.optimize!(NL); true finally end
end