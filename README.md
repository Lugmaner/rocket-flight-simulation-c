# Rocket Flight Simulation (C)

A physics-based rocket flight simulation written in C.  
This project focuses on **numerical simulation, system modeling, and physically grounded computation**.

---

## Overview

The simulation models the vertical flight of a multi-stage rocket under the influence of:

- Thrust (per-stage configurable)
- Gravity (altitude-dependent)
- Aerodynamic drag (Mach-dependent)
- Fuel consumption (mass flow per stage)
- Stage separation when fuel is depleted

The system is updated in discrete time steps using **Runge-Kutta 4 (RK4)** numerical integration.

---

## Physics Model

- **Gravity** — decreases with altitude: `g = 9.81 * (R / (R + h))²`
- **Atmospheric density** — exponential decay with altitude
- **Aerodynamic drag** — Mach-dependent drag coefficient via Gaussian curve:  
  `Cd(M) = 0.3 + 0.5 * exp(-((M - 1) / 0.3)²)`  
  Models the transonic drag peak at Mach 1
- **Mass** — total mass of all remaining stages, updated every RK4 step
- **Thrust** — constant per stage while fuel remains

---

## Structure

### Files

| File | Description |
|------|-------------|
| `types.h` | All struct definitions and physical constants |
| `physics.h/c` | Physics calculations (drag, gravity, thrust, acceleration, derivatives) |
| `init.h/c` | Rocket and state initialization |
| `output.h/c` | Terminal output and CSV writing |
| `simulation.h/c` | RK4 integrator, staging logic, simulation loop |
| `main.c` | Entry point, argument parsing |

### Structs

| Struct | Description |
|--------|-------------|
| `Stage_t` | Per-stage parameters: mass, dry mass, thrust, mass flow, area |
| `Constants_t` | Engine parameters (thrust, mass flow, cross-section area) — embedded in `Stage_t` |
| `State_t` | Current simulation state (height, velocity, total mass) |
| `Derivatives_t` | Time derivatives (dh, dv, dm) used by the integrator |
| `Rocket_t` | Full rocket: state, stages array, current stage pointer |

### Update Pipeline (per step)

1. Compute k1–k4 via `calc_derivatives`
2. Combine with RK4 weighted average
3. Update state (height, velocity, mass) and current stage mass
4. Check for stage separation → drop empty stage, advance to next
5. Apply boundary checks (ground, dry mass)

---

## Configuration

Stage parameters are defined in `simulate_flight` in `simulation.c`:

```c
Stage_t stageConfigs[] = {
    {.dryMass = 5000.0, .mass = 35000.0, .constants = {.massStream = 300.0, .crossSectionArea = 10.0, .thrust0 = 1400000.0}},
    {.dryMass = 5000.0, .mass = 35000.0, .constants = {.massStream = 300.0, .crossSectionArea = 10.0, .thrust0 = 1400000.0}},
    {.dryMass = 5000.0, .mass = 35000.0, .constants = {.massStream = 300.0, .crossSectionArea = 10.0, .thrust0 = 1400000.0}},
};
```

Adding a stage = adding one line to the array.

---

## Usage

```bash
./rocket <time_seconds>                # run simulation
./rocket <time_seconds> output.csv    # run and export to CSV
```

### Example

```bash
./rocket 400 output.csv
```

### CSV Format

```
time s,mass kg,height m,velocity m/s,mach,acceleration m/s^2,aerodrag N,numOfStages
1.000,104700.000,0.464,0.928,...
...
```

---

## Build

```bash
./compileSim.sh rocket
```

---

## Limitations

- 1D vertical motion only
- Simplified atmosphere model (no temperature profile, no wind)
- Constant thrust per stage (no thrust curve)
- No orbital mechanics
