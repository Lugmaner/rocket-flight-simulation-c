# ============================================================
# Kapitel 01: Das Euler-Verfahren
# ============================================================
# Lies zuerst theory.pdf (workbook/01_euler/theory.pdf)
# Löse alle Rechenaufgaben auf Papier, dann implementiere hier.
# ============================================================

using Plots

# ─────────────────────────────────────────────────────────────
# AUFGABE 1+2: Euler-Schritt und vollständige Integration
# ─────────────────────────────────────────────────────────────

# Ein einzelner Euler-Schritt.
# f    : Funktion f(t, y) — die rechte Seite der ODE
# t    : aktueller Zeitpunkt
# y    : aktueller Zustand (Zahl oder Vektor)
# h    : Schrittweite
# Gibt den neuen Zustand y_{n+1} zurück.
function euler_step(f, t, y, h)
    # TODO: Implementiere y_{n+1} = y_n + h * f(t_n, y_n)

end

# Vollständige Euler-Integration über ein Zeitintervall.
# f      : Funktion f(t, y)
# y0     : Anfangsbedingung
# t0     : Startzeit
# t_end  : Endzeit
# h      : Schrittweite
# Gibt (t_values, y_values) zurück — zwei Vektoren.
function euler_solve(f, y0, t0, t_end, h)
    t_values = [t0]
    y_values = [y0]

    t = t0
    y = y0

    while t < t_end - 1e-10  # kleine Toleranz für Floating-Point
        # TODO: Rufe euler_step auf, speichere t und y in den Vektoren

    end

    return t_values, y_values
end

# ─────────────────────────────────────────────────────────────
# TEST 1: dy/dt = -y, y(0) = 1 (exakte Lösung: e^{-t})
# ─────────────────────────────────────────────────────────────

f_test1 = (t, y) -> -y          # rechte Seite der ODE
y0_test1 = 1.0
t0 = 0.0
t_end = 5.0

# Löse mit h = 0.2 und h = 0.5
t_euler_02, y_euler_02 = euler_solve(f_test1, y0_test1, t0, t_end, 0.2)
t_euler_05, y_euler_05 = euler_solve(f_test1, y0_test1, t0, t_end, 0.5)

# Exakte Lösung
t_exact = range(t0, t_end, length=500)
y_exact = exp.(-t_exact)

# Plot 1: Lösungsvergleich
p1 = plot(t_exact, y_exact, label="Exakt: e^{-t}", color=:black, lw=2)
plot!(p1, t_euler_02, y_euler_02, label="Euler h=0.2", marker=:circle, ms=3)
plot!(p1, t_euler_05, y_euler_05, label="Euler h=0.5", marker=:square, ms=4)
xlabel!(p1, "Zeit t")
ylabel!(p1, "y(t)")
title!(p1, "Euler-Verfahren: dy/dt = -y")

# Plot 2: Fehler über Zeit
fehler_02 = abs.(y_euler_02 .- exp.(-t_euler_02))
fehler_05 = abs.(y_euler_05 .- exp.(-t_euler_05))

p2 = plot(t_euler_02, fehler_02, label="Fehler h=0.2", marker=:circle, ms=3)
plot!(p2, t_euler_05, fehler_05, label="Fehler h=0.5", marker=:square, ms=4)
xlabel!(p2, "Zeit t")
ylabel!(p2, "Absoluter Fehler")
title!(p2, "Fehlervergleich (Aufgabe 2)")
yscale = :log10

display(plot(p1, p2, layout=(2,1), size=(700, 600)))

# ─────────────────────────────────────────────────────────────
# TEST 2: Freier Fall (Aufgabe 3 aus theory.pdf)
# ─────────────────────────────────────────────────────────────

# Zustandsvektor: y = [h, v]
# dy/dt = [v, -g]
g = 9.81
h0 = 100.0
v0 = 0.0

f_freefall = (t, y) -> [y[2], -g]      # y[1]=h, y[2]=v

t_fall, y_fall = euler_solve(f_freefall, [h0, v0], 0.0, 5.0, 0.5)

# Extrahiere Höhe und Geschwindigkeit
h_values = [y[1] for y in y_fall]
v_values = [y[2] for y in y_fall]

# Exakte Lösungen
t_ex = range(0, 5, length=500)
h_exact_fall = h0 .- 0.5 .* g .* t_ex.^2
v_exact_fall = -g .* t_ex

p3 = plot(t_ex, h_exact_fall, label="h exakt", color=:black, lw=2)
plot!(p3, t_fall, h_values, label="h Euler", marker=:circle, ms=3)
xlabel!(p3, "Zeit t (s)")
ylabel!(p3, "Höhe h (m)")
title!(p3, "Freier Fall — Höhe")

p4 = plot(t_ex, v_exact_fall, label="v exakt", color=:black, lw=2)
plot!(p4, t_fall, v_values, label="v Euler", marker=:circle, ms=3)
xlabel!(p4, "Zeit t (s)")
ylabel!(p4, "Geschwindigkeit v (m/s)")
title!(p4, "Freier Fall — Geschwindigkeit")

display(plot(p3, p4, layout=(2,1), size=(700, 600)))

# ─────────────────────────────────────────────────────────────
# CHECKS — diese Aussagen müssen true sein
# ─────────────────────────────────────────────────────────────
println("\n===== Checks =====")
println("euler_step definiert:   ", @isdefined(euler_step))
println("euler_solve definiert:  ", @isdefined(euler_solve))

if @isdefined(euler_step)
    y1_check = euler_step((t,y) -> -y, 0.0, 1.0, 0.2)
    println("Schritt 1 korrekt:      ", isapprox(y1_check, 0.8, atol=1e-10),
            "  (erwartet 0.8, got $y1_check)")
end

if @isdefined(euler_solve)
    ts, ys = euler_solve((t,y) -> -y, 1.0, 0.0, 1.0, 0.2)
    println("5 Schritte korrekt:     ", length(ts) == 6,
            "  (erwartet 6 Punkte, got $(length(ts)))")
end
