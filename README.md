# WavesTray

A tiny Windows system tray app (pure PowerShell + VBScript, no install) that lets you
toggle the **Waves MaxxAudio service** (`WavesSysSvc`) on and off from the tray.

## Why

On many Dell laptops (XPS, Inspiron, Vostro...), the Waves MaxxAudio service:

- is required for 3.5 mm **headphone jack detection** - without it, plugging in
  headphones does nothing and audio keeps playing through the speakers;
- **reserves a large amount of RAM** (commonly 300-700 MB, sometimes over 1 GB)
  that never comes back down.

You normally get to choose between working headphones and your RAM. WavesTray gives
you both:

- **Gray headphones icon** = Waves OFF: no RAM used, speakers work normally.
- **Green headphones icon** = Waves ON: jack detection and the "what did you plug in?"
  popup work; click Enable, then plug in (or re-plug) your headphones.
- Toggle off again whenever you're done and the memory is freed instantly.

## Requirements

- Windows 10/11
- A Dell (or other) machine with the Waves MaxxAudio driver stack
  (service name `WavesSysSvc`, process `WavesSvc64.exe`)
- No installation, no dependencies - just PowerShell and .NET WinForms, both built in

## Install

1. Copy or clone this folder anywhere in your user profile, e.g.
   `C:\Tools\WavesTray` (do **not** use a network drive; scheduled/Startup apps need local paths).
2. Recommended: set the `WavesSysSvc` service to *Manual* so it never auto-starts at boot:
   ```powershell
   # elevated PowerShell
   Set-Service WavesSysSvc -StartupType Manual
   ```
3. Create a shortcut that launches `WavesTray.vbs` silently:
   - Right-click `WavesTray.vbs` > *Show more options* > *Send to* > *Desktop (create shortcut)*
   - (Optional) give the shortcut the `waves_tray.ico` icon
4. Auto-start at login: put the same shortcut in your Startup folder
   (`Win+R` > `shell:startup` > paste the shortcut).

Double-click the shortcut. A headphones icon appears in the tray (check the
chevron `^` if you don't see it right away).

## Usage

Right-click the tray icon:

- **Enable Waves (headphone jack)** - starts the service (one UAC prompt),
  then plug in / re-plug your headphones within a few seconds.
- **Disable Waves (free memory)** - stops the service and kills its process.
  Speakers keep working; the reserved RAM is freed immediately.
- **Exit** - closes the tray app (leaves the service as-is).

Hover the icon to see the current state, including live RAM usage of the service
while it is on. The icon color mirrors the state.

## Known behavior / limitations

- Each toggle triggers one UAC prompt, because service control needs admin rights.
- While enabled, the Waves process reserves its (large) memory - that is the driver's
  own allocation and cannot be reduced. Toggle off when you don't need the jack.
- On some models the service is also spawned by a `WavesSvc` entry in
  `HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Run`. If Waves loads at boot anyway,
  delete that entry (elevated PowerShell):
  ```powershell
  Remove-ItemProperty 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'WavesSvc'
  ```
- Do **not** delete the Waves driver package itself - on these machines the audio
  stack depends on it and audio can stop working entirely. This tool only toggles
  the service.
- Why a `.vbs` launcher? Windows 11 hosts PowerShell console sessions in Windows
  Terminal, which opens a visible window even with `-WindowStyle Hidden`. The
  VBScript wrapper starts PowerShell with a hidden window, so only the tray icon appears.

## Files

| File | Purpose |
|---|---|
| `WavesTray.ps1` | The tray application |
| `WavesTray.vbs` | Silent launcher (no console window) |
| `waves_tray.ico` / `waves_tray_on.ico` | Tray/shortcut icons (gray = off, green = on) |
| `docs/troubleshooting.md` | Common issues |

## License

MIT - see [LICENSE](LICENSE).
