# ============================================================
# Kapitel 05: Gravity Turn & Pitchprogramm
# ============================================================
# Voraussetzungen: Kapitel 01-04 abgeschlossen.
# Implementiere lineare und Velocity-Tracking Pitch-Strategien.
# ============================================================

using Plots

# ─────────────────────────────────────────────────────────────
# Alle fertigen Funktionen aus Kapitel 02-04 einfügen
# (rk4_step, rk4_solve, isa_density, speed_of_sound,
#  drag_coefficient, gravity, derivatives_2d)
# ─────────────────────────────────────────────────────────────

# [TODO: Kopiere deine Implementierungen hierher]

# ─────────────────────────────────────────────────────────────
# AUFGABE 1: Lineare Pitch-Strategie
# ─────────────────────────────────────────────────────────────

# Lineares Pitchprogramm.
# t          : aktueller Zeitpunkt
# t_kick     : Zeitpunkt des Kickbeginns
# t_end_pitch: Zeitpunkt wenn Endwinkel erreicht
# theta_end  : Ziel-Pitchwinkel (Radiant)
# Gibt theta in Radiant zurück.
function pitch_linear(t; t_kick=15.0, t_end_pitch=150.0, theta_end=deg2rad(5.0))
    theta_start = π/2  # 90°
    if t <= t_kick
        return theta_start
    elseif t <= t_end_pitch
        # TODO: Lineare Interpolation von theta_start auf theta_end

    else
        return theta_end
    end
end

# ─────────────────────────────────────────────────────────────
# AUFGABE 2: Velocity-Vector Tracking
# ─────────────────────────────────────────────────────────────

# Pitchwinkel folgt dem Geschwindigkeitsvektor.
# s = [x, y, vx, vy, m]
# Gibt theta in Radiant zurück.
function pitch_velocity_tracking(t, s; t_kick=15.0, kick_angle=deg2rad(1.0))
    vx, vy = s[3], s[4]
    if t < t_kick || sqrt(vx^2 + vy^2) < 1.0
        return π/2
    end
    # TODO: theta = atan(vy, vx)
    # Hinweis: Julia's atan(y,x) gibt den Winkel im richtigen Quadranten

end

# ─────────────────────────────────────────────────────────────
# SIMULATION: Vergleich der Pitch-Strategien
# ─────────────────────────────────────────────────────────────

# Raketenparameter (2-stufig vereinfacht)
m0        = 350_000.0   # kg Startmasse
m_dry     = 25_000.0    # kg Trockenmasse (nach Treibstoff)
thrust    = 7_600_000.0 # N (Falcon 9 ähnlich)
mass_flow = 2_500.0     # kg/s
area      = 10.73       # m²
t_meco    = (m0 - m_dry) / mass_flow   # s bis Engine Cut-Off

println("Brenndauer: $(round(t_meco, digits=1)) s")
println("Ideales Δv: $(round(3200 * log(m0/m_dry), digits=0)) m/s")

# Strategie A: Lineares Pitch
params_linear = (
    thrust     = thrust,
    mass_flow  = mass_flow,
    area       = area,
    theta_func = (t, s) -> pitch_linear(t),
)

# Strategie B: Velocity Tracking
params_vtrack = (
    thrust     = thrust,
    mass_flow  = mass_flow,
    area       = area,
    theta_func = (t, s) -> pitch_velocity_tracking(t, s),
)

s0     = [0.0, 0.0, 0.0, 1.0, m0]   # kleines vy als numerischer Kickstart
h_step = 0.5

t_A, s_A = rk4_solve((t,s) -> derivatives_2d(t, s, params_linear), s0, 0.0, t_meco, h_step)
t_B, s_B = rk4_solve((t,s) -> derivatives_2d(t, s, params_vtrack),  s0, 0.0, t_meco, h_step)

# Extrahiere Größen
extract(vals, i) = [s[i] for s in vals]

x_A, y_A = extract(s_A, 1), extract(s_A, 2)
x_B, y_B = extract(s_B, 1), extract(s_B, 2)
vx_A, vy_A = extract(s_A, 3), extract(s_A, 4)
vx_B, vy_B = extract(s_B, 3), extract(s_B, 4)

# ─────────────────────────────────────────────────────────────
# PLOTS
# ─────────────────────────────────────────────────────────────

# Trajektorie
p_traj = plot(x_A ./ 1000, y_A ./ 1000,
              label="Linear Pitch", lw=2, color=:blue,
              xlabel="Downrange (km)", ylabel="Höhe (km)",
              title="Trajektorienvergleich", aspect_ratio=:auto)
plot!(p_traj, x_B ./ 1000, y_B ./ 1000,
      label="Velocity Tracking", lw=2, color=:red, ls=:dash)

# Pitchwinkel über Zeit
theta_A = [rad2deg(pitch_linear(t)) for t in t_A]
theta_B = [rad2deg(pitch_velocity_tracking(t_B[i], s_B[i])) for i in eachindex(t_B)]

p_pitch = plot(t_A, theta_A, label="Linear", lw=2, color=:blue,
               xlabel="Zeit (s)", ylabel="θ (°)", title="Pitchwinkel")
plot!(p_pitch, t_B, theta_B, label="Vel.Track", lw=2, color=:red, ls=:dash)

# Geschwindigkeit
v_A = sqrt.(vx_A.^2 .+ vy_A.^2)
v_B = sqrt.(vx_B.^2 .+ vy_B.^2)
p_vel = plot(t_A, v_A, label="Linear", lw=2, color=:blue,
             xlabel="Zeit (s)", ylabel="|v| (m/s)", title="Gesamtgeschwindigkeit")
plot!(p_vel, t_B, v_B, label="Vel.Track", lw=2, color=:red, ls=:dash)
hline!(p_vel, [7800], ls=:dot, color=:green, label="LEO ~7800 m/s")

display(plot(p_traj, p_pitch, p_vel, layout=(2,2), size=(1000, 700)))

# ─────────────────────────────────────────────────────────────
# AUSWERTUNG
# ─────────────────────────────────────────────────────────────
println("\n===== Ergebnisse bei MECO =====")
println("Strategie A (Linear):")
println("  Downrange:    $(round(x_A[end]/1000, digits=1)) km")
println("  Höhe:         $(round(y_A[end]/1000, digits=1)) km")
println("  |v|:          $(round(v_A[end], digits=0)) m/s")

println("\nStrategie B (Vel.Track):")
println("  Downrange:    $(round(x_B[end]/1000, digits=1)) km")
println("  Höhe:         $(round(y_B[end]/1000, digits=1)) km")
println("  |v|:          $(round(v_B[end], digits=0)) m/s")
