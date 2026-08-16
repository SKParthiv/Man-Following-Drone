# Product Requirements Document (PRD)

# Project Name

**Pocket Follow Drone (V1)**

Version: **1.0**
Status: **Planning**
Author: *S K Parthiv Pedapati*

---

# 1. Overview

Pocket Follow Drone is a low-cost autonomous aerial camera platform designed to follow a user carrying a phone over short range.

The phone acts as the high-level compute and planning system.

The drone contains an ESP32-based low-level flight controller responsible for sensing, state estimation, stabilization, and physical movement.

The system uses Wi-Fi for communication between the phone and drone.

V1 focuses on building the smallest practical system that can achieve stable autonomous flight and reliable short-range following.

The project prioritizes:

* Low Cost
* Lightweight Design
* Open Hardware
* Open Software
* Simplicity
* Expandability

---

# 2. Problem Statement

Autonomous drones often require expensive flight controllers, GNSS systems, companion computers, and large sensor suites.

For a short-range follow-me system, much of this complexity may be unnecessary.

This project investigates whether the following architecture is sufficient:

```text
Phone
  ↓
User State
  ↓
Path Planning
  ↓
High-Level Control
  ↓
Wi-Fi
  ↓
ESP32
  ↓
State Estimation
  ↓
Stabilisation
  ↓
Motors
```

The objective is to achieve useful autonomous following while minimizing cost, weight, hardware complexity, and onboard computation.

---

# 3. Goals

## Primary Goals

* Build a low-cost autonomous drone
* Follow a user carrying a phone
* Maintain configurable distance
* Maintain configurable height
* Hover stably
* Execute high-level commands from the phone
* Estimate drone state using onboard sensors
* Use optical flow and ToF for local motion and altitude information
* Record video
* Design a custom lightweight frame

## Secondary Goals

* ROS2 integration
* Gazebo simulation
* Custom PCB
* Mobile application
* OTA firmware updates
* Expandable sensor support

---

# 4. Scope

V1 is a **short-range follow drone**.

V1 includes:

* Phone-based high-level control
* Phone GNSS/IMU sensing
* Wi-Fi communication
* ESP32 flight control
* IMU
* MicoAir MTF-01P
* Optical flow
* ToF
* Local drone state estimation
* Path planning
* Stabilization
* Video recording
* ROS2 development
* Gazebo simulation

V1 does not include:

* Long-range communication
* LoRa
* Drone GNSS
* Waypoint navigation
* Return-to-home
* Obstacle avoidance
* AI-based visual tracking

These may be considered in later versions.

---

# 5. Target Users

* Content creators
* Students
* Robotics enthusiasts
* Researchers
* Hobbyists
* Open-source developers

---

# 6. Use Cases

## Primary

1. User powers on the drone.
2. Drone initializes its sensors.
3. User starts Follow Mode.
4. Phone determines user state.
5. Phone plans the required drone movement.
6. Phone sends high-level commands over Wi-Fi.
7. Drone interprets the commands.
8. Drone estimates its state.
9. Flight controller stabilizes and moves the drone.
10. Drone maintains the desired follow position.
11. Camera records video.

## Secondary

* Manual control
* Hover mode
* Emergency landing
* Video recording
* Parameter tuning
* Telemetry monitoring

---

# 7. Functional Requirements

## Flight

The drone shall:

* Take off
* Land
* Hover
* Maintain altitude
* Maintain stable attitude
* Change yaw
* Execute movement commands
* Provide state feedback

## Following

The system shall:

* Track the phone/user state
* Determine a desired drone position
* Maintain configurable distance
* Maintain configurable height
* Smoothly accelerate
* Smoothly decelerate
* Use drone state feedback

## Path Planning

The system shall:

* Accept user and drone state
* Determine desired movement
* Account for available environment information
* Produce high-level movement commands

## State Estimation

The drone shall estimate relevant state from its sensors.

Possible state:

* Position
* Velocity
* Altitude
* Attitude
* Yaw

## Camera

The system shall:

* Record video
* Start recording
* Stop recording

## Communication

Phone ↔ Drone:

* Wi-Fi

Communication shall support:

