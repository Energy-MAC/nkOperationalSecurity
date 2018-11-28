using JuMP
using PowerSystems
using Ipopt
using GLPK

#const JumpVariable = JuMP.JuMPArray{JuMP.VariableRef,2,Tuple{Array{String,1},UnitRange{Int64}}}
#const JumpExpressionMatrix = Matrix{<:JuMP.GenericAffExpr}
const JumpAffineExpressionArray = Array{JuMP.GenericAffExpr{Float64,JuMP.VariableRef},1}
const JumpQuadExpressionArray = Array{JuMP.JuMP.GenericQuadExpr{Float64,JuMP.VariableRef},1}

include("simple_lp.jl")
include("../data/data_14bus_pu.jl")
include("Nodal_balance_primal.jl")
include("Primal_problem.jl")
include("Nodal_balance_dual.jl")
include("Dual_problem.jl")
include("common.jl")
include("Nodal_balance_dual_bigM.jl")
include("Full_problem_bigM.jl")
include("get_values.jl")
include("get_values.jl")
include("Nodal_balance_dual_NL.jl")
include("NL_version.jl")
include("generate_118_bus.jl")
