# Fn Toggle

![Platform](https://img.shields.io/badge/platform-macOS-lightgrey)
![License](https://img.shields.io/badge/license-MIT-blue)
![Swift](https://img.shields.io/badge/Swift-5.0+-orange)

**Fn Key Toggle** is a lightweight macOS menu bar application that allows you to effortlessly toggle the functionality of your Fn keys. Press the Fn key to instantly switch between standard function keys and multimedia controls.

---

## ✨ Features

| Feature | Description |
| :--- | :--- |
| **Menu Bar App** | Always accessible from the top bar for quick status checks. |
| **Auto Toggle** | Automatically changes settings when the **Fn key** is pressed. |
| **Visual Feedback** | Menu bar icon changes to reflect the current state. |
| **Audio Feedback** | Subtle system sound confirms mode changes. |
| **Manual Control** | Toggle settings directly from the menu bar dropdown. |
| **Spam Protection** | Built-in debounce prevents accidental rapid toggling. |
| **Clear System Action** | Option to remove system assignments (e.g. Emoji) from Fn key. |
| **Language Selection** | Switch between Turkish 🇹🇷 and English 🇬🇧 interface. |

## 🚀 Installation & Usage

### 1. Build
Compile the application using the provided script:
```bash
./build_menubar.sh
```

### 2. Run
Launch the application:
```bash
open Build/FnToggle.app
```

### 3. Permissions
The app will automatically check for **Input Monitoring** permission on launch:
1. If the permission is missing, a popup will appear.
2. Click **"Sistem Ayarlarını Aç"** to open System Settings directly to the Input Monitoring page.
3. Enable the toggle for **FnToggle** or **Terminal** (depending on how you ran it).
4. Restart the app.

> **Note:** The app cannot function without Input Monitoring permission and will exit if not granted.

> **Tip:** If the app fails to open, you may need to remove quarantine attributes:
> ```bash
> xattr -cr Build/FnToggle.app
> ```

## 📖 Usage Guide

### Indicators
The menu bar icon shows the current mode of your Fn keys:

| Icon | Mode | Description |
| :---: | :--- | :--- |
| **Fn** | **Function Mode** | Keys F1, F2, etc. act as standard function keys. |
| **Multimedia** | **Media Mode** | Keys act as brightness, volume, and media controls. |

### Controls
- **Physical Key**: Press the `Fn` key on your keyboard.
- **Menu Item**: Click the menu bar icon and select **Toggle Fn State**.
- **Clear Action**: Select **Clear System Fn Action** to prevent conflicts with Emoji/Dictation.
- **Language**: Choose **Language** > **English** or **Türkçe** to switch interface language.

## 🛠 System Requirements

- **OS**: macOS 10.15 (Catalina) or later.
- **Architecture**: Apple Silicon (M1/M2/M3) or Intel.
- **Hardware**: Mac with a built-in keyboard or Magic Keyboard.

## 📂 File Structure

```text
.
├── Sources/
│   ├── main.swift          # Entry point
│   ├── Localizable.swift   # Turkish/English Localization
│   ├── MenuBarApp.swift    # UI & App Logic
│   ├── FnStateManager.swift # System Settings Logic
│   ├── FnKeyListener.swift # Input Event Handling
│   └── Resources/          # Assets (Icons)
└── build_menubar.sh        # Build Script
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---
<div align="center">
  <sub>Built with AI support</sub>
</div>
