using PlotlyJS
using Dash
#using Plotly
using DashBootstrapComponents

lns = scatter(x=[200, 200, 500],
                y=[200, 800, 500],
                mode="markers",
                marker_color="black")

hm = heatmap(x = collect(0:10:1000),
             y = collect(0:10:1000),
             z = zeros(101,101),
             colorscale ="Greens",
             colorbar_thickness=20)
fig = plot([hm, lns]);
fig.plot.data[2].fields
#fig.plot.layout.fields[:clickmode] = "event+select"
# update_layout(fig, clickmode="event+select")
#update(fig)
#fig.plot
# update!(fig.plot, clickmode="event+select")
# update_traces(fig, marker_size=20)
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
                html_div(className = "nine columns",
                        dcc_graph(id = "map1", animate = true,
                        figure = fig
                        )),
                 dash_datatable(id = "tlb1",
                 columns = [Dict("name"=>"№", "id"=>1),
                            Dict("name"=>"X", "id"=>2),
                            Dict("name"=>"Y", "id"=>3)],
                 data=[ Dict(1=>1, 2=>3, 3=>4), Dict(1=>5, 2=>4, 3=>10)],
                 editable = true,
                 row_deletable = true),
                 html_table([
                    html_thead(html_tr(html_th.(["№","x","y"]))),
                    html_tbody([html_tr(html_td.([1, 500, 500])),
                                html_tr(html_td.([2, 250, 255]))])
                        ],
                    )], style = Dict("border" => "0.5px solid", "border-radius" => 5)

        ))
    ])])

callback!(
    app,
    Output("map1", "figure"),
    Output("tlb1", "data"),
    Input("map1", "clickData"),
    State("map1", "figure"),
    State("tlb1", "data")
) do clickData, x2, tlb_data
    #points = clickData.points[1]
    println("hi")
    println(clickData)
    # println("h2")
    # println(x2)
    if isnothing(clickData)
        PreventUpdate()
    else
        points = clickData["points"][1]
        x = points["x"]
        y = points["y"]

        # get scatter trace (in this case it's the last trace)
        println(x2.data[2])
        scatter_x = x2.data[2]["x"]
        scatter_y = x2.data[2]["y"]
        x_new = vcat(scatter_x, x)
        y_new = vcat(scatter_y, y)

        # update figure data (in this case it's the last trace)
        println(typeof(x2))
        println(typeof(fig))
        println(tlb_data)
        #update!(x2, 2; x=x_new)
        #update!(x2, 2; y=y_new)
        #update!(x2, 2)
        tlb_data = copy(tlb_data)
        println(tlb_data)
        println(tlb_data[1])
        Dict("1"=>rand(1:10), "2"=>x, "3"=>y)
        push!(tlb_data, Dict(Symbol("1")=>rand(1:10), Symbol("2")=>x, Symbol("3")=>y))

        lns = scatter(x=x_new,
                        y=y_new,
                        mode="markers",
                        marker_color="black")


        x2 = plot([hm, lns]);

    end
    return x2, tlb_data
end

run_server(app, "0.0.0.0", 8050)
