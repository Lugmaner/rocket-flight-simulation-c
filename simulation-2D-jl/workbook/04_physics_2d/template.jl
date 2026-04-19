# ============================================================
# Kapitel 04: 2D-Physik der Rakete
# ============================================================
# Voraussetzungen: Kapitel 01 (Euler), 02 (RK4), 03 (Atmosphäre) abgeschlossen.
# Löse alle Rechenaufgaben in theory.pdf auf Papier, dann hier.
# ============================================================

using Plots

# ─────────────────────────────────────────────────────────────
# Übernommene Funktionen aus Kapitel 02 + 03
# (Kopiere deine fertigen Implementierungen hierher)
# ─────────────────────────────────────────────────────────────

function rk4_step(f, t, y, h)
    # TODO: Deine RK4-Implementierung aus Kapitel 02

end

function rk4_solve(f, y0, t0, t_end, h)
    t_values = [t0]
    y_values = [y0]
    t, y = t0, y0
    while t < t_end - 1e-10
        y = rk4_step(f, t, y, h)
        t += h
        push!(t_values, t)
        push!(y_values, y)
    end
    return t_values, y_values
end

function isa_temperature(h)
    # TODO: Deine ISA-Temperatur aus Kapitel 03

end

function isa_density(h)
    R_s = 287.058
    # TODO: ρ = p/(Rₛ·T), nutze isa_pressure und isa_temperature

end

function isa_pressure(h)
    # TODO: Deine ISA-Druck-Implementierung aus Kapitel 03

end

function speed_of_sound(h)
    # TODO:

end

function drag_coefficient(mach)
    # TODO:

end

# ─────────────────────────────────────────────────────────────
# AUFGABE 1: Schwerkraft
# ─────────────────────────────────────────────────────────────

const g₀ = 9.80665
const R_E = 6_371_000.0  # Erdradius m

# Höhenabhängige Gravitationsbeschleunigung (m/s², positiv = Betrag)
function gravity(y)
    # TODO: g(y) = g₀ · (R_E / (R_E + y))²

end

# ─────────────────────────────────────────────────────────────
# AUFGABE 2+3: Rechte Seite des ODE-Systems
# ─────────────────────────────────────────────────────────────

# Raketenparameter als NamedTuple
# params = (thrust, mass_flow, area, theta_func)
# theta_func(t, s) gibt den Pitchwinkel in Radiant zurück

# Berechnet die Ableitungen des Zustandsvektors s = [x, y, vx, vy, m].
# Gibt ds/dt = [ẋ, ẏ, v̇x, v̇y, ṁ] zurück.
function derivatives_2d(t, s, params)
    x, y, vx, vy, m = s

    T      = params.thrust
    m_dot  = params.mass_flow
    A      = params.area
    θ      = params.theta_func(t, s)   # Pitchwinkel

    # Geschwindigkeitsbetrag und Einheitsvektor
    v_mag = sqrt(vx^2 + vy^2)

    # TODO: Berechne Drag-Kraft (Betrag)
    # Hinweis: Wenn v_mag ≈ 0 → F_D = 0 (Division vermeiden!)
    F_D = 0.0

    # TODO: Berechne Schubkomponenten

    # TODO: Berechne Beschleunigungen ax, ay
    # ax = (F_Tx - F_D * vx/v_mag) / m
    # ay = (F_Ty - F_D * vy/v_mag) / m - g(y)

    # TODO: Gib [vx, vy, ax, ay, -m_dot] zurück

end

# ─────────────────────────────────────────────────────────────
# SIMULATION: Senkrechter Start (theta = 90°)
# ─────────────────────────────────────────────────────────────

# Rakete: 1 Stufe, ~Falcon 9 First Stage vereinfacht
params_vertical = (
    thrust     = 1_400_000.0,           # N
    mass_flow  = 437.5,                 # kg/s
    area       = 10.0,                  # m²
    theta_func = (t, s) -> π/2,         # immer senkrecht
)

s0      = [0.0, 0.0, 0.0, 0.0, 100_000.0]   # [x, y, vx, vy, m]
t_end   = 200.0                               # s
h_step  = 0.5                                 # s

# ODE-Funktion für rk4_solve (verpackt params)
f_rocket = (t, s) -> derivatives_2d(t, s, params_vertical)

t_vals, s_vals = rk4_solve(f_rocket, s0, 0.0, t_end, h_step)

# Extrahiere Größen
y_vals  = [s[2] for s in s_vals]
vy_vals = [s[4] for s in s_vals]
m_vals  = [s[5] for s in s_vals]

# Beschleunigung nachberechnen (aus Ableitungsvektor)
ay_vals = [derivatives_2d(t_vals[i], s_vals[i], params_vertical)[4]
           for i in eachindex(t_vals)]

# ─────────────────────────────────────────────────────────────
# PLOTS
# ─────────────────────────────────────────────────────────────

p1 = plot(t_vals, y_vals ./ 1000, xlabel="Zeit (s)", ylabel="Höhe (km)",
          title="Höhenprofil", lw=2, color=:blue, label="h(t)")

p2 = plot(t_vals, vy_vals, xlabel="Zeit (s)", ylabel="v_y (m/s)",
          title="Vertikalgeschwindigkeit", lw=2, color=:red, label="vy(t)")

p3 = plot(t_vals, ay_vals, xlabel="Zeit (s)", ylabel="a_y (m/s²)",
          title="Vertikalbeschleunigung", lw=2, color=:orange, label="ay(t)")
hline!(p3, [0.0], ls=:dash, color=:gray, label="a=0")

p4 = plot(t_vals, m_vals, xlabel="Zeit (s)", ylabel="Masse (kg)",
          title="Massenabbau", lw=2, color=:green, label="m(t)")

display(plot(p1, p2, p3, p4, layout=(2,2), size=(900, 700)))

# ─────────────────────────────────────────────────────────────
# CHECKS
# ─────────────────────────────────────────────────────────────
println("\n===== Checks =====")
if @isdefined(gravity)
    println("g(0m):     $(round(gravity(0.0),    digits=4))  (erwartet 9.8067)")
    println("g(100km):  $(round(gravity(100_000), digits=4))  (erwartet ~9.5)")
end

if @isdefined(derivatives_2d)
    s_test  = [0.0, 0.0, 0.0, 0.0, 100_000.0]
    ds      = derivatives_2d(0.0, s_test, params_vertical)
    println("ẋ  = $(round(ds[1], digits=3))   (erwartet 0.0)")
    println("ẏ  = $(round(ds[2], digits=3))   (erwartet 0.0)")
    println("v̇x = $(round(ds[3], digits=3))   (erwartet 0.0, theta=90°)")
    println("v̇y = $(round(ds[4], digits=3))   (erwartet ~4.2, T/m - g)")
    println("ṁ  = $(round(ds[5], digits=3))   (erwartet -437.5)")
end
