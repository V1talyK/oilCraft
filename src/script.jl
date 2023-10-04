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
                        ))],
                    ), style = Dict("border" => "0.5px solid", "border-radius" => 5)
                )
        ])
    ])

callback!(
    app,
    Output("map1", "figure"),
    Input("map1", "clickData"),
    State("map1", "figure")
    #State("map", "figure")
) do clickData, x2
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
        #update!(x2, 2; x=x_new)
        #update!(x2, 2; y=y_new)
        #update!(x2, 2)

        lns = scatter(x=x_new,
                        y=y_new,
                        mode="markers",
                        marker_color="black")


        x2 = plot([hm, lns]);

    end
    return x2
end

run_server(app, "0.0.0.0", 8050)
