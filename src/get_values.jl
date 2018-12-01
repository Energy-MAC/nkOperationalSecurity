function get_duals(m)
    ref = [element.first for element in m.obj_dict if isa(element.second,JuMPArray{ConstraintRef})]
    for c in ref
        key = Symbol(c)
        println(c,"")
            for ax in m.obj_dict[key]
                println(JuMP.dual(ax),"")
        end
    end
end

function get_primals(m)
    ref = [element.first for element in m.obj_dict if isa(element.second,JuMPArray{VariableRef})]
    for c in ref
        key = Symbol(c)
        println(c,"")
            for ax in m.obj_dict[key]
                println(JuMP.value(ax),"")
        end
    end
end
                        

function store_primals(m)
    result = Dict{Any,Any}()
    ref = [element.first for element in m.obj_dict if isa(element.second,JuMPArray{VariableRef})]
    for c in ref
        key = Symbol(c)
        result_array = []
            for ax in m.obj_dict[key]
                push!(result_array,JuMP.value(ax))
        end
        result[key] = result_array
    end
    return result
end