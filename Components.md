# V1 Component Selection Plan

> **Document Version:** 1.0  
> **Project:** Pocket Follow Drone (V1)  
> **Status:** Draft - Component Evaluation

---

# Objective

This document contains the candidate hardware components for Version 1 of the Pocket Follow Drone.

The primary objective of V1 is to build the **lowest-cost**, **lightweight**, and **reliable** autonomous follow drone while minimizing hardware complexity.

Unlike later versions, V1 intentionally avoids expensive navigation hardware such as GPS, Pixhawk, companion computers, LiDAR, and LoRa.

---

# System Architecture

```
                Phone
        (Control Application)
               │
           Wi-Fi / BLE
               │
        ┌─────────────┐
        │  ESP32-S3   │
        ├─────────────┤
        │ Sensor Fusion
        │ Flight Control
        │ PID Controller
        └──────┬──────┘
               │
          PWM / DShot
               │
          4-in-1 ESC
               │
        Brushless Motors
```

---

# Component Categories

## Sensors

The drone requires sensors for stabilization and local position estimation.

---

# 1. IMU (Inertial Measurement Unit)

## Purpose

- Roll estimation
- Pitch estimation
- Angular velocity
- Linear acceleration
- Flight stabilization

---

### Option 1 — MPU6050

**Advantages**

- Extremely inexpensive
- Huge community support
- Easy to integrate

**Disadvantages**

- Older sensor
- More noise
- Lower accuracy

Approx Price

```
₹200–300
```

---

### Option 2 — BMI270

**Advantages**

- Better filtering
- Lower noise
- Low power consumption

**Disadvantages**

- Smaller community
- Slightly higher price

Approx Price

```
₹450–600
```

---

### Option 3 — ICM-42688-P (Recommended)

**Advantages**

- Very low noise
- High sampling rate
- Excellent stability
- Used in modern drones

**Disadvantages**

- Highest cost of the three

Approx Price

```
₹600–800
```

---

# 2. Optical Flow Sensor

## Purpose

Measures movement relative to the ground.

Allows the drone to estimate horizontal motion without GPS.

---

### Option 1 — PMW3901 (Recommended)

**Advantages**

- Proven in many drones
- Excellent documentation
- Lightweight
- Low power

**Disadvantages**

- Requires textured surfaces

Approx Price

```
₹1200–1800
```

---

### Option 2 — PAA5100JE

**Advantages**

- Newer sensor
- Better low-light performance

**Disadvantages**

- Smaller software ecosystem

Approx Price

```
₹1000–1500
```

---

# 3. Time-of-Flight (ToF)

## Purpose

Measures distance from the ground.

Used for

- Hovering
- Landing
- Altitude stabilization

---

### Option 1 — VL53L1X (Recommended)

Range

```
4 m
```

Advantages

- Accurate
- Inexpensive
- Small

Approx Price

```
₹600–800
```

---

### Option 2 — VL53L5CX

Advantages

- 8×8 depth map
- Future obstacle avoidance

Disadvantages

- More expensive
- Unnecessary for V1

Approx Price

```
₹1700–2200
```

---

# 4. Barometer (Optional but Recommended)

## Purpose

Altitude estimation above ToF range.

Candidate

BMP388

Approx Price

```
₹300–450
```

---

# Flight Controller

---

## ESP32-S3 (Current Choice)

Responsibilities

- Flight Control
- Sensor Fusion
- PID Controller
- Communication
- Battery Monitoring
- ESC Control

Advantages

- Extremely inexpensive
- Wi-Fi
- Bluetooth
- Dual Core
- Large community

Disadvantages

- Less processing power than STM32
- Custom firmware required

Approx Price

```
₹500–700
```

---

# ESC

The Electronic Speed Controller converts flight controller commands into motor power.

---

## Requirements

- 4-in-1
- Brushless
- DShot Support
- 20A–30A

---

### Option 1 — HAKRC 20A

Advantages

