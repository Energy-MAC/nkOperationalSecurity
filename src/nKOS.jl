using JuMP
using PowerSystems
using Ipopt
using GLPK
using MathOptInterface

#const JumpVariable = JuMP.JuMPArray{JuMP.VariableRef,2,Tuple{Array{String,1},UnitRange{Int64}}}
#const JumpExpressionMatrix = Matrix{<:JuMP.GenericAffExpr}
const JumpAffineExpressionArray = Array{JuMP.GenericAffExpr{Float64,JuMP.VariableRef},1}
const JumpQuadExpressionArray = Array{JuMP.JuMP.GenericQuadExpr{Float64,JuMP.VariableRef},1}

#Code for system data
include("../data/data_14bus_pu.jl")
include("generate_118_bus.jl")

include("common.jl")
include("get_values.jl")

include("Nodal_balance_primal.jl")
include("Primal_problem.jl")

include("Nodal_balance_dual.jl")
include("Dual_problem.jl")

include("Nodal_balance_dual_bigM.jl")
include("bigM_version.jl")

include("Nodal_balance_dual_NL.jl")
include("NL_version.jl")

include("Nodal_balance_dual_lambda_continous.jl")
include("lambda_continous_version.jl")

include("Nodal_balance_dual_lambda_integer.jl")
include("lambda_integer_version.jl")