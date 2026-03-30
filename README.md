# Rocket Flight Simulation (C)

A physics-based rocket flight simulation written in C.  
This project focuses on **numerical simulation, system modeling, and physically grounded computation**.

---

## Overview

The simulation models the vertical flight of a rocket under the influence of:

- Thrust  
- Gravity  
- Aerodynamic drag  
- Fuel consumption (mass flow)  

The system is updated in discrete time steps using a simple numerical integration approach.

---

## Physics Model

The simulation includes:

- **Gravity** (constant acceleration)  
- **Atmospheric density model** (exponential decay with altitude)  
- **Aerodynamic drag**  
  - \( F_d = \frac{1}{2} \rho v^2 C_d A \)
- **Mass reduction due to fuel burn**
- **Thrust-to-mass dependent acceleration**

All values are updated iteratively over time.

---

## Structure

The simulation is based on a central `Rocket_t` structure containing:

- Current velocity, height, acceleration  
- Mass, fuel, thrust  
- Aerodynamic properties (drag coefficient, cross-section)  
- State flags (e.g. fuel empty)  

---

### Update Pipeline

Each simulation step performs:

1. Mass update (fuel consumption)  
2. Fuel check  
3. Aerodynamic drag calculation  
4. Acceleration update  
5. Velocity update  
6. Position update  

---

## Features

- Time-stepped simulation (fixed Δt)  
- Dynamic tracking of:
  - Maximum height  
  - Maximum velocity  
  - Lowest atmospheric density  
- Fuel depletion handling  
- Ground impact detection  
- Continuous console output of system state  

---

## Example Output

The simulation prints values such as:

- Time  
- Acceleration  
- Velocity  
- Height  
- Remaining fuel  
- Aerodynamic drag  
- Air density  

---

## Limitations

- 1D vertical motion only  
- No advanced integration methods (e.g. Runge-Kutta)  
- Constant thrust (no staging)  
- Simplified atmosphere model  
- No orbital mechanics  

---

## Build

Using the provided script:

```bash
./compileSim.sh main.c sim
