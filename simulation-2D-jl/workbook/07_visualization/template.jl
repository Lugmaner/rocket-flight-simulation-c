# ============================================================
# Kapitel 07: Wissenschaftliche Visualisierung
# ============================================================
# Voraussetzungen: Kapitel 01-06 vollständig abgeschlossen.
# Das ist dein Showcase — baue hier das vollständige Dashboard.
# ============================================================

using Plots
# using GLMakie   # Für 3D — einkommentieren wenn GLMakie installiert

# ─────────────────────────────────────────────────────────────
# [TODO: Alle fertigen Funktionen aus Kapitel 02-06 einfügen]
# ─────────────────────────────────────────────────────────────

# ─────────────────────────────────────────────────────────────
# Vollständige Simulation (aus Kapitel 06)
# ─────────────────────────────────────────────────────────────

# [TODO: stage1, stage2, payload_mass, simulate_multistage definieren]
# [TODO: Simulation ausführen und t_vals, s_vals speichern]

# Angenommen: t_vals, s_vals sind verfügbar
# x_v, y_v, vx_v, vy_v, m_v aus s_vals extrahieren

# ─────────────────────────────────────────────────────────────
# AUFGABE 1: 6-Panel Dashboard
# ─────────────────────────────────────────────────────────────

function plot_dashboard(t_vals, s_vals, staging_times=[])
    x_v  = [s[1] for s in s_vals] ./ 1000
    y_v  = [s[2] for s in s_vals] ./ 1000
    vx_v = [s[3] for s in s_vals]
    vy_v = [s[4] for s in s_vals]
    m_v  = [s[5] for s in s_vals]
    v_v  = sqrt.(vx_v.^2 .+ vy_v.^2)

    # Panel 1: Trajektorie
    p1 = plot(x_v, y_v, xlabel="Downrange (km)", ylabel="Höhe (km)",
              title="Trajektorie", lw=2, color=:royalblue, label="Flugbahn",
              aspect_ratio=:auto)

    # Panel 2: Höhe über Zeit
    p2 = plot(t_vals, y_v, xlabel="Zeit (s)", ylabel="Höhe (km)",
              title="Höhenprofil h(t)", lw=2, color=:blue, label="h(t)")

    # Panel 3: Geschwindigkeit
    p3 = plot(t_vals, v_v, xlabel="Zeit (s)", ylabel="|v| (m/s)",
              title="Geschwindigkeit |v(t)|", lw=2, color=:red, label="|v|")
    hline!(p3, [7800.0], ls=:dot, color=:green, lw=1.5, label="LEO")

    # Panel 4: Masse
    p4 = plot(t_vals, m_v ./ 1000, xlabel="Zeit (s)", ylabel="Masse (t)",
              title="Massenabbau m(t)", lw=2, color=:darkorange, label="m(t)")
    for t_sep in staging_times
        vline!(p4, [t_sep], ls=:dash, color=:red, lw=1.5, label="")
    end

    # Panel 5: Phasenraum (vy vs h)
    p5 = plot(y_v, vy_v, xlabel="Höhe (km)", ylabel="vy (m/s)",
              title="Phasenraum: vy vs h", lw=2, color=:purple, label="Phasenkurve")
    scatter!(p5, [y_v[1]], [vy_v[1]], color=:green, ms=8, label="Start")
    scatter!(p5, [y_v[end]], [vy_v[end]], color=:red,  ms=8, label="Ende")

    # Panel 6: Energiebilanz
    # TODO: Berechne E_kin, E_pot, E_total
    E_kin = 0.5 .* v_v.^2                          # J/kg
    E_pot = 9.81 .* (y_v .* 1000)                  # J/kg
    E_tot = E_kin .+ E_pot

    p6 = plot(t_vals, E_kin ./ 1e6, label="E_kin", lw=2, color=:red,
              xlabel="Zeit (s)", ylabel="Energie (MJ/kg)", title="Energiebilanz")
    plot!(p6, t_vals, E_pot ./ 1e6, label="E_pot", lw=2, color=:blue)
    plot!(p6, t_vals, E_tot ./ 1e6, label="E_total", lw=2, color=:black, ls=:dash)

    return plot(p1, p2, p3, p4, p5, p6,
                layout=(3,2), size=(1100, 900),
                plot_title="Rocket Flight Simulation — 2D Dashboard")
