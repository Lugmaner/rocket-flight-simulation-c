# ============================================================
# Kapitel 06: Mehrstufige Raketen
# ============================================================
# Voraussetzungen: Kapitel 01-05 abgeschlossen.
# Implementiere Stufentrennung und eine vollständige 2-Stage-Sim.
# ============================================================

using Plots

# ─────────────────────────────────────────────────────────────
# [TODO: Alle fertigen Funktionen aus Kapitel 02-05 einfügen]
# rk4_step, rk4_solve, isa_density, speed_of_sound,
# drag_coefficient, gravity, derivatives_2d,
# pitch_linear, pitch_velocity_tracking
# ─────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────
# Datenstruktur: Stufe
# ─────────────────────────────────────────────────────────────

struct Stage
    m_wet      :: Float64    # Gesamtmasse der Stufe (voll) kg
    m_dry      :: Float64    # Trockenmasse (leer)          kg
    thrust     :: Float64    # Schub                        N
    mass_flow  :: Float64    # Massenfluss                  kg/s
    area       :: Float64    # Querschnittsfläche           m²
end

# Verbleibender Treibstoff der aktiven Stufe
fuel_remaining(stage::Stage, m_rocket::Float64, m_above::Float64) =
    m_rocket - m_above - stage.m_dry

# ─────────────────────────────────────────────────────────────
# Falcon 9 ähnliche Parameter
# ─────────────────────────────────────────────────────────────

stage1 = Stage(
    m_wet     = 300_000.0,   # kg
    m_dry     =  22_200.0,   # kg
    thrust    = 7_607_000.0, # N (Merlin 1D × 9)
    mass_flow =   2_530.0,   # kg/s
    area      =      10.73,  # m²
)

stage2 = Stage(
    m_wet     =  92_670.0,
    m_dry     =   4_000.0,
    thrust    =  934_000.0,  # N (Merlin Vacuum)
    mass_flow =    280.0,
    area      =     10.73,
)

payload_mass = 13_150.0   # kg (Geosynchronous)

# ─────────────────────────────────────────────────────────────
# AUFGABE: Staging-Simulation
# ─────────────────────────────────────────────────────────────

# Führt eine vollständige mehrstufige Simulation durch.
# stages     : Vector{Stage} von unten nach oben
# payload    : Nutzlastmasse kg
# theta_func : Pitchwinkel-Funktion (t, s) -> Radiant
# h_step     : Zeitschritt s
# t_max      : maximale Simulationszeit s
function simulate_multistage(stages, payload, theta_func; h_step=0.5, t_max=600.0)

    # Gesamtstartmasse
    m0 = sum(s.m_wet for s in stages) + payload

    # Anfangszustand
    s0 = [0.0, 0.0, 0.0, 1.0, m0]

    # Tracking-Arrays
    all_t = Float64[]
    all_s = Vector{Float64}[]
    staging_times = Float64[]

    t = 0.0
    s_curr = s0
    stage_idx = 1

    # Masse der Stufen oberhalb der aktuellen
    mass_above(idx) = sum(stages[j].m_wet for j in (idx+1):length(stages)) + payload

    while t < t_max && stage_idx <= length(stages)
        stage = stages[stage_idx]
        m_above = mass_above(stage_idx)

        # Parameter für aktuelle Stufe
        params = (
            thrust     = stage.thrust,
            mass_flow  = stage.mass_flow,
            area       = stage.area,
            theta_func = theta_func,
        )

        f = (t, s) -> derivatives_2d(t, s, params)

        # RK4-Schritt
        s_new = rk4_step(f, t, s_curr, h_step)

        # TODO: Prüfe ob Treibstoff dieser Stufe aufgebraucht ist.
        # Bedingung: s_new[5] <= m_above + stage.m_dry
        # Falls ja: trenne Stufe (subtrahiere stage.m_dry von Masse),
        #           wechsle zu nächster Stufe, speichere staging_time.


        t += h_step
        s_curr = s_new
        push!(all_t, t)
        push!(all_s, s_curr)

        # Abbruch wenn unter Boden
        s_curr[2] < 0 && break
    end

    return all_t, all_s, staging_times
end

# ─────────────────────────────────────────────────────────────
# Simulation ausführen
# ─────────────────────────────────────────────────────────────

theta_func = (t, s) -> pitch_linear(t; t_kick=15.0, t_end_pitch=180.0, theta_end=deg2rad(3.0))

t_vals, s_vals, t_stages = simulate_multistage(
    [stage1, stage2], payload_mass, theta_func,
    h_step=0.5, t_max=700.0
)

# ─────────────────────────────────────────────────────────────
# PLOTS
# ─────────────────────────────────────────────────────────────

x_v  = [s[1] for s in s_vals] ./ 1000
y_v  = [s[2] for s in s_vals] ./ 1000
vx_v = [s[3] for s in s_vals]
vy_v = [s[4] for s in s_vals]
m_v  = [s[5] for s in s_vals]
v_v  = sqrt.(vx_v.^2 .+ vy_v.^2)

# Trajektorie
p_traj = plot(x_v, y_v, xlabel="Downrange (km)", ylabel="Höhe (km)",
              title="2-Stage Trajektorie", lw=2, label="Trajektorie")
for t_sep in t_stages
    idx = argmin(abs.(t_vals .- t_sep))
    scatter!(p_traj, [x_v[idx]], [y_v[idx]], marker=:star5, ms=10,
             color=:red, label="Stage Sep.")
end

# Masse
p_mass = plot(t_vals, m_v ./ 1000, xlabel="Zeit (s)", ylabel="Masse (t)",
              title="Massenabbau", lw=2, label="m(t)")
for t_sep in t_stages
    vline!(p_mass, [t_sep], ls=:dash, color=:red, label="Stage Sep.")
end

# Geschwindigkeit
p_vel = plot(t_vals, v_v, xlabel="Zeit (s)", ylabel="|v| (m/s)",
             title="Geschwindigkeit", lw=2, label="|v|")
hline!(p_vel, [7800.0], ls=:dot, color=:green, label="LEO")

display(plot(p_traj, p_mass, p_vel, layout=(2,2), size=(1000, 700)))

# ─────────────────────────────────────────────────────────────
# Tsiolkovsky-Vergleich
# ─────────────────────────────────────────────────────────────
v_e = 3200.0
dv_ideal_1 = v_e * log(stage1.m_wet / stage1.m_dry)
dv_ideal_2 = v_e * log(stage2.m_wet / stage2.m_dry)

println("\n===== Tsiolkovsky vs Simulation =====")
println("Δv ideal  Stufe 1: $(round(dv_ideal_1, digits=0)) m/s")
println("Δv ideal  Stufe 2: $(round(dv_ideal_2, digits=0)) m/s")
println("Δv ideal  gesamt:  $(round(dv_ideal_1 + dv_ideal_2, digits=0)) m/s")
println("Δv sim    gesamt:  $(round(v_v[end], digits=0)) m/s")
println("Verluste:          $(round(dv_ideal_1 + dv_ideal_2 - v_v[end], digits=0)) m/s (Gravity + Drag)")
