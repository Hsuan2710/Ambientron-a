# Ambientron

**Ambientron** is a macOS app designed for ambient music lovers. It lets you control the volume in a smooth and visual way, using a scrollable slider with clear dB (decibel) steps. The design is inspired by 90s Dieter Rams style — simple, colorful, and a bit retro.

This app helps you focus on how the sound feels, not just the volume.

---

## Features

- **Y2K-style user interface**  
  Retro fonts, colors, and shapes for a unique visual vibe.

- **audio update**  
  Changes happen instantly through the AVAudioEngine.

- **macOS features**  
  Maybe the haptic feedback and SwiftUI.

---

## Preview

> Screenshots will be added soon.

---

## Built With

- `SwiftUI` – for building the interface  
- `AVFoundation` – for sound control  
- `NSHapticFeedbackManager` – for Mac haptic response  
- `PreferenceKey` – to track and snap to dB positions

---

## How to Run (this version can only use XCode to build)

```bash
git clone https://github.com/yourname/ambient.git
cd ambient
open Ambient.xcodeproj
