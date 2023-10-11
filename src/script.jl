using PlotlyJS
using Dash
#using Plots
#plotly()
#using Plotly
using DashBootstrapComponents
push!(LOAD_PATH, joinpath(Base.source_dir(),"../../ITPM_SimX.jl"))
using ITPM_SimX, StatsBase


include(joinpath(Base.source_dir(),"libs.jl"))

nw = 6;
well_tlb, well_clm = make_empty_tlb(nw)
well_id, well_x, well_y = check_tlb(well_tlb)
kin_figure = kin_fig()

lns = scatter(x=well_x,
                y=well_y,
                mode="markers",
                marker_color="black")
#z0 = zeros(101,101); z0[51,51] = 10

# rsl, kin = get_srf();
# PM = rsl.PM
# qw = rsl.qw
PM = 10 .*ones(Float32, 10000, 61)
z0 = Float64.(reshape(PM[:,1],100,100))

hm = heatmap(x = collect(5:10:1000),
             y = collect(5:10:1000),
             z = z0,
             zmin= 0,
             zmax= 15,
             colorscale ="Greens",
             colorbar_thickness=10,
              uirevision = true)
fig = Plot([hm, lns]);
fig.data[1][:z] = [c for c in eachcol(fig.data[1][:z])] # <-- As a temporary

#update(fig)
#Dict(1=>1, 2=>3, 3=>4), Dict(1=>5, 2=>4, 3=>10)

# Paste the code to compute the vibration response here
#app = dash(external_stylesheets = ["/home/lik/proto/oilCraft/src/app.css"])
app = dash(external_stylesheets = [dbc_themes.BOOTSTRAP])
app.title = "Free response of a mass-spring system"
app.layout = dbc_container([
    dbc_row([
        dbc_col("OilCraft", style = Dict("margin-top" => 20, "border" => "0.5px solid")),
        dbc_col(
            dbc_row([
                dcc_graph(id = "map1", animate = true,
                        figure = fig
                        ),
                dcc_slider(id = "time_slider",
                       min = 0,
                       max = 60,
                       step = 1,
                       value = 0,
                       marks = Dict([i => ("$i") for i in [0, 12, 24, 36, 48, 60]])
                       ),
                 html_button(id="run_button", n_clicks=0, children = "run"),
                 dash_datatable(id = "tlb1",
                 columns = well_clm,
                 data = well_tlb,
                 editable = true,
                 row_deletable = false),
                 #dcc_input(id = "input-1-state", type = "text", value = "Montreal"),
                 html_div(id = "output-state"),
                 ], style = Dict("border" => "0.5px solid", "border-radius" => 5)

        )),
        dbc_col(
            dcc_graph(
                id = "kin",
                animate = true,
                figure = kin_figure)
                )
    ])])

callback!(
    app,
    #Output("map1", "figure"),
    Output("tlb1", "data"),
    Input("map1", "clickData"),
    State("map1", "figure"),
    State("tlb1", "data")
) do clickData, x2, tlb_data
    #points = clickData.points[1]
    println("hi")
    #println(clickData)
    # println("h2")
    # println(x2)
    if isnothing(clickData)
        PreventUpdate()
    else
        #if length(tlb_data)<5
            points = clickData["points"][1]
            x = points["x"]
            y = points["y"]

            # get scatter trace (in this case it's the last trace)
            #println(x2.data[2])
            well_id, well_x, well_y = check_tlb(tlb_data)
            #scatter_x = x2.data[2]["x"]
            #scatter_y = x2.data[2]["y"]
            wi_out = collect(1:nw)
            x_out = zeros(nw).-1
            y_out = zeros(nw).-1

            id = indexin(well_id, wi_out)
            x_out[id] = well_x
            y_out[id] = well_y

            empty_wi = setdiff(wi_out, well_id)
            if length(empty_wi)>0
                x_out[empty_wi[1]] = x
                y_out[empty_wi[1]] = y
            end
            #x_new = vcat(well_x, x)
            #y_new = vcat(well_y, y)
            #well_id_new = vcat(well_id, maximum(well_id)+1)
            #println(x_out)
            # update figure data (in this case it's the last trace)
            # println(typeof(x2))
            # println(typeof(fig))
            tlb_data = copy(tlb_data)
            #println(tlb_data)
            for (k,v) in enumerate(tlb_data)
                ia = findfirst(v[:wi].==wi_out)
                v[:xx] = x_out[ia]
                v[:yy] = y_out[ia]
            end

            lns = scatter(x=x_out,
                            y=y_out,
                            mode="markers",
                            marker_color="black")


            x2 = plot([hm, lns]);
        #else

        #end

    end
    return tlb_data
