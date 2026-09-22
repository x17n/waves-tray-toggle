' WavesTray silent launcher.
' Windows 11 hosts PowerShell console sessions in Windows Terminal, which opens a
' visible window even with -WindowStyle Hidden. Launching through wscript keeps it fully silent.
CreateObject("Wscript.Shell").Run "powershell.exe -NoProfile -WindowStyle Hidden -ExecutionPolicy Bypass -File """ & WScript.ScriptFullName.Replace("WavesTray.vbs", "WavesTray.ps1") & """", 0, False
