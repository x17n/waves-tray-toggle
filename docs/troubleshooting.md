# Troubleshooting

## The tray icon doesn't appear
- Check the overflow chevron (`^`) next to the tray.
- Make sure you launched `WavesTray.vbs` (not the `.ps1` directly).
- If it appeared before and vanished after an Explorer restart, just relaunch the shortcut.

## A PowerShell/console window stays open
You launched `WavesTray.ps1` directly, or a shortcut points at `powershell.exe`.
Point the shortcut at `WavesTray.vbs` instead.

## "Enable Waves" runs but headphones still play through speakers
1. Plug the headphones in *after* enabling (or unplug and replug them) - jack
   detection events are only handled while the service is running.
2. Check Settings > Sound > Output for a "Headphones" entry:
   - **Entry exists** -> select it manually once; Windows remembers the choice.
   - **No entry** -> the driver stack needs a reboot after (re)installing, or your
     model genuinely requires the service running at boot. Re-check with the
     service running: `Get-Service WavesSysSvc` should show `Running`.

## Audio is completely dead (no output devices at all)
You (or a cleanup tool) removed the Waves-integrated Realtek driver package from the
DriverStore (e.g. `pnputil /delete-driver oemXXX.inf /uninstall`). On these machines
the generic Microsoft HD Audio driver exposes no endpoints. Reinstall the full Dell
Realtek Audio driver package from Dell's support site (or from the preloaded
`C:\Drivers\audio\...` folder if present), then reboot.

This is why WavesTray only toggles the *service* and never touches drivers.

## The service loads at boot anyway
Delete the `WavesSvc` autostart value (see README) and confirm the service itself
is set to Manual: `Set-Service WavesSysSvc -StartupType Manual`.

## Re-enable everything permanently (undo)
```powershell
# elevated PowerShell
Set-Service WavesSysSvc -StartupType Automatic
Start-Service WavesSysSvc
```
and remove the WavesTray shortcut from your Startup folder.
