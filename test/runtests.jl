using Test
@test include("../src/nKOS.jl");
@test try simple_lp() end
