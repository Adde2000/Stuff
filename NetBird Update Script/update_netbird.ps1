# Auto-elevate script
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {

    Write-Host "Restarting script as administrator..."
    Start-Sleep -Seconds 1  # Give user time to read

    # Determine PowerShell executable
    $pwsh = Get-Command pwsh -ErrorAction SilentlyContinue
    $ps5  = Get-Command powershell -ErrorAction SilentlyContinue

    if ($pwsh) {
        Write-Host "Running in PowerShell 7"
        Start-Sleep -Seconds 2
        $exe = $pwsh.Source
    } elseif ($ps5) {
        Write-Host "Running in PowerShell 5"
        Start-Sleep -Seconds 2
        $exe = $ps5.Source
    } else {
        Write-Error "No PowerShell executable found."
        Read-Host "Press Enter to exit..."
        exit
    }

    # Properly quote the script path
    $scriptPathQuoted = "`"$PSCommandPath`""

    # Launch elevated
    Start-Process -FilePath $exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File $scriptPathQuoted" -Verb RunAs

    # Exit the unelevated instance
    exit
}

# Set variables
$downloadUrl = "https://pkgs.netbird.io/windows/x64"  # NetBird latest version download URL
$installerPath = "$env:TEMP\NetBird.exe"
$installedPath = "C:\Program Files\Netbird\NetBird-UI.exe"
$shortcutPath = "$env:PUBLIC\Desktop\Netbird.lnk"

# Download the file
Write-Host "Downloading installer from $downloadUrl..."
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri $downloadUrl -OutFile $installerPath

# Run the installer silently
Write-Host "Running installer..."
Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait

# Start NetBird UI
Write-Host "Restarting NetBird UI..."
Start-Process -FilePath $installedPath

# Wait until the process appears
$processName = [System.IO.Path]::GetFileNameWithoutExtension($installedPath)

while (-not (Get-Process -Name $processName -ErrorAction SilentlyContinue)) {
    Start-Sleep -Milliseconds 200
}

Write-Host "$processName has started. "

# Clean up
Write-Host "Removing installer..."
Remove-Item $installerPath -Force

# Check NetBird version
Write-Host "NetBird updated to version: " -ForegroundColor Cyan -NoNewline
Write-Host $(netbird version) -ForegroundColor Blue


if (Test-Path $shortcutPath) {
    # Ask for confirmation
    $answer = Read-Host "Do you want to remove the desktop shortcut '$shortcutPath'? (Y/N)"
    
    if ($answer -match "^[Yy]") {
        Remove-Item $shortcutPath -Force
        Write-Host "Shortcut removed."
    } else {
        Write-Host "Shortcut kept."
    }
} else {
    Write-Warning "Shortcut not found."
}

Read-Host "Update complete! Press 'Enter' to close"