# ============================================================
# Kapitel 02: Runge-Kutta 4. Ordnung (RK4)
# ============================================================
# Lies zuerst theory.pdf, löse alle 4 Aufgaben auf Papier.
# Dann implementiere hier und vergleiche mit deinen Ergebnissen.
# ============================================================

using Plots

# Euler aus Kapitel 01 — als Referenz zum Vergleich
function euler_step(f, t, y, h)
    return y .+ h .* f(t, y)
end

function euler_solve(f, y0, t0, t_end, h)
    t_values = [t0]
    y_values = [y0]
    t, y = t0, y0
    while t < t_end - 1e-10
        y = euler_step(f, t, y, h)
        t += h
        push!(t_values, t)
        push!(y_values, y)
    end
    return t_values, y_values
end

# ─────────────────────────────────────────────────────────────
# AUFGABE 1+2: RK4-Schritt und vollständige Integration
# ─────────────────────────────────────────────────────────────

# Ein einzelner RK4-Schritt.
# Funktioniert sowohl für Skalare als auch Vektoren (Broadcasting via .+)
function rk4_step(f, t, y, h)
    # TODO: Berechne k1, k2, k3, k4 und y_{n+1}
    # k1 = f(t, y)
    # k2 = f(t + h/2, y + h/2 * k1)
    # k3 = f(t + h/2, y + h/2 * k2)
    # k4 = f(t + h,   y + h   * k3)
    # return y + h/6 * (k1 + 2*k2 + 2*k3 + k4)

end

# Vollständige RK4-Integration
function rk4_solve(f, y0, t0, t_end, h)
    t_values = [t0]
    y_values = [y0]
    t, y = t0, y0
    while t < t_end - 1e-10
        # TODO: Rufe rk4_step auf, aktualisiere t und y

    end
    return t_values, y_values
end

# ─────────────────────────────────────────────────────────────
# TEST 1: dy/dt = -y, Fehlervergleich Euler vs RK4
# ─────────────────────────────────────────────────────────────

f_decay = (t, y) -> -y
y0 = 1.0
t0, t_end = 0.0, 5.0

h_values = [1.0, 0.5, 0.25, 0.1, 0.05]
errors_euler = Float64[]
errors_rk4   = Float64[]

for h in h_values
    _, ys_euler = euler_solve(f_decay, y0, t0, t_end, h)
    _, ys_rk4   = rk4_solve(f_decay, y0, t0, t_end, h)
    push!(errors_euler, abs(last(ys_euler) - exp(-t_end)))
    push!(errors_rk4,   abs(last(ys_rk4)  - exp(-t_end)))
end

p1 = plot(h_values, errors_euler, label="Euler", marker=:circle,
          xscale=:log10, yscale=:log10, lw=2)
plot!(p1, h_values, errors_rk4, label="RK4", marker=:square, lw=2)
xlabel!(p1, "Schrittweite h")
ylabel!(p1, "Globaler Fehler bei t=5")
title!(p1, "Fehlerordnung: Euler O(h) vs RK4 O(h^4)")

# Referenzlinien für Ordnung 1 und 4
h_ref = h_values
plot!(p1, h_ref, 0.5 .* h_ref,        label="O(h)",   ls=:dash, color=:gray)
plot!(p1, h_ref, 0.1 .* h_ref.^4,     label="O(h^4)", ls=:dot,  color=:gray)

display(p1)

# ─────────────────────────────────────────────────────────────
# TEST 2: Freier Fall als Vektorsystem (Aufgabe 3)
# ─────────────────────────────────────────────────────────────

g = 9.81
f_fall = (t, y) -> [y[2], -g]     # y = [h, v]
y0_fall = [100.0, 0.0]

t_rk4, y_rk4 = rk4_solve(f_fall, y0_fall, 0.0, 5.0, 1.0)
t_eul, y_eul = euler_solve(f_fall, y0_fall, 0.0, 5.0, 1.0)

h_rk4 = [y[1] for y in y_rk4]
h_eul = [y[1] for y in y_eul]

t_ex = range(0, 5, length=500)
h_ex = 100.0 .- 0.5 .* g .* t_ex.^2

p2 = plot(t_ex, h_ex, label="Exakt", color=:black, lw=2)
plot!(p2, t_rk4, h_rk4, label="RK4  h=1s", marker=:square, ms=5, lw=2)
plot!(p2, t_eul, h_eul, label="Euler h=1s", marker=:circle, ms=5, lw=2, ls=:dash)
xlabel!(p2, "Zeit t (s)")
ylabel!(p2, "Höhe h (m)")
title!(p2, "Freier Fall: RK4 vs Euler (h=1s)")

display(p2)

# ─────────────────────────────────────────────────────────────
# CHECKS
# ─────────────────────────────────────────────────────────────
println("\n===== Checks =====")
if @isdefined(rk4_step)
    y1 = rk4_step((t,y) -> -y, 0.0, 1.0, 0.5)
    println("RK4 Schritt korrekt: ", isapprox(y1, exp(-0.5), atol=1e-4),
            "  (erwartet ≈ $(round(exp(-0.5), digits=5)), got $(round(y1, digits=5)))")
end

println("\nFehlerordnung bei t=5, h=0.1 vs h=0.05:")
if length(errors_rk4) >= 2
    ratio_rk4   = errors_rk4[end-1]   / errors_rk4[end]
    ratio_euler = errors_euler[end-1] / errors_euler[end]
    println("  Euler-Verhältnis:  $(round(ratio_euler, digits=1))  (erwartet ~2)")
    println("  RK4-Verhältnis:    $(round(ratio_rk4,   digits=1))  (erwartet ~16)")
end
