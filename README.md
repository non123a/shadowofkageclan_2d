# shadowofkageclan_2d
shadow of kage clan is a 2D game about adventure enemy base recuse comrade, this game involving emotion about duty vs loyalty.

<p align="center">
  <img src="/Screenshot 2026-01-27 at 6.18.28 in the evening.png" width="600">
</p>
<p align="center">
  <img src="/Screenshot 2026-01-27 at 6.18.57 in the evening.png" width="600">
</p>


## 🎮 Gameplay Video
https://www.youtube.com/watch?v=ZijD6uu0IMw

Got it — you want a **clear, professional list of everything you did to optimize the game** for your README (or to explain to your instructor). I’ll organize it cleanly and logically so it looks like a real dev workflow.

You can copy this directly.

---

# Game Optimization Process

## 1. Asset Cleanup

* Removed unused assets such as:

  * prototype scenes
  * unused audio files
  * unused textures and test images
* Deleted redundant or duplicate files to reduce project size

---

## 2. Audio Optimization

* Converted large audio files (e.g. `.wav`) into compressed formats (`.mp3` / `.ogg`)
* Reduced audio bitrate to optimize size:

  * Background music: ~96 kbps
  * Sound effects: ~64 kbps
* Removed unnecessary or duplicate sound files

**Result:** Significant reduction in overall project size

---

## 3. Texture Optimization

* Reduced large image resolutions to appropriate sizes
* Removed unused UI images and screenshots
* Used Godot import settings:

  * Compression enabled
  * Optimized for game usage

---

## 4. Custom Engine Build

* Compiled a custom Godot Windows export template using SCons
* Removed unnecessary engine features:

  * 3D rendering system (`disable_3d`)
  * Direct3D 12 renderer (`d3d12=no`)
  * accessibility features (`accesskit=no`)
  * unused modules (XR, navigation, glTF, etc.)
* Replaced default export template with optimized version

**Result:** Reduced engine runtime size significantly

---
