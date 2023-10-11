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

function make_empty_tlb(nw=5)
    tlb = Vector{Dict}(undef,nw)
    for iw in 1:nw
        tlb[iw] = Dict(Symbol("wi")=>iw, Symbol("xx")=>"", Symbol("yy")=>"")
    end

    well_clm = [Dict("name"=>"№", "id"=>"wi"),
                Dict("name"=>"X", "id"=>"xx"),
                Dict("name"=>"Y", "id"=>"yy")]
    return tlb, well_clm
end

function kin_fig()
    figure = (
        data = [(
            x = [],
            y = [],
            type = "line",
            hoverlabel = Dict(
                "font" => Dict("size" => 12)
            )
            )
        ],
        layout =(
            xaxis = Dict(
                "title" => "Месяц",
                "titlefont" => Dict(
                    "size" => 14
                ),
                "tickfont" => Dict(
                    "size" => 12
                ),
                "range" => [0, 60],
            ),
            yaxis = Dict(
                "title" => "КИН д.ед.",
                "titlefont" => Dict(
                    "size" => 14
                ),
                "tickfont" => Dict(
                    "size" => 12
                ),
                "range" => [0, 1],
                "ticks" => "outside",
                "tickcolor" => "white",
                "ticklen" => 10
            ),
        )
    )
    return figure
end
#
# html_table([
#    html_thead(html_tr(html_th.(["№","x","y"]))),
#    html_tbody([html_tr(html_td.([1, 500, 500])),
#                html_tr(html_td.([2, 250, 255]))])
#        ],
#    )

function get_srf(wxy)
    grd, gdm_prop, prp, x, nt = make_gdm(kp_init = 10,
                                         he_init = 1,
                                         nt_init = 60,
                                         nx_init = 100,
                                         ny_init = 100,
                                         Lx_init = 1000,
                                         Ly_init = 1000)

    #
    gdm_sat = make_gdm_prop_sat(mu_o = 3)
    #wxy9 = collect(Iterators.product(x,x))[:]
    well = make_well(wxy,grd)
    nw = length(well)

    satf = calc_sat_step(prp, grd, gdm_prop, gdm_sat, well, nt)
    sim_calc = make_sim2f(grd, gdm_prop, well, prp, nt, satf)

    qw = rand(0.:2.:64., nw, nt);
    #qw[[1,3,7,9],:] .= (-abs.(qw[[1,3,7,9],:]).-10);
    #qw[[2,4,5,6,8],:] .= abs.(qw[[2,4,5,6,8],:].+10);
    #qw[5,:] .= 72
    qw .= mean(qw,dims=2)

    rsl = sim_calc(qw = qw)
    wtc = calc_wtc(rsl.SW, gdm_sat.fkrp, well);
    wtc[rsl.qw .< 0.0] .= 0.0;
    qo = rsl.qw.*(1 .- wtc);  qo[rsl.qw .< 0.0] .= 0.0;

    kin = cumsum(sum(qo, dims=1)[:])/(sum(prp.Vp.*(1.0 .- gdm_sat.Sw0))).*gdm_prop.dt
    kin1 = cumsum(sum(qo[1:2:end,:], dims=1)[:])/(sum(prp.Vp.*(1.0 .- gdm_sat.Sw0))).*gdm_prop.dt
    kin2 = cumsum(sum(qo[2:2:end,:], dims=1)[:])/(sum(prp.Vp.*(1.0 .- gdm_sat.Sw0))).*gdm_prop.dt
    return rsl, kin, kin1, kin2
end
