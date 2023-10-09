function check_tlb(rows)
    well_id = get.(rows,:wi,-1)
    x_tlb = convert(Array{Any,1}, get.(rows,:xx,-1))
    y_tlb = convert(Array{Any,1}, get.(rows,:yy,-1))
    flag = trues(length(x_tlb))
    for (k,v) in enumerate(x_tlb)
        if typeof(v) == String
            x_tlb[k] = tryparse(Float64, v)
        end
        if isnothing(x_tlb[k])
            flag[k] = false
        elseif x_tlb[k]<0
            flag[k] = false
        else
            flag[k] = true
        end
    end
    for (k,v) in enumerate(y_tlb)
        if typeof(v) == String
            y_tlb[k] = tryparse(Float64, v)
        end
        if isnothing(y_tlb[k])
            flag[k] = false
        elseif y_tlb[k]<0
            flag[k] = false
        else
            flag[k] = true & flag[k]
        end
    end
    #flag .= .&(x_tlb.>=0, y_tlb.>=0)
    return well_id[flag], x_tlb[flag], y_tlb[flag]
end

function make_empty_tlb()
    tlb = Vector{Dict}(undef,5)
    for iw in 1:5
        tlb[iw] = Dict(Symbol("wi")=>iw, Symbol("xx")=>"", Symbol("yy")=>"")
    end

    well_clm = [Dict("name"=>"№", "id"=>"wi"),
                Dict("name"=>"X", "id"=>"xx"),
                Dict("name"=>"Y", "id"=>"yy")]
    return tlb, well_clm
end
#
# html_table([
#    html_thead(html_tr(html_th.(["№","x","y"]))),
#    html_tbody([html_tr(html_td.([1, 500, 500])),
#                html_tr(html_td.([2, 250, 255]))])
#        ],
#    )
