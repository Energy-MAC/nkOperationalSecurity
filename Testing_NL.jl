using Pkg
Pkg.activate()
Pkg.instantiate()

include("src/nKOS.jl")
using Gurobi
using TimerOutputs


const to = TimerOutput()
sols = Dict()

ipopt_build = NL_version(generators14, nodes14, branches14, loads14, 0.95); JuMP.optimize!(ipopt_build)

BLi = NL_version(generators118, nodes118, branches118, loads118, 0.95);

@timeit to "0.95" JuMP.optimize!(BLi)
sols["0.95"] = JuMP.objective_value(BLi)

BLi = NL_version(generators118, nodes118, branches118, loads118, 0.90);

@timeit to "0.90" JuMP.optimize!(BLi)
sols["0.90"] = JuMP.objective_value(BLi)

BLi = NL_version(generators118, nodes118, branches118, loads118, 0.85);

@timeit to "0.85" JuMP.optimize!(BLi)
sols["0.85"] = JuMP.objective_value(BLi)

BLi = NL_version(generators118, nodes118, branches118, loads118, 0.80);

@timeit to "0.80" JuMP.optimize!(BLi)
sols["0.80"] = JuMP.objective_value(BLi)

BLi = NL_version(generators118, nodes118, branches118, loads118, 0.75);

@timeit to "0.75" JuMP.optimize!(BLi)
sols["0.75"] = JuMP.objective_value(BLi)

BLi = NL_version(generators118, nodes118, branches118, loads118, 0.70);

@timeit to "0.70" JuMP.optimize!(BLi)
sols["0.70"] = JuMP.objective_value(BLi)