end

# Aufruf (sobald Simulation läuft):
# display(plot_dashboard(t_vals, s_vals, t_stages))

# ─────────────────────────────────────────────────────────────
# AUFGABE 2: 3D-Plot mit GLMakie
# ─────────────────────────────────────────────────────────────

function plot_3d_trajectory(t_vals, s_vals)
    # Lädt GLMakie (stelle sicher: import Pkg; Pkg.add("GLMakie"))
    # using GLMakie

    x_v = [s[1] for s in s_vals] ./ 1000
    y_v = [s[2] for s in s_vals] ./ 1000
    z_v = zeros(length(x_v))   # 2D-Simulation → z=0

    # TODO mit GLMakie:
    # fig = Figure(resolution=(800, 600))
    # ax  = Axis3(fig[1,1], xlabel="Downrange (km)", ylabel="z (km)", zlabel="Höhe (km)")
    # lines!(ax, x_v, z_v, y_v, color=:royalblue, linewidth=3)
    # scatter!(ax, [x_v[1]], [0], [y_v[1]], color=:green, markersize=20)
    # scatter!(ax, [x_v[end]], [0], [y_v[end]], color=:red, markersize=20)
    # display(fig)

    println("3D-Plot: Aktiviere GLMakie und uncommentiere den Code.")
    println("Trajektoriepunkte: $(length(x_v))")
    println("Max Downrange: $(round(maximum(x_v), digits=1)) km")
    println("Max Höhe:      $(round(maximum(y_v), digits=1)) km")
end

# plot_3d_trajectory(t_vals, s_vals)

# ─────────────────────────────────────────────────────────────
# AUFGABE 3: Animation
# ─────────────────────────────────────────────────────────────

function animate_trajectory(t_vals, s_vals; filename="rocket_flight.gif", fps=30)
    x_v = [s[1] for s in s_vals] ./ 1000
    y_v = [s[2] for s in s_vals] ./ 1000
    n   = length(x_v)
    step = max(1, div(n, 200))    # max 200 Frames

    anim = @animate for i in 1:step:n
        plot(x_v[1:i], y_v[1:i],
             xlim=(minimum(x_v)-10, maximum(x_v)+10),
             ylim=(-5, maximum(y_v)+10),
             xlabel="Downrange (km)", ylabel="Höhe (km)",
             title="t = $(round(t_vals[i], digits=0)) s",
             lw=2, color=:royalblue, label="Bahn",
             size=(700, 500))
        scatter!([x_v[i]], [y_v[i]], color=:red, ms=8, label="Rakete")
    end

    gif(anim, filename, fps=fps)
    println("Animation gespeichert: $filename")
end

# animate_trajectory(t_vals, s_vals)

# ─────────────────────────────────────────────────────────────
# ZUSAMMENFASSUNG
# ─────────────────────────────────────────────────────────────
println("""
===== Kapitel 07: Checkliste =====
 [ ] plot_dashboard() aufgerufen und alle 6 Panels korrekt
 [ ] Phasenraum interpretiert (Aufgabe 1 aus theory.pdf)
 [ ] Energiebilanz plottet E_kin, E_pot, E_total sinnvoll
 [ ] GLMakie installiert: julia> ] add GLMakie
 [ ] 3D-Plot aktiviert und getestet
 [ ] Animation erstellt (rocket_flight.gif)
 [ ] Alle 3 Konzeptfragen in theory.pdf beantwortet
""")
