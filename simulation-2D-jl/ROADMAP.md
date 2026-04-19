# Rocket Science Workbook — 2D Simulation in Julia

> This workbook structure was designed by Claude to make the learning goal explicit:
> the primary focus of this project is **understanding** — not just producing a working simulation.
> Every chapter forces you to derive and solve the math on paper before writing a single line of code.
> The simulation is the result of learning, not the goal itself.

## How to use this workbook

Work through the chapters **in order**. Each chapter builds on the previous one.

For every chapter:
1. Compile the PDF (`make all` in `workbook/`)
2. Read the theory section
3. Solve all exercises **on paper** before touching the keyboard
4. Open `template.jl` and implement the TODO sections
5. Run the checks at the bottom — all should pass

---

### Chapter 01 — Euler Method
**PDF:** `workbook/01_euler/theory.pdf`
**Template:** `workbook/01_euler/template.jl`

What you learn: What an ODE is, geometric interpretation, global error order O(h).

Paper exercises:
- [ ] Exercise 1: Euler 5 steps for dy/dt = -y by hand
- [ ] Exercise 2: Error comparison h=0.2 vs h=0.5
- [ ] Exercise 3: Free fall as a 2D state vector
- [ ] Exercise 4: Stability analysis

Implementation:
- [ ] `euler_step` works
- [ ] `euler_solve` works
- [ ] All checks pass

---

### Chapter 02 — Runge-Kutta 4 (RK4)
**PDF:** `workbook/02_rk4/theory.pdf`
**Template:** `workbook/02_rk4/template.jl`

What you learn: k1–k4 derivation, error order O(h^4), Butcher tableau.

Paper exercises:
- [ ] Exercise 1: One full RK4 step by hand (k1 through k4)
- [ ] Exercise 2: Fill in the error order table
- [ ] Exercise 3: Free fall with RK4 (vector system)
- [ ] Exercise 4: Read and interpret the Butcher tableau

Implementation:
- [ ] `rk4_step` works for scalars and vectors
- [ ] `rk4_solve` complete
- [ ] Error plot shows Euler O(h) vs RK4 O(h^4) on log scale

---

### Chapter 03 — ISA Atmosphere
**PDF:** `workbook/03_atmosphere/theory.pdf`
**Template:** `workbook/03_atmosphere/template.jl`

What you learn: Hydrostatic equation as an ODE, ISA layers, speed of sound.

Paper exercises:
- [ ] Exercise 1: Compute T, rho, c for 5 altitudes
- [ ] Exercise 2: Solve the isothermal stratosphere ODE analytically
- [ ] Exercise 3: Compare F_drag at 3 altitudes
- [ ] Exercise 4: Find the maximum of Cd(Ma)

Implementation:
- [ ] `isa_temperature`, `isa_pressure`, `isa_density`
- [ ] `speed_of_sound`, `drag_coefficient`, `aerodrag`
- [ ] All 4 atmosphere plots look correct
- [ ] All checks pass

---

### Chapter 04 — 2D Physics
**PDF:** `workbook/04_physics_2d/theory.pdf`
**Template:** `workbook/04_physics_2d/template.jl`

What you learn: Force decomposition in 2D, state vector, Newton as an ODE system.

Paper exercises:
- [ ] Exercise 1: Compute all forces at theta=75° step by step
- [ ] Exercise 2: Mass flow rate and burn duration
- [ ] Exercise 3: One full RK4 step on the 5D system by hand

Implementation:
- [ ] `gravity(y)` with altitude dependence
- [ ] `derivatives_2d(t, s, params)` complete
- [ ] Vertical launch plots correctly
- [ ] All checks pass

---

### Chapter 05 — Gravity Turn
**PDF:** `workbook/05_gravity_turn/theory.pdf`
**Template:** `workbook/05_gravity_turn/template.jl`

What you learn: Pitch program, velocity vector tracking, Tsiolkovsky equation, gravity losses.

Paper exercises:
- [ ] Exercise 1: Tsiolkovsky for 1-stage and 2-stage rocket
- [ ] Exercise 2: Linear pitch program — table and sketch
- [ ] Exercise 3: Velocity tracking angle calculation
- [ ] Exercise 4: Gravity loss integral (trapezoidal rule)

Implementation:
- [ ] `pitch_linear` correct
- [ ] `pitch_velocity_tracking` correct
- [ ] Comparison trajectory shows difference between both strategies

---

### Chapter 06 — Multi-Stage Separation
**PDF:** `workbook/06_staging/theory.pdf`
**Template:** `workbook/06_staging/template.jl`

What you learn: Structural coefficient, multi-stage rocket equation, event detection.

Paper exercises:
- [ ] Exercise 1: Optimal mass ratio, delta-v calculation
- [ ] Exercise 2: Separation time and mass discontinuity
- [ ] Exercise 3: Compare 1 vs 2 vs 3 stages

Implementation:
- [ ] `Stage` struct defined
- [ ] `simulate_multistage` with staging logic
- [ ] Mass plot shows jump at stage separation
- [ ] Tsiolkovsky vs simulation comparison printed in terminal

---

### Chapter 07 — Visualization
**PDF:** `workbook/07_visualization/theory.pdf`
**Template:** `workbook/07_visualization/template.jl`

What you learn: Phase space, energy budget, 3D plots, animation.

Paper exercises:
- [ ] Exercise 1: Interpret phase space phases A and B
- [ ] Exercise 2: Compute LEO energy, understand Oberth effect
- [ ] Exercise 3: Think through what a 3D extension would require

Implementation:
- [ ] `plot_dashboard` — all 6 panels correct
- [ ] GLMakie installed: `] add GLMakie`
- [ ] 3D plot is rotatable
- [ ] Animation saved (`rocket_flight.gif`)

---

## Compile PDFs

```bash
cd workbook
make all                       # compile all 7 PDFs
make 01_euler/theory.pdf       # single chapter
make clean                     # remove auxiliary files
```

Requires: `pdflatex` (TeX Live or MiKTeX)

## Run Julia templates

```bash
julia --project=. workbook/01_euler/template.jl
```

Or from the REPL:
```julia
julia> ]activate .
julia> include("workbook/01_euler/template.jl")
```
