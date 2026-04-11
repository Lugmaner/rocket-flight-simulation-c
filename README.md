# Rocket Flight Simulation (C)

A physics-based rocket flight simulation written in C.  
This project focuses on **numerical simulation, system modeling, and physically grounded computation**.

---

## Overview

The simulation models the vertical flight of a rocket under the influence of:

- Thrust  
- Gravity (altitude-dependent)
- Aerodynamic drag (Mach-dependent)
- Fuel consumption (mass flow)  

The system is updated in discrete time steps using **Runge-Kutta 4 (RK4)** numerical integration.

---

## Physics Model

- **Gravity** — decreases with altitude: `g = 9.81 * (R / (R + h))²`
- **Atmospheric density** — exponential decay with altitude
- **Aerodynamic drag** — Mach-dependent drag coefficient via Gaussian curve:  
  `Cd(M) = 0.3 + 0.5 * exp(-((M - 1) / 0.3)²)`  
  Models the transonic drag peak at Mach 1
- **Mass reduction** — due to fuel burn (constant mass flow)
- **Thrust** — constant while fuel remains

---

## Structure

### Structs

| Struct | Description |
|--------|-------------|
| `Constants_t` | Fixed rocket parameters (dry mass, thrust, area, ...) |
| `State_t` | Current simulation state (height, velocity, mass) |
| `Derivatives_t` | Time derivatives (dh, dv, dm) used by the integrator |

### Update Pipeline (per step)

1. Compute k1–k4 via `calc_derivatives`
2. Combine with RK4 weighted average
3. Update state (height, velocity, mass)
4. Apply boundary checks (ground, dry mass)

---

## Features

- **RK4 integration** for accurate numerical results
- **Mach-dependent drag** with transonic peak at Mach 1
- **Altitude-dependent gravity**
- **Optional CSV output** for data visualization
- Dynamic tracking of maximum height, velocity, lowest air density
- Fuel depletion and ground impact detection

---

## Usage

```bash
./sim <time_seconds>                   # run simulation
./sim <time_seconds> output.csv        # run and export to CSV
```

### Example

```bash
./sim 300 output.csv
```

### CSV Format

```
time,height,velocity,acceleration,aerodrag
0.010,0.058,5.802,580.156,0.021
...
```

---

## Build

```bash
./compileSim.sh main.c sim
```

---

## Limitations

- 1D vertical motion only
- No rocket staging
- Simplified atmosphere model (no temperature profile)
- Constant thrust (no thrust curve)
- No orbital mechanics