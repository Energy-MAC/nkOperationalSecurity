using JuMP
using PowerSystems
using SCS
using Ipopt
using GLPK

const JumpVariable = JuMP.JuMPArray{JuMP.VariableRef,2,Tuple{Array{String,1},UnitRange{Int64}}}
const JumpExpressionMatrix = Matrix{<:JuMP.GenericAffExpr}
const JumpAffineExpressionArray = Array{JuMP.GenericAffExpr{Float64,JuMP.VariableRef},2}

include("simple_lp.jl")
include("../data/data_14bus_pu.jl")