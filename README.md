# Product Requirements Document (PRD)

# Project Name

**Follow Drone (V1)**

Version: **1.0**
Status: **Planning**
Author: *S K Parthiv Pedapati*

---

# 1. Overview

Pocket Follow Drone is a low-cost autonomous aerial camera platform designed to maintain a configurable position relative to a user's phone or wearable device.

Unlike existing follow-me drones that rely on expensive GPS systems, dedicated flight controllers, and onboard AI, this project focuses on achieving reliable autonomous following using minimal hardware and custom software.

The project prioritizes:

- Low Cost
- Lightweight Design
- Open Hardware
- Open Software
- Simplicity
- Expandability

The long-term vision is to evolve this platform into a complete autonomous robotics platform while keeping Version 1 focused and achievable.

---

# 2. Problem Statement

Current autonomous drones are expensive because they require:

- Pixhawk flight controllers
- GNSS modules
- Multiple sensors
- Companion computers
- High-end processors
- Proprietary software

For a simple "follow me while recording" use case, much of this hardware is unnecessary.

The objective of this project is to investigate how much of this complexity can be removed while still maintaining stable autonomous flight.

---

# 3. Goals

## Primary Goals

- Build a low-cost autonomous drone
- Follow a user
- Record video
- Maintain configurable distance
- Maintain configurable height
- Hover stably
- Use inexpensive components
- Design custom electronics
- Design custom frame

---

## Secondary Goals

- Modular architecture
- Custom PCB
- Mobile application
- OTA firmware updates
- Expandable sensor support

---

# 5. Target Users

- Content creators
- Students
- Robotics enthusiasts
- Researchers
- Hobbyists
- Open-source developers

---

# 6. Use Cases

## Primary

The user launches the drone.

The drone stabilizes.

The user starts Follow Mode.

The drone maintains

- distance
- height
- heading

while recording video.

---

## Secondary

Manual control

Emergency landing

Hover mode

Video recording

Parameter tuning

---

# 7. Functional Requirements

## Flight

The drone shall

- Hover
- Takeoff
- Land
- Maintain pose
- Maintain altitude
- Accept velocity commands

---

## Following

The drone shall

- Follow the user
- Maintain configurable distance
- Maintain configurable height
- Smoothly accelerate
- Smoothly decelerate

---

## Camera

The drone shall

- Record video
- Start recording
- Stop recording

---

## Communication

Phone ↔ Drone

- Wi-Fi
- BLE (optional)

---

## Configuration

The user shall be able to configure

- Height
- Distance
- Speed
- Maximum velocity
- Camera settings
- PID tuning

---

# 8. Performance Requirements

| Parameter | Target |
|------------|--------|
| Flight Time | 20–30 min |
| Weight | < 800 g |
| Ideal Weight | 500–700 g |
| Speed | Walking/Jogging |
| Startup Time | <10 sec |
| Video | >240p |
| Hover Accuracy | ±20 cm (target) |
| Communication | Wi-Fi |

---

# 9. System Architecture

```
Phone
│
├── UI
├── High Level Control
├── Relative Position Controller
└── Video Preview
        │
        │ Wi-Fi
        ▼
ESP32
│
├── IMU
├── Sensor Fusion
├── PID
├── Flight Controller
├── Battery Monitoring
└── ESC Output
        │
        ▼
ESC
│
Brushless Motors
```

---

# 10. Hardware Requirements

## Flight Controller

Custom ESP32 Flight Controller

---

## Processor

ESP32-S3

---

## Sensors

- IMU
- Barometer

Future

- Optical Flow
- ToF

---

## Camera

1080p Camera

---

## ESC

4-in-1 Brushless ESC

---

## Motors

Brushless Outrunner Motors

---

## Battery

LiPo / Li-ion

---

# 11. Software Architecture

## ESP32

Responsibilities

- Flight stabilization
- Sensor fusion
- PID
- ESC control
- Communication

---

## Mobile App

Responsibilities

- Control
- UI
- Telemetry
- Parameter tuning
- Recording
- High-level movement

---

# 12. Engineering Goals

## Cost

Keep total BOM below ₹10k.

---

## Weight

Target

500–700 g

Maximum

800 g

---

## Endurance

20–30 minutes

---

## Manufacturability

- 3D printable
- Easy assembly
- Replaceable parts

---

# 13. Constraints

- Low budget
- Open source
- Minimal custom hardware initially
- Consumer components
- Easy to reproduce

---

# 14. Risks

## Flight Stability

Building a custom flight controller is significantly harder than using Pixhawk.

---

## Communication Latency

Phone control latency must remain low enough for smooth flight.

---

## Sensor Drift

IMU drift may reduce long-term positional accuracy.

---

## Battery Life

Small batteries reduce endurance.

---

# 15. Success Criteria

The project is considered successful when

- The drone can hover reliably.
- The drone can follow the user.
- The drone maintains configurable distance.
- The drone records stable video.
- Total BOM remains below ₹10,000.
- Flight time exceeds 20 minutes.

---

# 16. Future Roadmap

## V2

- Optical Flow
- ToF
- Better Camera
- Improved Stabilization

---

## V3

- Obstacle Avoidance
- AI Tracking
- Auto Orbit
- Gesture Control

---

## V4

- GPS
- LoRa
- Autonomous Deployment
- Waypoint Navigation
- Return to User

---

# 17. Bill of Materials (Draft)

| Component | Status |
|------------|--------|
| ESP32-S3 | TBD |
| IMU | TBD |
| ESC | TBD |
| Motors | TBD |
| Battery | TBD |
| Camera | TBD |
| Frame | TBD |
| Propellers | TBD |
| Connectors | TBD |

---

# 18. Project Milestones

## Milestone 1

- [ ] Finalize architecture

---

## Milestone 2

- [ ] Select all components

---

## Milestone 3

- [ ] Engineering calculations
- [ ] Weight budget
- [ ] Power budget
- [ ] Cost budget

---

## Milestone 4

- [ ] CAD Design
- [ ] Frame Design

---

## Milestone 5

- [ ] Hardware Assembly

---

## Milestone 6

- [ ] Flight Controller Firmware

---

## Milestone 7

- [ ] Mobile App

---

## Milestone 8

- Flight Testing

---

## Milestone 9

- Follow Mode

---

## Milestone 10

- Documentation

---

# 19. Design Principles

1. Keep hardware simple.
2. Minimize component count.
3. Prefer software optimization over hardware complexity.
4. Optimize for cost before performance.
5. Design for repairability.
6. Keep the platform modular.
7. Every added component must justify its cost, weight, and power consumption.

---

# 20. Open Questions

- Which communication protocol provides the best balance between latency and reliability (Wi-Fi vs BLE)?
- Can an ESP32-based flight controller provide sufficiently stable autonomous flight?
- What is the minimum sensor suite required for reliable following?
- Can the target BOM remain under ₹10,000 while meeting endurance and stability goals?
- Which propulsion system offers the best efficiency for a 500–700 g airframe?
- Should the drone rely solely on the phone for high-level guidance, or should additional onboard sensing be introduced in later versions?
