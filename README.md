# Man-Following Autonomous Drone

> An autonomous aerial robot capable of locating, navigating to, and following a designated user while avoiding dynamic obstacles using onboard intelligence.

---

## Overview

This project aims to build a lightweight autonomous quadcopter that can travel to a user's location from a distant starting point and continuously follow them at a configurable distance.

Unlike conventional "Follow Me" drones that require the user to remain within communication range, this system is designed around a two-stage communication architecture:

1. **Long-range communication** using LoRa through a wearable beacon.
2. **High-bandwidth communication** using Wi-Fi once the drone reaches the user.

The drone is intended to function as a research platform emphasizing modularity, autonomy, and future extensibility.

---

# Goals

The primary goals of the project are:

- Autonomous navigation to the user.
- Follow the user while maintaining a safe distance.
- Dynamic obstacle avoidance.
- Lightweight and efficient design.
- Modular hardware architecture.
- ROS2-compatible software stack.
- Expandable for future research.

---

# Project Requirements

## Functional Requirements

- Follow the designated user at approximately **1–2 meters**.
- Receive a remote deployment command.
- Navigate autonomously from its current location to the user's location.
- Avoid both static and dynamic obstacles.
- Continue tracking while the user moves.
- Recover from temporary loss of visual tracking.
- Return to home or land safely when required.

---

## Communication Requirements

### Long Range

Used only for mission deployment and telemetry.

Requirements:

- Extremely long range
- Low power
- Small packet size
- Reliable

Chosen Technology:

- **LoRa**

---

### Short Range

Activated once the drone reaches the user.

Requirements:

- High bandwidth
- Low latency
- Video streaming
- Debugging
- Configuration

Chosen Technology:

- **Wi-Fi**

---

# System Architecture

```
                  Phone
          UI • Maps • Logging
                   │
           Bluetooth / USB
                   │
      ┌────────────────────────┐
      │ Wearable Navigation    │
      │ Beacon                 │
      │                        │
      │ • ESP32                │
      │ • LoRa                 │
      │ • GNSS                 │
      │ • Battery              │
      └────────────────────────┘
                   │
              Long-range LoRa
                   │
           ┌──────────────────┐
           │      Drone       │
           │                  │
           │ Flight Controller│
           │ Companion SBC    │
           │ Camera           │
           │ Obstacle Sensors │
           │ Wi-Fi            │
           └──────────────────┘
```

---

# High-Level Workflow

```
User presses Deploy

↓

Wearable Beacon sends:

• Latitude
• Longitude
• Heading
• Speed
• Timestamp

↓

Drone receives coordinates

↓

Autonomous Navigation

↓

Obstacle Avoidance

↓

Drone reaches user

↓

Switch to Wi-Fi

↓

Vision-based following

↓

Mission complete
```

---

# Development Phases

---

## Phase 0 — Research

Objectives

- Define requirements
- Explore architectures
- Study existing solutions
- Select hardware
- Estimate weight
- Estimate flight time

Deliverables

- Final architecture
- Component list
- Weight estimation
- Power estimation

---

## Phase 1 — Hardware Design

Objectives

- Select components
- Build CAD model
- Determine center of gravity
- Battery placement
- Wiring plan

Deliverables

- Complete CAD assembly
- BOM
- Mechanical layout

---

## Phase 2 — Basic Flight

Objectives

- Assemble drone
- Configure PX4 / ArduPilot
- Stable hover
- Manual flight
- Battery testing

Deliverables

- Stable autonomous platform

---

## Phase 3 — Wearable Beacon

Objectives

Develop the wearable device.

Features

- LoRa
- GNSS
- Bluetooth
- Battery
- USB Charging

Deliverables

- Working beacon
- Position broadcasting

---

## Phase 4 — Long-Range Navigation

Objectives

- Receive beacon coordinates
- Fly autonomously
- Waypoint navigation

Deliverables

Drone capable of locating the user.

---

## Phase 5 — Vision

Objectives

- Person detection
- Person tracking
- Distance estimation

Deliverables

Reliable visual tracking.

---

## Phase 6 — Obstacle Avoidance

Objectives

- Detect obstacles
- Dynamic path planning
- Safe rerouting
- Collision avoidance

Deliverables

Reliable autonomous navigation.

---

## Phase 7 — Follow Mode

Objectives

- Maintain 1–2 meter distance
- Smooth motion
- Stable camera tracking

Deliverables

Complete follow-me functionality.

---

## Phase 8 — Optimization

Objectives

- Reduce weight
- Increase endurance
- Improve algorithms
- Tune PID
- Improve power efficiency

---

# Current Hardware Direction

Current design philosophy:

- Lightweight
- Endurance focused
- Modular
- Upgradeable

Target specifications

| Item | Goal |
|------|------|
| Size | ~300 mm frame |
| Weight | As light as possible |
| Flight Time | 40–50 minutes |
| Payload | Computer vision capable |
| Communication | LoRa + Wi-Fi |

---

# Planned Software Stack

- Linux
- ROS2
- PX4
- MAVLink
- OpenCV
- Python
- C++
- Git
- Docker (optional)

---

# Future Improvements

- RTK GPS
- Stereo Vision
- SLAM
- Visual-Inertial Odometry
- Multi-target tracking
- Swarm capability
- Autonomous charging
- Battery swapping
- AI-based path planning
- Reinforcement learning

---

# TODO

## Research

- [ ] Finalize architecture
- [ ] Compare flight controllers
- [ ] Compare companion computers
- [ ] Compare GNSS modules
- [ ] Compare batteries
- [ ] Compare communication systems
- [ ] Determine regulatory constraints

---

## Hardware

- [ ] Finalize frame
- [ ] Select motors
- [ ] Select ESC
- [ ] Select propellers
- [ ] Select battery
- [ ] Select GNSS
- [ ] Select camera
- [ ] Select obstacle sensors
- [ ] Select LoRa modules
- [ ] Design wearable beacon

---

## CAD

- [ ] Collect CAD models
- [ ] Assemble prototype
- [ ] Verify clearances
- [ ] Estimate center of gravity
- [ ] Design mounting hardware

---

## Software

### Flight

- [ ] Configure PX4
- [ ] Configure MAVLink
- [ ] Configure failsafes

### Navigation

- [ ] GPS navigation
- [ ] Waypoint following
- [ ] Mission planner

### Vision

- [ ] Camera interface
- [ ] Person detection
- [ ] Person tracking

### AI

- [ ] Path planning
- [ ] Obstacle avoidance
- [ ] Local planner
- [ ] Global planner

### Communication

- [ ] LoRa protocol
- [ ] Wi-Fi communication
- [ ] Phone application
- [ ] Telemetry

---

## Testing

- [ ] Hover test
- [ ] Manual flight
- [ ] GPS accuracy
- [ ] LoRa range
- [ ] Wi-Fi bandwidth
- [ ] Obstacle avoidance
- [ ] Tracking accuracy
- [ ] Battery endurance
- [ ] Emergency stop
- [ ] Return to home

---

# Long-Term Vision

This project is intended to evolve beyond a simple follow-me drone into a modular autonomous aerial robotics platform.

Potential research directions include:

- Human-following robots
- Autonomous aerial navigation
- Dynamic obstacle avoidance
- Multi-agent systems
- Embedded AI
- Autonomous inspection
- Search and rescue
- Morphological robotics integration
- Human-drone interaction

---

# License

License to be decided.

---

# Status

🟡 **Planning & Architecture**

Current focus:

- System architecture
- Component selection
- Weight estimation
- CAD planning
