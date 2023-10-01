const t = 0.:1e-3:2.

function response(f₀ = 10., ξ = 0.01, x₀ = 1., v₀ = 1.)
    ω₀ = 2π*f₀     # Natural angular frequency
    if 0. ≤ ξ < 1. # Undamped/Under-damped response
       Ω₀ = ω₀*√(1. - ξ^2)
      x = (x₀*cos.(Ω₀*t) + (v₀ + ξ*ω₀*x₀)*sin.(Ω₀*t)/Ω₀).*exp.(-ξ*ω₀*t)
    elseif ξ == 1.  # Critically damped response
      x = @. (x₀ + ω₀*x₀*t + v₀*t)*exp(-ω₀*t)
    else # Over-damped response
      β = ω₀*√(ξ^2 - 1.)
      x = @. (x₀*cosh(β*t) + (v₀ + ξ*ω₀*x₀*sinh(β*t))/β)*exp(-ξ*ω₀*t)
    end
end

function damping(value)
    if value == 1
        return 0.
    elseif value == 2
        return 0.001
    elseif value == 3
        return 0.01
    elseif value == 4
        return 0.1
    elseif value == 5
        return 1.
    else
        return 1.5
    end
end