end

# callback!(
#     app,
#     Output("map1", "figure"),
#     Input("tlb1", "data")
# ) do tlb_data
#     well_id, x_tlb, y_tlb = check_tlb(tlb_data)
#     lns = scatter(x=x_tlb,
#                     y=y_tlb,
#                     mode="markers",
#                     marker_color="black")
#
#     x2 = plot([hm, lns]);
#     return x2
# end

callback!(
    app,
    Output("map1", "figure"),
    #Output("kin", "figure"),
    Input("time_slider", "value"),
    Input("tlb1", "data"),
    State("map1", "figure")
) do time_val, tlb_data, fig1

    well_id, x_tlb, y_tlb = check_tlb(tlb_data)
    # if length(x_tlb)!=5
    #     kin = zeros(61)
    # else
    #     wxy = collect(zip(x_tlb, y_tlb))
    #     rsl, kin = get_srf(wxy);
    #     PM[:,2:end] .= rsl.PM
    # end

    z0 .= reshape(PM[:,time_val+1],100,100)'
    hm = heatmap(x = collect(5:10:1000),
             y = collect(5:10:1000),
             z = z0,
             colorscale ="Greens",
             colorbar_thickness=20,
             uirevision = true)

    lns = scatter(x=x_tlb,
                 y=y_tlb,
                 mode="markers",
                 marker_color="black")

    x2 = Plot([hm, lns]);
    # fig1 = copy(fig1)
    #println(typeof(fig1))
    #println(keys(fig1))
    x2.data[1][:z] = [c for c in eachcol(z0)] # <-- As a temporary
    #fig1 = copy(x2)
    #x2 = (data = x2.data, layout = x2.layout.fields)
    #update!(fig)
    #update!(fig; layout = x2.layout)
    #update_traces!(fig)
    #PreventUpdate()
    #end
    # figure = (
    #     data = [(
    #         x = collect(1:time_val),
    #         y = kin[1:time_val],
    #         type = "line",
    #         hoverlabel = Dict(
    #             "font" => Dict("size" => 12)
    #         )
    #         )
    #     ],
    #     layout =(
    #         xaxis = Dict(
    #             "title" => "Месяц",
    #             "titlefont" => Dict(
    #                 "size" => 14
    #             ),
    #             "tickfont" => Dict(
    #                 "size" => 12
    #             ),
    #             "range" => [0, 60],
    #         ),
    #         yaxis = Dict(
    #             "title" => "Кин д.ед.",
    #             "titlefont" => Dict(
    #                 "size" => 14
    #             ),
    #             "tickfont" => Dict(
    #                 "size" => 12
    #             ),
    #             "range" => [0, 1],
    #             "ticks" => "outside",
    #             "tickcolor" => "white",
    #             "ticklen" => 10
    #         ),
    #     )
    # )

    return x2#, figure
end

callback!(
    app,
    Output("kin", "figure"),
    Input("run_button", "n_clicks"),
    State("tlb1", "data"),
    State("time_slider", "value"),
    State("kin", "figure")
) do n_clicks, tlb_data, time_val, kin_figure

    if n_clicks > 0
        well_id, x_tlb, y_tlb = check_tlb(tlb_data)
        kin = zeros(61)
        kin1 = zeros(61)
        kin2 = zeros(61)
        if length(x_tlb)==nw
            println("sim")
            wxy = collect(zip(x_tlb, y_tlb))
            rsl, kin, kin1, kin2 = get_srf(wxy);
            PM[:,2:end] .= rsl.PM
        end

        kin_figure = copy(kin_figure)
        println(kin_figure)
        kin_figure[:data][1][:x]=1:60
        kin_figure[:data][1][:y]=kin
        push!(kin_figure[:data],copy(kin_figure[:data][1]))
        push!(kin_figure[:data],copy(kin_figure[:data][1]))
        kin_figure[:data][2][:y]=kin1
        kin_figure[:data][3][:y]=kin2
        return kin_figure
    end
    return kin_figure
end

run_server(app, "0.0.0.0", 8050, debug=true)
