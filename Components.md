# V1 Component Selection Plan

> **Document Version:** 1.0
> **Project:** Pocket Follow Drone (V1)
> **Status:** Draft — Component Evaluation

---

# Objective

Select the lowest-cost, lightweight, and reliable hardware required for V1.

V1 uses:

* Phone for high-level computation
* ESP32 for low-level flight control
* IMU for attitude sensing
* MicoAir MTF-01P for optical flow + ToF
* Wi-Fi for communication
* Brushless propulsion

V1 does not use:

* Drone GNSS
* Pixhawk
* Companion computer
* LiDAR
* LoRa
* Long-range communication

---

# System

```text
                    Phone
             High-Level Control
                     │
                    Wi-Fi
                     │
                     ▼
              ┌─────────────┐
              │   ESP32-S3  │
              │             │
              │ Sensor      │
              │ Aggregation │
              │             │
              │ State       │
              │ Estimation  │
              │             │
              │ PID /       │
              │ Stabilisation│
              └──────┬──────┘
                     │
                 DShot / PWM
                     │
                     ▼
                 4-in-1 ESC
                     │
                     ▼
               Brushless Motors
```

---

# 1. Flight Controller

## ESP32-S3

**Status:** Current choice

### Responsibilities

* Sensor aggregation
* State estimation
* Stabilisation
* PID control
* Altitude control
* Movement execution
* Wi-Fi communication
* ESC control
* Battery monitoring
* Safety

### Advantages

* Low cost
* Wi-Fi
* Bluetooth available
* Dual-core
* Large ecosystem
* Sufficient for V1 processing

### Disadvantages

* Custom flight-control firmware required
* Less flight-control ecosystem than dedicated STM32 flight controllers

### Approximate Price

```text
₹500–700
```

---

# 2. IMU

The IMU provides the primary inertial information required for stabilization and state estimation.

## Option 1 — MPU6050

**Status:** Budget candidate

### Advantages

* Extremely inexpensive
* Large community
* Easy to find
* Simple integration

### Disadvantages

* Older sensor
* Higher noise
* Lower performance

### Approximate Price

```text
₹200–300
```

---

## Option 2 — BMI270

**Status:** Candidate

### Advantages

* Lower noise
* Good filtering
* Low power
* Modern sensor

### Disadvantages

* Smaller ecosystem
* Slightly higher cost

### Approximate Price

```text
₹450–600
```

---

## Option 3 — ICM-42688-P

**Status:** Preferred candidate

### Advantages

* Very low noise
* High sampling rate
* Good stability
* Well suited to flight-control applications

### Disadvantages

* Higher cost

### Approximate Price

```text
₹600–800
```

---

# 3. Optical Flow + ToF

## MicoAir MTF-01P

**Status:** Selected V1 sensor

The MTF-01P combines:

* Optical flow
* ToF distance measurement

This replaces the need to separately select an optical-flow sensor and a ToF sensor for V1.

### Purpose

Optical flow:

* Horizontal motion estimation
* Local odometry

ToF:

* Ground distance
* Altitude estimation
* Hover control
* Landing

### Advantages

* Combined module
* Less wiring
* Less integration work
* Lightweight
* Designed for flight applications
* Directly matches the V1 architecture

### Disadvantages

* More expensive than individual basic sensors
* Performance depends on surface, lighting, and altitude

### Approximate Price

```text
TBD
```

---

# 4. Barometer

## BMP388

**Status:** Optional

A barometer may provide additional altitude information, particularly outside the useful ToF range.

It is **not part of the minimum V1 sensor stack**.

### Purpose

* Pressure-based altitude estimation
* Additional altitude reference
* Sensor redundancy

### Approximate Price

```text
₹300–450
```

### Decision

Start without it.

Add it only if simulation or flight testing shows that ToF alone is insufficient.

---

# 5. ESC

The ESC converts flight-controller commands into motor power.

## Requirements

* 4-in-1
* Brushless
* 20–30 A target
* DShot support preferred
* Suitable for selected motors and battery

---

## Option 1 — HAKRC 20A

**Status:** Budget candidate

### Advantages

* Low cost
* Lightweight

### Disadvantages

* Quality variation
* Less confidence for long-term reliability

### Approximate Price

```text
₹1500–1800
```

---

## Option 2 — SpeedyBee 20A

**Status:** Preferred candidate

### Advantages

* Better build quality
* Better documentation
* Established ecosystem

### Disadvantages

* Higher cost

### Approximate Price

```text
₹1800–2200
```

---

# 6. Motors

Motor selection depends on:

* Final weight
* Propeller size
* Battery voltage
* Required thrust
* Desired efficiency

The target is a lightweight propulsion system suitable for a roughly 500–700 g drone.

---

## Option 1 — 1404

**Status:** Candidate

### Advantages

* Lightweight
* Low power
* Suitable for small frames

### Disadvantages

* Lower thrust margin

### Approximate Price

```text
₹2400–2800 / 4
```

---

## Option 2 — 1505

**Status:** Current direction

### Advantages

* Good thrust/weight balance
* Suitable for lightweight drone
* Better thrust margin than 1404

### Disadvantages

* Slightly heavier

### Approximate Price

```text
₹3000–3500 / 4
```

