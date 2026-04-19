# ============================================================
# Kapitel 03: ISA-Atmosphäre
# ============================================================
# Lies zuerst theory.pdf und berechne Aufgabe 1+2 auf Papier.
# Implementiere dann die ISA-Funktionen und überprüfe deine Werte.
# ============================================================

using Plots

# ─────────────────────────────────────────────────────────────
# Konstanten
# ─────────────────────────────────────────────────────────────
const g₀     = 9.80665    # Standardgravitation m/s²
const R_s    = 287.058    # Spezifische Gaskonstante Luft J/(kg·K)
const γ      = 1.4        # Isentropenexponent
const T₀     = 288.15     # Temperatur Meereshöhe K
const p₀     = 101_325.0  # Druck Meereshöhe Pa
const ρ₀     = 1.225      # Dichte Meereshöhe kg/m³
const L      = 0.0065     # Temperaturgradient Troposphäre K/m
const h_trop = 11_000.0   # Tropopause m
const T_trop = T₀ - L * h_trop   # Temperatur an Tropopause
const p_trop = p₀ * (T_trop / T₀)^(g₀ / (L * R_s))

# ─────────────────────────────────────────────────────────────
# AUFGABE 1: Temperaturprofil
# ─────────────────────────────────────────────────────────────

# ISA-Temperatur in Abhängigkeit der Höhe h (in Metern).
# Troposphäre:        0     ≤ h ≤ 11 000 m  → linear fallend
# Untere Stratosphäre: 11 000 < h ≤ 20 000 m → konstant 216.65 K
function isa_temperature(h)
    # TODO: Gib T(h) zurück.
    # Tipp: Nutze if/else für die beiden Schichten.

end

# ─────────────────────────────────────────────────────────────
# AUFGABE 2: Druckprofil
# ─────────────────────────────────────────────────────────────

# ISA-Druck in Pa.
# Troposphäre:   p(h) = p₀ · (T(h)/T₀)^(g/(L·Rₛ))
# Stratosphäre:  p(h) = p_trop · exp(-g/(Rₛ·T_trop) · (h - h_trop))
function isa_pressure(h)
    # TODO:

end

# ISA-Dichte in kg/m³ über ideales Gasgesetz: ρ = p / (Rₛ · T)
function isa_density(h)
    # TODO:

end

# ─────────────────────────────────────────────────────────────
# Schallgeschwindigkeit und Machzahl
# ─────────────────────────────────────────────────────────────

function speed_of_sound(h)
    # TODO: c = sqrt(γ · Rₛ · T(h))

end

function mach_number(v, h)
    return abs(v) / speed_of_sound(h)
end

# ─────────────────────────────────────────────────────────────
# AUFGABE 3+4: Aerodynamischer Widerstand
# ─────────────────────────────────────────────────────────────

# Mach-abhängiger Widerstandsbeiwert
function drag_coefficient(mach)
    # TODO: Cd = 0.3 + 0.5 * exp(-((mach - 1.0) / 0.3)^2)

end

# Luftwiderstandskraft in N
# h    : Höhe (m)
# v    : Geschwindigkeit (m/s)
# A    : Querschnittsfläche (m²)
# Cd   : Widerstandsbeiwert
function aerodrag(h, v, A, Cd)
    ρ = isa_density(h)
    # TODO: F = 0.5 * ρ * v² * Cd * A

end

# ─────────────────────────────────────────────────────────────
# PLOTS: Atmosphärenprofile
# ─────────────────────────────────────────────────────────────

h_range = range(0, 20_000, length=500)

# Temperatur
p_temp = plot(isa_temperature.(h_range), h_range ./ 1000,
              xlabel="Temperatur T (K)", ylabel="Höhe (km)",
              title="ISA Temperaturprofil", lw=2, color=:red,
              label="T(h)")
vline!(p_temp, [T_trop], ls=:dash, color=:gray, label="Tropopause")

# Dichte
p_dens = plot(isa_density.(h_range), h_range ./ 1000,
              xlabel="Dichte ρ (kg/m³)", ylabel="Höhe (km)",
              title="ISA Dichteprofil", lw=2, color=:blue,
              label="ρ(h)")

# Schallgeschwindigkeit
p_sound = plot(speed_of_sound.(h_range), h_range ./ 1000,
               xlabel="Schallgeschwindigkeit c (m/s)", ylabel="Höhe (km)",
               title="ISA Schallgeschwindigkeit", lw=2, color=:green,
               label="c(h)")

# Cd vs Mach
mach_range = range(0, 3, length=300)
p_cd = plot(mach_range, drag_coefficient.(mach_range),
            xlabel="Machzahl", ylabel="Cd",
            title="Widerstandsbeiwert vs Mach", lw=2, color=:orange,
            label="Cd(Ma)")
vline!(p_cd, [1.0], ls=:dash, color=:gray, label="Ma = 1")

display(plot(p_temp, p_dens, p_sound, p_cd, layout=(2,2), size=(900,700)))

# ─────────────────────────────────────────────────────────────
# CHECKS — überprüfe deine Handrechnung aus Aufgabe 1
# ─────────────────────────────────────────────────────────────
println("\n===== Checks =====")
checks = [
    ("T( 0 m)",      isa_temperature(0.0),     288.15,  0.01),
    ("T(5000 m)",    isa_temperature(5000.0),   255.65,  0.1),
    ("T(11000 m)",   isa_temperature(11000.0),  216.65,  0.1),
    ("T(15000 m)",   isa_temperature(15000.0),  216.65,  0.1),
    ("ρ( 0 m)",      isa_density(0.0),          1.225,   0.01),
    ("ρ(5000 m)",    isa_density(5000.0),        0.7364,  0.01),
    ("ρ(11000 m)",   isa_density(11000.0),       0.3639,  0.01),
    ("c( 0 m)",      speed_of_sound(0.0),        340.3,   0.5),
    ("Cd(Ma=1.0)",   drag_coefficient(1.0),      0.8,     0.01),
    ("Cd(Ma=0.0)",   drag_coefficient(0.0),      0.3,     0.02),
]

for (name, got, expected, tol) in checks
    ok = @isdefined(isa_temperature) && isapprox(got, expected, atol=tol)
    println("  $name = $(round(got, digits=4))  (erwartet ≈ $expected)  $(ok ? "✓" : "✗")")
end
