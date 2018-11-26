using Test
@test include("../src/nKOS.jl");

#=
@testset "Run basics" begin
    @test try   BM = bigM_version(generators14, nodes14, branches14, loads14, 5000); JuMP.optimize!(BM); true finally end
    @test try  NL = NL_version(generators14, nodes14, branches14, loads14); JuMP.optimize!(NL); true finally end
end
=#

@testset "Run NK Versions" begin
    @test try   BM = bigM_version(generators14, nodes14, branches14, loads14, 5000); JuMP.optimize!(BM); true finally end
    @test try  NL = NL_version(generators14, nodes14, branches14, loads14); JuMP.optimize!(NL); true finally end
end