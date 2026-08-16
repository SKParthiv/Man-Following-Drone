# Architecture

## Goal

Pocket Follow Drone.

Follow a phone-held user in a dynamic environment over short-range Wi-Fi.

The system is divided into:

* Phone-side high-level control
* Drone-side low-level control
* Physical hardware
* ROS2/Gazebo simulation

---

# 1. System Architecture

```text
                         PHYSICAL DRONE
                              │
                              │
                    ┌─────────▼─────────┐
                    │ Sensor Aggregation│
                    └─────────┬─────────┘
                              │
                              ▼
                    ┌───────────────────┐
                    │ State Estimation  │
                    └───────┬─────┬─────┘
                            │     │
                ┌───────────┘     └──────────────┐
                ▼                                ▼
       Stabilisation / PID              WiFi Interface
          Controller                          ▲
                │                             │
                ▼                             │
             ESCs + Motors                    │
                │                             │
                ▼                             │
         Physical Motion                      │
                │                             │
                └────────── Feedback ────────┘
                              │
                              │
                         WiFi Interface
                              ▲
                              │
                    ┌─────────┴─────────┐
                    │ Action Command    │
                    │ Understanding     │
                    └─────────┬─────────┘
                              ▲
                              │
                    ┌─────────┴─────────┐
                    │ State Reader +    │
                    │ High-Level Control│
                    └─────────┬─────────┘
                              ▲
                              │
                    ┌─────────┴─────────┐
                    │ Path Finding /    │
                    │ Planning          │
                    └─────────┬─────────┘
                              ▲
                              │
                    ┌─────────┴─────────┐
                    │ Phone Sensor      │
                    │ Aggregation       │
                    └─────────┬─────────┘
                              ▲
                              │
                       GNSS + Phone IMU
```

---

# 2. Phone

The phone is the **high-level compute node**.

It provides:

* User position
* User motion information
* High-level state
* Path planning
* Follow logic
* High-level movement commands
* User interface

The phone does not directly control motors.

---

# 3. Phone Sensor Aggregation

The phone combines available phone sensors into useful user information.

Inputs may include:

* GNSS
* IMU
* Compass
* Other phone sensors where useful

Output:

```text
User position
User velocity
User heading
Sensor confidence
```

The exact sensor-fusion method will be determined during development.

---

# 4. Planning

The path-planning layer determines where the drone should move.

Inputs:

* User state
* Drone state
* Desired follow distance
* Desired height
* Environment information

Output:

```text
Desired drone state
```

This layer should not know about:

* Motors
* ESCs
* PID
* IMU registers
* Motor speeds

It operates at the motion/planning level.

---

# 5. State Reader + High-Level Control

This layer maintains the high-level understanding of the system.

It reads:

* User state
* Drone state
* Path-planning output

It determines the desired drone behaviour.

Example output:

```text
Desired position
Desired velocity
Desired altitude
Desired yaw
```

---

# 6. WiFi Interface

Wi-Fi is the short-range communication link between phone and drone.

```text
Phone
  │
  │ WiFi
  ▼
Drone
```

The interface carries:

* High-level commands
* Drone state
* Telemetry
* Status
* Safety information

The communication protocol should remain minimal.

---

# 7. Action Command Understanding

This layer converts high-level commands into commands understood by the low-level flight system.

Example:

```text
High-level:

Move toward user
Maintain 2 m distance
Maintain 1.5 m altitude

        ↓

Low-level command:

vx
vy
vz
yaw
```

This separates **what the drone should do** from **how the flight controller physically achieves it**.

---

# 8. Drone Sensor Aggregation

The drone collects and processes its physical sensors.

V1 sensors:

* IMU
* MicoAir MTF-01P

  * Optical Flow
  * ToF

The aggregation layer produces usable sensor data for state estimation and control.

---

# 9. State Estimation

State estimation converts sensor information into the drone's best estimate of its current state.

Possible state:

```text
Position
Velocity
Altitude
Attitude
Yaw
Sensor confidence
```

Conceptually:

```text
Raw Sensors
     ↓
Sensor Aggregation
     ↓
State Estimation
     ↓
Drone State
```

The state estimate is consumed by both:

* High-level communication
* Low-level stabilization

---

# 10. Stabilisation / PID Controller

The stabilization layer handles low-level flight control.

Inputs:

* Desired motion
* Current drone state

Outputs:

* Motor commands

Responsibilities:

* Attitude stabilization
* Altitude control
* Velocity control where implemented
* PID control
* Motor command generation

The stabilization layer should not perform path planning.

---

# 11. Physical System

```text
Sensors
   ↓
Sensor Aggregation
   ↓
State Estimation
   ↓
Stabilisation / PID
   ↓
ESCs
   ↓
Brushless Motors
   ↓
Physical Motion
   ↓
Sensors
```

This creates the physical feedback loop.

---

# 12. Safety

Safety logic can override normal commands.

```text
High-Level Control ──┐
                     ├──► Safety ──► Flight Control
Manual Control ──────┘
```

Safety may handle:

* Communication loss
* Invalid commands
* Sensor failure
* Low battery
* Emergency landing
* Flight limits

Safety has higher priority than normal movement commands.

---

# 13. ROS2 Architecture

ROS2 is used as the software integration framework.

Conceptual nodes:

```text
PHONE SIDE

Phone Sensors
      ↓
Phone Sensor Aggregation
      ↓
Path Planner
      ↓
High-Level Controller
      ↓
WiFi
```

```text
DRONE SIDE

WiFi
  ↓
Action Command
  ↓
State Estimation
  ↓
Stabilisation
  ↓
Motor Control
```

The exact ROS2 node and package structure will be created during implementation.

Implementation:

[`ros2_ws/`](ros2_ws/)

---

# 14. Gazebo

Gazebo mirrors the physical architecture.

```text
ROS2
 │
 ├── Phone-side logic
 ├── Drone-side logic
 ├── Sensors
 └── Controllers
       │
       ▼
    Gazebo
       │
       ├── Drone
       ├── World
       └── Sensor simulation
```

Simulation should reproduce the important interfaces and feedback loops of the physical system.

---

# 15. Architecture Principles

1. Phone handles high-level decisions.
2. ESP32 handles low-level flight control.
3. Sensor data is separated from state estimation.
4. Planning is separated from control.
5. High-level commands are separated from physical actuation.
6. Safety can override normal control.
7. Communication should remain minimal.
8. Simulation should mirror the physical architecture.
9. Do not add a layer without a clear responsibility.
10. Do not put low-level hardware logic into high-level planning.
11. Keep V1 short-range and simple.
12. Keep the architecture independent of specific implementation details where practical.

---

# 16. Repository Links

* [Product Requirements](README.md)
* [Components](Components.md)
* [ROS2 Workspace](ros2_ws/)
* [Configuration](config/)

