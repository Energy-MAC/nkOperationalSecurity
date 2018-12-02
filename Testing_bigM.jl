using Pkg
Pkg.activate()
Pkg.instantiate()

include("src/nKOS.jl")
using Gurobi
using TimerOutputs

const to = TimerOutput()
sols = Dict()
gap = Dict()

BLi = bigM_version(generators118, nodes118, branches118, loads118, 1000, 0.95, with_optimizer(Gurobi.Optimizer));

@timeit to "0.95" JuMP.optimize!(BLi)
sols["0.95"] = JuMP.objective_value(BLi)
gap["0.95"] = (MathOptInterface.get(BLi, MathOptInterface.ObjectiveBound()) - JuMP.objective_value(BLi))/JuMP.objective_value(BLi)

BLi = bigM_version(generators118, nodes118, branches118, loads118, 1000, 0.90, with_optimizer(Gurobi.Optimizer));

@timeit to "0.90" JuMP.optimize!(BLi)
sols["0.90"] = JuMP.objective_value(BLi)
gap["0.90"] = (MathOptInterface.get(BLi, MathOptInterface.ObjectiveBound()) - JuMP.objective_value(BLi))/JuMP.objective_value(BLi)

BLi = bigM_version(generators118, nodes118, branches118, loads118, 1000, 0.85, with_optimizer(Gurobi.Optimizer));

@timeit to "0.85" JuMP.optimize!(BLi)
sols["0.85"] = JuMP.objective_value(BLi)
gap["0.85"] = (MathOptInterface.get(BLi, MathOptInterface.ObjectiveBound()) - JuMP.objective_value(BLi))/JuMP.objective_value(BLi)

BLi = bigM_version(generators118, nodes118, branches118, loads118, 1000, 0.80, with_optimizer(Gurobi.Optimizer));

@timeit to "0.80" JuMP.optimize!(BLi)
sols["0.80"] = JuMP.objective_value(BLi)
gap["0.80"] = (MathOptInterface.get(BLi, MathOptInterface.ObjectiveBound()) - JuMP.objective_value(BLi))/JuMP.objective_value(BLi)

BLi = bigM_version(generators118, nodes118, branches118, loads118, 1000, 0.75, with_optimizer(Gurobi.Optimizer));

@timeit to "0.75" JuMP.optimize!(BLi)
sols["0.75"] = JuMP.objective_value(BLi)
gap["0.75"] = (MathOptInterface.get(BLi, MathOptInterface.ObjectiveBound()) - JuMP.objective_value(BLi))/JuMP.objective_value(BLi)

BLi = bigM_version(generators118, nodes118, branches118, loads118, 1000, 0.70, with_optimizer(Gurobi.Optimizer));

@timeit to "0.70" JuMP.optimize!(BLi)
sols["0.70"] = JuMP.objective_value(BLi)
gap["0.70"] = (MathOptInterface.get(BLi, MathOptInterface.ObjectiveBound()) - JuMP.objective_value(BLi))/JuMP.objective_value(BLi)