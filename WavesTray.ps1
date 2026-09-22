# WavesTray - system tray toggle for the Waves MaxxAudio service on Dell laptops
# Lets you turn WavesSysSvc (jack detection / MaxxAudio DSP) on and off to reclaim
# the RAM the service reserves, while keeping headphone switching available on demand.
#
# Icons: waves_tray.ico (gray = OFF) and waves_tray_on.ico (green = ON) in the same folder.

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$script:dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$iconOnPath  = Join-Path $script:dir 'waves_tray_on.ico'
$iconOffPath = Join-Path $script:dir 'waves_tray.ico'

if (-not (Test-Path $iconOnPath) -or -not (Test-Path $iconOffPath)) {
    [System.Windows.Forms.MessageBox]::Show("Icon files not found next to the script.`nExpected: waves_tray.ico and waves_tray_on.ico in $script:dir", 'WavesTray') | Out-Null
    exit 1
}

$iconOn  = [System.Drawing.Icon]::new($iconOnPath)
$iconOff = [System.Drawing.Icon]::new($iconOffPath)

$icon = New-Object System.Windows.Forms.NotifyIcon
$icon.Text = 'Waves Audio Toggle'
$icon.Icon = $iconOff
$icon.Visible = $true

function Update-Icon {
    $p = Get-Process WavesSvc64 -ErrorAction SilentlyContinue
    $svc = Get-Service WavesSysSvc -ErrorAction SilentlyContinue
    if (-not $svc) {
        $icon.Icon = $iconOff
        $icon.Text = 'Waves service not found on this machine'
        return
    }
    $mb = if ($p) { [math]::Round($p.WorkingSet64/1MB) } else { 0 }
    if ($p -or $svc.Status -eq 'Running') {
        $icon.Icon = $iconOn
        $icon.Text = "Waves Audio: ON ($mb MB) - right-click to toggle"
    } else {
        $icon.Icon = $iconOff
        $icon.Text = 'Waves Audio: OFF - right-click to toggle'
    }
}
Update-Icon

$menu = New-Object System.Windows.Forms.ContextMenuStrip

$enable = $menu.Items.Add('Enable Waves (headphone jack)')
$enable.add_Click({
    # Self-elevate: the service needs admin rights. One UAC prompt per toggle.
    Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList '-NoProfile','-Command','Start-Service WavesSysSvc'
    Start-Sleep 6
    Update-Icon
    $icon.ShowBalloonTip(3000, 'Waves enabled', 'Jack detection active - plug in / replug your headphones now.', [System.Windows.Forms.ToolTipIcon]::Info)
})

$disable = $menu.Items.Add('Disable Waves (free memory)')
$disable.add_Click({
    Start-Process powershell -Verb RunAs -WindowStyle Hidden -ArgumentList '-NoProfile','-Command','Stop-Service WavesSysSvc -Force; Stop-Process -Name WavesSvc64 -Force -ErrorAction SilentlyContinue'
    Start-Sleep 3
    Update-Icon
    $icon.ShowBalloonTip(3000, 'Waves disabled', 'Memory freed. Speakers stay active.', [System.Windows.Forms.ToolTipIcon]::Info)
})

[void]$menu.Items.Add('-')
$exit = $menu.Items.Add('Exit')
$exit.add_Click({
    $icon.Visible = $false
    [System.Windows.Forms.Application]::Exit()
})
$icon.ContextMenuStrip = $menu

$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 10000
$timer.add_Tick({ Update-Icon })
$timer.Start()

[System.Windows.Forms.Application]::Run()
$icon.Visible = $false