* Commands
* Drone state
* Telemetry
* Status
* Safety information

---

# 8. Performance Requirements

| Parameter       | Target          |
| --------------- | --------------- |
| Flight Time     | 20–30 min       |
| Weight          | < 800 g         |
| Ideal Weight    | 500–700 g       |
| Speed           | Walking/Jogging |
| Startup Time    | < 10 sec        |
| Video           | ≥ 240p          |
| Hover Accuracy  | ±20 cm target   |
| Communication   | Wi-Fi           |
| Operating Range | Short range     |

---

# 9. System Architecture

```text
                         PHONE
                           │
                    GNSS + Phone IMU
                           │
                           ▼
                Phone Sensor Aggregation
                           │
                           ▼
                   Path Planning
                           │
                           ▼
              State Reader / High-Level
                     Control
                           │
                           │ Wi-Fi
                           ▼
              Action Command Understanding
                           │
                           ▼
                  Drone State Estimation
                           ▲
                           │
                 Sensor Aggregation
                           ▲
                           │
                    IMU + MTF-01P
                           │
                           ▼
                 Stabilisation / PID
                           │
                           ▼
                     ESCs + Motors
                           │
                           ▼
                   Physical Motion
```

Detailed architecture:

[Architecture.md](Architecture.md)

---

# 10. Hardware Requirements

## Flight Controller

Custom ESP32-based flight controller.

## Processor

ESP32.

## Sensors

### Drone

* IMU
* MicoAir MTF-01P

  * Optical Flow
  * ToF

### Phone

* GNSS
* IMU
* Compass where useful

## Camera

Camera suitable for aerial video recording.

## ESC

4-in-1 brushless ESC.

## Motors

Brushless outrunner motors.

## Battery

LiPo or Li-ion depending on final power requirements.

## Frame

Custom lightweight frame.

---

# 11. Software Architecture

## Phone

Responsibilities:

* Sensor aggregation
* User state
* Path planning
* High-level control
* User interface
* Telemetry
* Parameter configuration
* Camera control

## ESP32

Responsibilities:

* Sensor aggregation
* State estimation
* Stabilization
* PID control
* Altitude control
* Odometry/state feedback
* ESC control
* Safety
* Wi-Fi communication

## ROS2

Responsibilities:

* Node integration
* Communication
* Simulation
* Testing
* Parameters
* Architecture validation

## Gazebo

Responsibilities:

* Drone simulation
* Sensor simulation
* Environment simulation
* Flight testing
* Follow-system testing

---

# 12. Engineering Goals

## Cost

Keep total BOM below **₹10,000**.

## Weight

Target:

**500–700 g**

Maximum:

**800 g**

## Endurance

Target:

**20–30 minutes**

## Manufacturability

* 3D printable where practical
* Easy assembly
* Replaceable parts
* Simple construction

---

# 13. Constraints

* Low budget
* Open source
* Minimal hardware
* Short-range operation
* Consumer components where practical
* Easy reproduction
* Limited onboard computation
* Low weight
* Wi-Fi as the V1 communication link

---

# 14. Risks

## Flight Stability

A custom ESP32 flight controller is significantly harder to develop than using an established flight controller.

## Communication Latency

Wi-Fi latency must remain low enough for stable high-level control.

## Sensor Accuracy

Optical flow and ToF performance may vary with:

* Surface
* Lighting
* Height
* Motion
* Environment

## State Estimation

Sensor errors may cause incorrect estimates of drone position, velocity, altitude, or attitude.

## Phone Position

GNSS and phone IMU measurements may contain noise and drift.

## Path Planning

A useful follow behaviour requires reliable user and drone state.

## Battery Life

Small batteries reduce endurance.

## Weight

Additional electronics and sensors directly reduce flight time.

---

# 15. Success Criteria

The project is considered successful when:

* The drone can hover reliably.
* The drone can take off and land safely.
* The drone can follow the user at short range.
* The drone maintains configurable distance.
* The drone maintains configurable height.
* The phone can provide high-level movement commands.
* The drone can interpret and execute those commands.
* The drone provides useful state feedback.
* The drone records usable video.
* Total BOM remains below ₹10,000.
* Flight time exceeds 20 minutes.