---

## Option 3 — 1804

**Status:** Candidate

### Advantages

* High thrust
* Greater payload margin

### Disadvantages

* Heavier
* Higher power consumption

### Approximate Price

```text
₹3600–4200 / 4
```

---

# 7. Propellers

**Status:** TBD after motor selection

Target:

```text
3–4 inch
```

Candidate manufacturers:

* Gemfan
* HQProp

Selection depends on:

* Motor KV
* Battery voltage
* Motor thrust curve
* Current
* Efficiency
* Required thrust

### Approximate Price

```text
₹300–600
```

---

# 8. Battery

Battery selection must follow propulsion calculations.

---

## Option 1 — 2S 1500 mAh LiPo

**Status:** Candidate

### Advantages

* Lightweight
* Low cost

### Disadvantages

* Lower power
* Lower energy capacity

### Approximate Price

```text
₹1200
```

---

## Option 2 — 2S 2200 mAh LiPo

**Status:** Candidate

### Advantages

* Higher capacity
* Longer potential flight time

### Disadvantages

* Heavier

### Approximate Price

```text
₹1600
```

---

## Option 3 — 3S 1500 mAh LiPo

**Status:** Candidate

### Advantages

* Higher voltage
* Higher available power
* Potentially better propulsion performance

### Disadvantages

* Higher current and motor requirements
* Requires matching motor/propeller selection

### Approximate Price

```text
₹1800
```

---

# 9. Camera

The camera is independent of the flight-control sensor system.

## Option 1 — ESP32-CAM

**Status:** Budget candidate

### Advantages

* Very cheap
* Easy integration
* Wi-Fi

### Disadvantages

* Limited image quality
* Limited video capability

### Approximate Price

```text
₹500
```

---

## Option 2 — OV2640 Module

**Status:** Candidate

### Advantages

* Low cost
* Better integration flexibility

### Disadvantages

* Still limited compared with dedicated cameras

### Approximate Price

```text
₹800–1200
```

---

# 10. Frame

**Status:** Custom design

The frame will be designed after propulsion and component selection.

### Requirements

* Lightweight
* Small
* Rigid
* Easy to assemble
* Easy to repair
* Correct motor geometry
* Good component placement
* Stable center of gravity
* Adequate airflow

### Materials

Prototype:

```text
PLA
```

Production candidate:

```text
PETG
```

Future:

```text
Carbon-fiber reinforced material
```

### Estimated Cost

```text
₹500–800
```

---

# 11. Wiring and Power

Required:

* XT30 connector
* Silicone wire
* JST connectors
* Heat shrink
* Power switch
* Power distribution

### Estimated Cost

```text
₹300–500
```

---

# 12. Fasteners

Required:

* M2 screws
* M3 screws
* Nylon standoffs
* Brass inserts where required

### Estimated Cost

```text
₹300
```

---

# 13. Component Status

| Component       | V1 Status      |
| --------------- | -------------- |
| ESP32-S3        | Current choice |
| IMU             | Candidate      |
| MicoAir MTF-01P | Selected       |
| Barometer       | Optional       |
| ESC             | Candidate      |
| Motors          | Candidate      |
| Propellers      | TBD            |
| Battery         | TBD            |
| Camera          | Candidate      |
| Frame           | Custom         |
| Wiring          | Required       |
| Fasteners       | Required       |

---

# 14. Current Budget

The original component candidates give approximately:

| Component  | Estimated Cost |
| ---------- | -------------: |
| ESP32-S3   |           ₹600 |
| IMU        |           ₹700 |
| MTF-01P    |            TBD |
| ESC        |          ₹2000 |
| Motors     |          ₹3200 |
| Propellers |           ₹500 |
| Battery    |          ₹1600 |
| Camera     |           ₹800 |
| Wiring     |           ₹500 |
| Frame      |           ₹600 |
| Fasteners  |           ₹300 |

```text
Current known total: ~₹10,800
```

MTF-01P cost is not included because it is still TBD.

Therefore the **₹10,000 BOM target is not currently achieved**.

---

# 15. Cost Priority

If the BOM exceeds ₹10,000, reduce cost in this order:

1. Remove optional barometer.
2. Reduce camera cost.
3. Optimize frame cost.
4. Compare budget ESCs.
5. Compare IMU options.
6. Optimize motor/propeller/battery combination.

Do not reduce the core flight-control architecture merely to meet the budget.

The core V1 sensor stack is:

```text
IMU
+
MTF-01P
+
ESP32-S3
```

---

# 16. Selection Method

Final component selection will be based on:

* Cost
* Weight
* Power consumption
* Reliability
* Availability
* Software support
* Integration difficulty
* Performance
* Compatibility with other components

No component is considered final solely because it is inexpensive.

---

# 17. Next Step

Before designing the frame, finalize the propulsion system:

```text
Motor
   ↓
KV
   ↓
Propeller
   ↓
Battery
   ↓
ESC
   ↓
Thrust
   ↓
Power
   ↓
Flight time
```

Once propulsion is finalized:

* Calculate total weight
* Calculate thrust-to-weight ratio
* Calculate power requirement
* Calculate expected flight time
* Select frame dimensions
* Place components
* Determine center of gravity
* Begin CAD design

