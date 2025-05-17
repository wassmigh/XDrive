# 🚗 XDrive – Intelligent Vehicle Control System

XDrive is a smart car prototype control system that enables real-time interaction between a mobile app and a connected vehicle. Built with Flutter, MicroPython, and Firebase, it offers a user-friendly and secure solution to control and monitor various vehicle features remotely.

## 📱 Features

- 🔐 **Authentication**: Secure login with Email & Password.
- 🚗 **Remote Engine Control**: Start/Stop the car engine remotely.
- 🔒 **Lock/Unlock Doors**: Control door and trunk access in real-time.
- ❄️ **Climate Control**: Adjust air conditioning and heating remotely.
- 💡 **Lighting System**:
  - Headlight management
  - Ambient dashboard lighting customization (NeoPixel)
- 🌡️ **Interior Temperature Monitoring**: Real-time updates from DHT22 sensor.
- 📍 **GPS Tracking**: Locate your vehicle easily in real time (planned feature).

## 📡 System Architecture

The system relies on **Firebase Realtime Database** for two-way communication between the Flutter mobile app and the onboard ESP32 microcontroller. The ESP32 runs MicroPython code to interact with sensors and actuators including:

- DHT22 (temperature/humidity)
- DC motors (for movement)
- Servos (for doors/trunk)
- LEDs & NeoPixel (for lighting)

## 🧰 Technologies Used

- **Mobile Frontend**: Flutter (Dart)
- **Microcontroller**: ESP32 (MicroPython)
- **Backend/Realtime Sync**: Firebase Realtime Database
- **Sensors**: DHT22
- **Actuators**: DC Motors, Servomotors, LEDs, NeoPixel

## 🔍 Problem & Solution

**Problems**:
- Forgetting to lock doors
- Losing car keys
- Wasting time on manual car controls

**Solutions**:
- Remote access via smartphone
- Real-time feedback and control
- Automated climate and access management


## 📂 Project Structure (coming soon)

We plan to provide:
- Flutter source code
- MicroPython code
- Wiring diagrams and schematics

## 🧪 Simulation

The hardware logic of the ESP32 system was developed and tested using Wokwi, a powerful online simulator for embedded systems.

- ✅ Rapid prototyping without physical hardware
- 🔁 Real-time interaction with Firebase
- 🔌 Simulated components: DHT22, servos, LEDs, motors

You can view or clone the Wokwi simulation from this link: https://wokwi.com/projects/430772061490504705