- Very inexpensive
- Lightweight

Disadvantages

- Quality varies

Approx Price

```
₹1500–1800
```

---

### Option 2 — SpeedyBee 20A (Recommended)

Advantages

- Reliable
- Better documentation
- Better build quality

Disadvantages

- Slightly more expensive

Approx Price

```
₹1800–2200
```

---

# Motors

The propulsion system will be selected based on final weight and desired flight time.

---

### Option 1 — 1404

Suitable for

- Small drones
- Lightweight

Advantages

- Very light
- Low power

Disadvantages

- Lower thrust

Approx Price (Set of 4)

```
₹2400–2800
```

---

### Option 2 — 1505 (Current Direction)

Advantages

- Good balance
- Efficient
- Higher thrust

Disadvantages

- Slightly heavier

Approx Price

```
₹3000–3500
```

---

### Option 3 — 1804

Advantages

- High thrust
- Future payload support

Disadvantages

- Heavier
- Higher power consumption

Approx Price

```
₹3600–4200
```

---

# Propellers

Current Direction

```
3–4 inch
```

Options

- Gemfan
- HQProp

Approx Price

```
₹300–600
```

---

# Battery

Battery selection depends on propulsion calculations.

---

### Option 1

2S 1500 mAh LiPo

Advantages

- Lightweight
- Cheap

Disadvantages

- Lower power

Approx Price

```
₹1200
```

---

### Option 2

2S 2200 mAh LiPo

Advantages

- Longer flight

Disadvantages

- Heavier

Approx Price

```
₹1600
```

---

### Option 3

3S 1500 mAh LiPo

Advantages

- More power

Disadvantages

- Higher current requirements

Approx Price

```
₹1800
```

---

# Camera

---

### Option 1

ESP32-CAM

Advantages

- Extremely cheap
- Easy integration

Disadvantages

- Limited quality

Approx Price

```
₹500
```

---

### Option 2

OV2640 Camera Module

Advantages

- Better image quality

Approx Price

```
₹800–1200
```

---

# Wiring

Requirements

- XT30 Connector
- Silicone Wire
- JST Connectors
- Heat Shrink
- Power Switch

Approx Cost

```
₹300–500
```

---

# Fasteners

- M2 Screws
- M3 Screws
- Brass Inserts
- Nylon Standoffs

Approx Cost

```
₹300
```

---

# Chassis

The frame will be custom designed after component selection.

Material Candidates

- PLA (Prototype)
- PETG
- Carbon Reinforced PETG (Future)

Estimated Cost

```
₹500–800
```

---

# Estimated Budget

| Component | Estimated Cost |
|------------|---------------:|
| ESP32-S3 | ₹600 |
| IMU | ₹700 |
| Optical Flow | ₹1500 |
| ToF | ₹700 |
| Barometer | ₹350 |
| ESC | ₹2000 |
| Motors | ₹3200 |
| Propellers | ₹500 |
| Battery | ₹1600 |
| Camera | ₹800 |
| Wiring | ₹500 |
| Frame | ₹600 |

## Estimated BOM

```
₹13,000 ± ₹1,500
```

---

# Cost Optimization Opportunities

If the ₹10,000 target becomes mandatory, possible reductions include:

- Use MPU6050 instead of ICM-42688-P
- Use HAKRC ESC instead of SpeedyBee
- Use ESP32-CAM instead of a separate camera
- Start without a barometer (if ToF covers the intended altitude range)
- Reuse an existing LiPo charger
- Purchase motors and ESCs from budget suppliers

These changes can reduce the BOM by approximately ₹2,000–₹3,000, but may affect performance or development effort.

---

# Next Step

Once the following components are finalized:

- Motors
- Propellers
- ESC
- Battery

the mechanical design phase can begin.

The chassis will then be designed around:

- Component dimensions
- Weight distribution
- Center of Gravity (CoG)
- Airflow
- Cooling
- Ease of assembly
- Future modularity