---

# 16. Future Roadmap

## V2

* Improved state estimation
* Improved optical flow
* Improved ToF
* Better camera
* Improved stabilization

## V3

* Obstacle avoidance
* AI tracking
* Auto orbit
* Gesture control

## V4

* Drone GNSS
* Long-range communication
* LoRa
* Waypoint navigation
* Return-to-user
* Extended autonomous operation

---

# 17. Bill of Materials

| Component       | Status   |
| --------------- | -------- |
| ESP32           | TBD      |
| IMU             | TBD      |
| MicoAir MTF-01P | Selected |
| ESC             | TBD      |
| Motors          | TBD      |
| Battery         | TBD      |
| Camera          | TBD      |
| Frame           | TBD      |
| Propellers      | TBD      |
| Connectors      | TBD      |

---

# 18. Project Milestones

## Milestone 1 — Architecture

* [ ] Finalize system architecture
* [ ] Define interfaces
* [ ] Define ROS2 architecture
* [ ] Define Gazebo architecture

## Milestone 2 — Components

* [ ] Select all components
* [ ] Verify component compatibility
* [ ] Verify weight budget
* [ ] Verify power budget

## Milestone 3 — Simulation

* [ ] Create drone model
* [ ] Create sensor models
* [ ] Create environment
* [ ] Implement sensor aggregation
* [ ] Implement state estimation
* [ ] Implement path planning
* [ ] Implement high-level control
* [ ] Implement stabilization
* [ ] Test follow behaviour

## Milestone 4 — Engineering

* [ ] Weight budget
* [ ] Power budget
* [ ] Cost budget
* [ ] Propulsion calculations
* [ ] Control calculations

## Milestone 5 — Hardware

* [ ] CAD design
* [ ] Frame design
* [ ] Assemble hardware
* [ ] Integrate ESP32
* [ ] Integrate sensors
* [ ] Integrate ESCs and motors

## Milestone 6 — Flight Controller

* [ ] IMU driver
* [ ] Sensor aggregation
* [ ] State estimation
* [ ] Stabilization
* [ ] PID
* [ ] Altitude control
* [ ] Movement control
* [ ] Wi-Fi interface
* [ ] Safety

## Milestone 7 — Phone

* [ ] Phone sensor aggregation
* [ ] Communication
* [ ] User state
* [ ] Path planning
* [ ] High-level control
* [ ] User interface
* [ ] Telemetry

## Milestone 8 — Flight Testing

* [ ] Manual hover
* [ ] Takeoff
* [ ] Landing
* [ ] Movement
* [ ] State estimation
* [ ] Position control
* [ ] Follow Mode

## Milestone 9 — Documentation

* [ ] Hardware documentation
* [ ] Software documentation
* [ ] Architecture documentation
* [ ] Build instructions
* [ ] Testing documentation

---

# 19. Design Principles

1. Keep V1 simple.
2. Minimize component count.
3. Separate sensing, state estimation, planning, and control.
4. Keep high-level decisions on the phone.
5. Keep low-level control on the ESP32.
6. Do not put hardware-level logic into path planning.
7. Do not put path planning into the stabilization controller.
8. Use feedback wherever required for reliable control.
9. Safety has priority over normal commands.
10. Keep communication minimal.
11. Keep simulation and physical architecture similar.
12. Optimize cost, weight, and power together.
13. Every added component must justify its cost, weight, and power.
14. Do not add future features to V1 without a clear requirement.

---

# 20. Open Questions

* How accurately can the phone estimate the user's state?
* How should phone GNSS and IMU data be fused?
* How should phone state and drone state be combined?
* What is the best representation of the desired follow position?
* How accurately can the MTF-01P provide local motion and altitude information?
* What state-estimation method should run on the ESP32?
* What commands should cross the Wi-Fi interface?
* What is the minimum reliable follow distance?
* What Wi-Fi architecture provides sufficiently low latency?
* Can the ESP32 provide sufficiently stable autonomous flight?
* What propulsion system provides the best efficiency for a 500–700 g airframe?
* Can the complete system remain below ₹10,000?
* How well does the system perform under different surfaces and lighting conditions?

