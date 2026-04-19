# Rocket Science Workbook — 2D Simulation in Julia

## Ablaufplan

Arbeite die Kapitel **in Reihenfolge** ab. Jedes Kapitel baut auf dem vorherigen auf.

---

### Kapitel 01 — Euler-Verfahren
**PDF:** `workbook/01_euler/theory.pdf`
**Template:** `workbook/01_euler/template.jl`

Was du lernst: Was eine ODE ist, geometrische Interpretation, Fehlerordnung O(h).

Rechenaufgaben (auf Papier):
- [ ] Aufgabe 1: Euler 5 Schritte für dy/dt = -y von Hand
- [ ] Aufgabe 2: Fehlervergleich h=0.2 vs h=0.5
- [ ] Aufgabe 3: Freier Fall als 2D-Zustandsvektor
- [ ] Aufgabe 4: Stabilitätsanalyse

Implementierung:
- [ ] `euler_step` funktioniert
- [ ] `euler_solve` funktioniert
- [ ] Alle Checks grün

---

### Kapitel 02 — Runge-Kutta 4 (RK4)
**PDF:** `workbook/02_rk4/theory.pdf`
**Template:** `workbook/02_rk4/template.jl`

Was du lernst: k1-k4 Herleitung, Fehlerordnung O(h^4), Butcher-Tableau.

Rechenaufgaben:
- [ ] Aufgabe 1: RK4 einen Schritt von Hand (k1 bis k4)
- [ ] Aufgabe 2: Fehlerordnungstabelle ausfüllen
- [ ] Aufgabe 3: Freier Fall mit RK4 (Vektor-System)
- [ ] Aufgabe 4: Butcher-Tableau lesen

Implementierung:
- [ ] `rk4_step` für Skalare und Vektoren
- [ ] `rk4_solve` vollständig
- [ ] Fehlerplot zeigt Euler O(h) vs RK4 O(h^4) auf Log-Skala

---

### Kapitel 03 — ISA-Atmosphäre
**PDF:** `workbook/03_atmosphere/theory.pdf`
**Template:** `workbook/03_atmosphere/template.jl`

Was du lernst: Hydrostatische Gleichung als DGL, ISA-Schichten, Schallgeschwindigkeit.

Rechenaufgaben:
- [ ] Aufgabe 1: T, rho, c für 5 Höhen berechnen
- [ ] Aufgabe 2: Isotherme Stratosphäre: DGL analytisch lösen
- [ ] Aufgabe 3: F_drag auf 3 Höhen vergleichen
- [ ] Aufgabe 4: Cd(Ma) Maximum bestimmen

Implementierung:
- [ ] `isa_temperature`, `isa_pressure`, `isa_density`
- [ ] `speed_of_sound`, `drag_coefficient`, `aerodrag`
- [ ] Alle 4 Atmosphärenplots korrekt
- [ ] Alle Checks grün

---

### Kapitel 04 — 2D-Physik
**PDF:** `workbook/04_physics_2d/theory.pdf`
**Template:** `workbook/04_physics_2d/template.jl`

Was du lernst: Kräftezerlegung in 2D, Zustandsvektor, Newton als ODE-System.

Rechenaufgaben:
- [ ] Aufgabe 1: Kräfte bei theta=75° vollständig berechnen
- [ ] Aufgabe 2: Massenstrom und Brenndauer
- [ ] Aufgabe 3: Einen RK4-Schritt für das 5D-System

Implementierung:
- [ ] `gravity(y)` mit Höhenabhängigkeit
- [ ] `derivatives_2d(t, s, params)` vollständig
- [ ] Senkrechter Start plottet korrekt
- [ ] Alle Checks grün

---

### Kapitel 05 — Gravity Turn
**PDF:** `workbook/05_gravity_turn/theory.pdf`
**Template:** `workbook/05_gravity_turn/template.jl`

Was du lernst: Pitchprogramm, Velocity Tracking, Tsiolkovsky, Gravitationsverluste.

Rechenaufgaben:
- [ ] Aufgabe 1: Tsiolkovsky 1-stufig und 2-stufig
- [ ] Aufgabe 2: Lineares Pitchprogramm tabellarisch + zeichnen
- [ ] Aufgabe 3: Velocity Tracking Winkel berechnen
- [ ] Aufgabe 4: Gravitationsverlust-Integral (Trapezregel)

Implementierung:
- [ ] `pitch_linear` korrekt
- [ ] `pitch_velocity_tracking` korrekt
- [ ] Vergleichs-Trajektorie zeigt Unterschied beider Strategien

---

### Kapitel 06 — Stufentrennung
**PDF:** `workbook/06_staging/theory.pdf`
**Template:** `workbook/06_staging/template.jl`

Was du lernst: Strukturkoeffizient, mehrstufige Raketengleichung, Event Detection.

Rechenaufgaben:
- [ ] Aufgabe 1: Optimales Massenverhältnis, Delta-v berechnen
- [ ] Aufgabe 2: Trennzeitpunkt und Massensprung
- [ ] Aufgabe 3: 1 vs 2 vs 3 Stufen vergleichen

Implementierung:
- [ ] `Stage`-Struct definiert
- [ ] `simulate_multistage` mit Staging-Logik
- [ ] Massenplot zeigt Sprung bei Stufentrennung
- [ ] Tsiolkovsky vs Simulation Vergleich in Terminal

---

### Kapitel 07 — Visualisierung
**PDF:** `workbook/07_visualization/theory.pdf`
**Template:** `workbook/07_visualization/template.jl`

Was du lernst: Phasenraum, Energiebilanz, 3D-Plots, Animation.

Rechenaufgaben:
- [ ] Aufgabe 1: Phasenraum Phase A/B interpretieren
- [ ] Aufgabe 2: LEO-Energie berechnen, Oberth-Effekt
- [ ] Aufgabe 3: 3D-Erweiterung konzeptuell durchdenken

Implementierung:
- [ ] `plot_dashboard` — alle 6 Panels korrekt
- [ ] GLMakie installiert: `] add GLMakie`
- [ ] 3D-Plot rotierbar
- [ ] Animation erstellt (`rocket_flight.gif`)

---

## PDFs kompilieren

```bash
cd workbook
make all        # kompiliert alle 7 PDFs
make 01_euler/theory.pdf   # einzelnes Kapitel
make clean      # löscht Hilfsdateien
```

Benötigt: `pdflatex` (TeX Live oder MiKTeX)

## Julia starten

```julia
# Im simulation-2D-jl Verzeichnis:
julia --project=. workbook/01_euler/template.jl
```

Oder in REPL:
```julia
julia> ]activate .
julia> include("workbook/01_euler/template.jl")
```
