using PlotlyJS
using Dash
using DashBootstrapComponents


hm = heatmap( x = collect(0:10:1000),
             y = collect(0:10:1000),
             z = eachcol(map(x->(x[1]+x[2]), collect(Iterators.product(0:10:1000,1:10:1001)))),
             colorscale ="Greens",
             colorbar_thickness=20)

lns = scatter(x=[200, 200, 500],
                y=[200, 800, 500],
                mode="markers",
                marker_color="black")

            lout = PlotlyJS.Layout(width=600, height=600,
                   xaxis_range=[0,20], yaxis_range=[-1,10])
fig = plot([hm,lns]);
# plt = plot(lns)
# push!(plt.plot.data, hm)
# plt

# Paste the code to compute the vibration response here
#app = dash(external_stylesheets = ["/home/lik/proto/oilCraft/src/app.css"])
app = dash(external_stylesheets = [dbc_themes.BOOTSTRAP])
app.title = "Free response of a mass-spring system"
app.layout = dbc_container([
    dbc_row([
        dbc_col("OilCraft", style = Dict("margin-top" => 20, "border" => "0.5px solid")),
        dbc_col(
            dbc_row([
                html_div(className = "row",
                    html_div(className = "nine columns",
                        dcc_graph(id = "map", animate = true,
                        figure = fig
                        ))),
                html_div(className = "row1",
                    html_div(className = "six columns",
                        dcc_graph(
                        id = "graphic",
                        animate = true,
                        )
                    ))],
                    ), style = Dict("border" => "0.5px solid", "border-radius" => 5)
                ),
        dbc_col(
        dbc_row([
        html_label("Dropdown"),
        dcc_dropdown(options =  [1:5], value = "MTL"),

        html_div(style = Dict("border" => "0.5px solid", "border-radius" => 5, "margin-top" => 68), className = "three columns") do
            html_div(id = "freq-val",
                style = Dict("margin-top" => "15px", "margin-left" => "15px", "margin-bottom" => "5px")),
            dcc_slider(
                id = "freq-slider",
                min = 1.,
                max = 50.,
                step = 1,
                value = 10.,
                marks = Dict([i => ("$i") for i in [1, 10, 20, 30, 40, 50]])
            )
        end
        ])
        ),
        ])
    ])




        #
        #     html_div(id = "damp-val",
        #     style = Dict("margin-top" => "15px", "margin-left" => "15px", "margin-bottom" => "5px")),
        #     dcc_slider(
        #         id = "damp-slider",
        #         min = 1,
        #         max = 6,
        #         step = nothing,
        #         value = 1,
        #         marks = Dict([i => ("$(damping(i))") for i in 1:6])
        #     ),
        #
        #     html_div(id = "disp-val",
        #     style = Dict("margin-top" => "15px", "margin-left" => "15px", "margin-bottom" => "5px")),
        #     dcc_slider(
        #         id = "disp-slider",
        #         min = -1.,
        #         max = 1.,
        #         step = 0.1,
        #         value = 0.5,
        #         marks = Dict([i => ("$i") for i in [-1, 0, 1]])
        #     ),
        #
        #     html_div(id = "vel-val",
        #     style = Dict("margin-top" => "15px", "margin-left" => "15px",  "margin-bottom" => "5px")),
        #     dcc_slider(
        #         id = "vel-slider",
        #         min = -100.,
        #         max = 100.,
        #         step = 1.,
        #         value = 0.,
        #         marks = Dict([i => ("$i") for i in [-100, -50, 0, 50, 100]])
        #     )
        # end

        # html_div(className = "row",
        #     html_div(className = "six columns",
        #         dcc_graph(
        #         id = "graphic1",
        #         animate = true,
        #         )
        #     )
        #     )])

callback!(
    app,
    Output("map", "figure"),
    Input("map", "clickData"),
    #State("map", "figure")
) do pnt
    #points = clickData.points[1]
    if !isnothing(pnt)
        println(pnt)
        x = pnt["points"][1]["x"]
        y = pnt["points"][1]["y"]
        #fig.data
        println(x," ",y)
        #println(fig.plot.data[2].fields)
        #push!(fig.plot.data[2].fields[:x],x)
        #push!(fig.plot.data[2].fields[:y],y)

        lns1 = scatter(x=lns.fields[:x],
                        y=lns.fields[:y],
                        mode="markers",
                        marker_color="black")

        figure = (
        data = [(x = [100,200,300], y = [700,800,100])]
        )
        #plot([hm,lns1]);
    end
end

# callback!(
#     app,
#     Output("freq-val", "children"),
#     Input("freq-slider", "value")
# ) do freq_val
#     "Resonance frequency : $(freq_val) Hz"
# end
#
# callback!(
#     app,
#     Output("damp-val", "children"),
#     Input("damp-slider", "value")
# ) do damp_val
#     "Damping ratio : $(damping(damp_val))"
# end
#
# callback!(
#     app,
#     Output("disp-val", "children"),
#     Input("disp-slider", "value")
# ) do disp_val
#     "Initial displacement : $(disp_val) m"
# end
#
# callback!(
#     app,
#     Output("vel-val", "children"),
#     Input("vel-slider", "value")
# ) do vit_val
#     "Initial velocity : $(vit_val) m/s"
# end
#
# callback!(
#     app,
#     Output("fg", "figure"),
#     Input("freq-slider", "value"),
#     Input("damp-slider", "value"),
#     Input("disp-slider", "value"),
#     Input("vel-slider", "value")
# ) do f₀, ξ, x₀, v₀
#     #rep = response(f₀, damping(ξ), x₀, v₀)
#     figure = (
#         data = [(
#             x = collect(1:100),
#             y = collect(1:100),
#             z = eachcol(map(x->(x[1]+x[2]), collect(Iterators.product(1:100,2:101)))),
#             xtype = "array",
#             ytype = "array",
#             type = "heatmap",
#             # hoverlabel = Dict(
#             #     "font" => Dict(
#             #         "size" => 14
#             #     )
#             # )
#             )
#         ],
#         #layout =(
#             # xaxis = Dict(
#             #     "title" => "x",
#             #     "titlefont" => Dict(
#             #         "size" => 20
#             #     ),
#             #     "tickfont" => Dict(
#             #         "size" => 14
#             #     ),
#             # ),
#             # yaxis = Dict(
#             #     "title" => "y",
#             #     "titlefont" => Dict(
#             #         "size" => 20
#             #     ),
#             #     "tickfont" => Dict(
#             #         "size" => 14
#             #     ),
#             #     "range" => [minimum(rep), maximum(rep)],
#             #     "ticks" => "outside",
#             #     "tickcolor" => "white",
#             #     "ticklen" => 10
#             # ),
#         #)
#     )
# end

run_server(app, "0.0.0.0", 8050)
