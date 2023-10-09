using PlotlyJS
using Dash
#using Plotly
using DashBootstrapComponents

include(joinpath(Base.source_dir(),"libs.jl"))
well_tlb, well_clm = make_empty_tlb()
well_id, well_x, well_y = check_tlb(well_tlb)

lns = scatter(x=well_x,
                y=well_y,
                mode="markers",
                marker_color="black")

hm = heatmap(x = collect(0:10:1000),
             y = collect(0:10:1000),
             z = zeros(101,101),
             colorscale ="Greens",
             colorbar_thickness=20)
fig = plot([hm, lns]);
fig.plot.data[2].fields

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
                html_div(className = "nine columns",
                        dcc_graph(id = "map1", animate = true,
                        figure = fig
                        )),
                 dash_datatable(id = "tlb1",
                 columns = well_clm,
                 data = well_tlb,
                 editable = true,
                 row_deletable = false),
                 #html_button(id="editing-rows-button", children = "submit", n_clicks=0),
                 #dcc_input(id = "input-1-state", type = "text", value = "Montreal"),
                 html_div(id = "output-state"),
                 ], style = Dict("border" => "0.5px solid", "border-radius" => 5)

        ))
    ])])

# callback!(
#     app,
#     Output("map1", "figure"),
#     Output("tlb1", "data"),
#     Input("map1", "clickData"),
#     State("map1", "figure"),
#     State("tlb1", "data")
# ) do clickData, x2, tlb_data
#     #points = clickData.points[1]
#     println("hi")
#     println(clickData)
#     # println("h2")
#     # println(x2)
#     if isnothing(clickData)
#         PreventUpdate()
#     else
#         if length(tlb_data)<5
#             points = clickData["points"][1]
#             x = points["x"]
#             y = points["y"]
#
#             # get scatter trace (in this case it's the last trace)
#             println(x2.data[2])
#             scatter_x = x2.data[2]["x"]
#             scatter_y = x2.data[2]["y"]
#             x_new = vcat(scatter_x, x)
#             y_new = vcat(scatter_y, y)
#
#             # update figure data (in this case it's the last trace)
#             println(typeof(x2))
#             println(typeof(fig))
#             println(tlb_data)
#             tlb_data = copy(tlb_data)
#             println(tlb_data)
#             #println(tlb_data[1])
#             #Dict("1"=>rand(1:10), "2"=>x, "3"=>y)
#             push!(tlb_data, Dict(Symbol("wi")=>length(tlb_data)+1, Symbol("x")=>x, Symbol("y")=>y))
#
#             lns = scatter(x=x_new,
#                             y=y_new,
#                             mode="markers",
#                             marker_color="black")
#
#
#             x2 = plot([hm, lns]);
#         else
#
#         end
#
#     end
#     return x2, tlb_data
# end
#
callback!(
    app,
    Output("map1", "figure"),
    Input("tlb1", "data")
) do tlb_data
    well_id, x_tlb, y_tlb = check_tlb(tlb_data)
    lns = scatter(x=x_tlb,
                    y=y_tlb,
                    mode="markers",
                    marker_color="black")


    x2 = plot([hm, lns]);
    return x2
end

# callback!(
#     app,
#     Output("tlb1", "data"),
#     Output("map1", "figure"),
#     Input("editing-rows-button", "n_clicks"),
#     State("tlb1", "data"),
# ) do n_clicks, rows
#     println("---------")
#     println(n_clicks)
#     println(rows)
#     if n_clicks > 1
#          if !isnothing(rows)
#              rows = copy(rows)
#              push!(rows, Dict(Symbol("wi")=>length(rows)+1))
#          else
#              rows =  [Dict{Symbol, Int64}(Symbol("wi")=>1)]
#          end
#          x_tlb, y_tlb = check_tlb(rows)
#          lns = scatter(x=x_tlb,
#                        y=y_tlb,
#                        mode="markers",
#                        marker_color="black")
#
#
#          x2 = plot([hm, lns]);
#          return rows, x2
#     end
#     return [], fig
# end

run_server(app, "0.0.0.0", 8050, debug=true)
