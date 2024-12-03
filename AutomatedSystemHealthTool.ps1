# Setup: Ensure logs folder exists
$LogFolder = "$PSScriptRoot\Logs"
if (!(Test-Path -Path $LogFolder)) {
    New-Item -ItemType Directory -Path $LogFolder | Out-Null
}
$LogFile = "$LogFolder\HealthCheckLog_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"

# Function to log messages
Function Log {
    param (
        [string]$Message
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Output "$Timestamp : $Message" | Tee-Object -FilePath $LogFile -Append
}

# System Health Monitoring
Function Check-SystemHealth {
    Log "Starting System Health Check..."
    Write-Host "=== System Health Summary ==="

    # CPU and Memory Usage
    $CPU = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples[0].CookedValue
    $RAM = Get-WmiObject -Class Win32_OperatingSystem
    $RAMFree = [math]::Round(($RAM.FreePhysicalMemory / 1MB), 2)
    $RAMTotal = [math]::Round(($RAM.TotalVisibleMemorySize / 1MB), 2)
    $RAMUsage = [math]::Round((($RAMTotal - $RAMFree) / $RAMTotal) * 100, 2)

    Write-Host "CPU Usage: $CPU%" -ForegroundColor Green
    Write-Host "Memory Usage: $RAMUsage% ($RAMFree MB free of $RAMTotal MB)" -ForegroundColor Green

    # Disk Space
    Get-PSDrive -PSProvider FileSystem | ForEach-Object {
        $FreeSpace = [math]::Round($_.Free / 1GB, 2)
        $TotalSpace = [math]::Round($_.Used + $_.Free / 1GB, 2)
        Write-Host "Drive $_.Name - Free: $FreeSpace GB of $TotalSpace GB"
    }
    Log "System Health Check Complete."
}

# Security Scans
Function Run-SecurityScans {
    Log "Starting Security Scans..."
    Write-Host "=== Running Windows Defender Quick Scan ===" -ForegroundColor Yellow
    Start-MpScan -ScanType QuickScan
    Log "Windows Defender Quick Scan Completed."

    # Auditing Unused Services
    Write-Host "Checking unused services..."
    Get-Service | Where-Object { $_.StartType -eq "Manual" -and $_.Status -eq "Running" } | Format-Table -AutoSize
    Log "Security Scans Completed."
}

# Optimization Tasks
Function Optimize-System {
    Log "Starting System Optimization..."
    Write-Host "Cleaning Temporary Files..." -ForegroundColor Yellow
    Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "Temporary Files Cleaned."

    Write-Host "Disabling Unnecessary Startup Programs..."
    Get-CimInstance -Namespace "root\cimv2" -Class Win32_StartupCommand | Where-Object { $_.Command -notlike "*Windows*" } | ForEach-Object {
        $Key = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run"
        Remove-ItemProperty -Path $Key -Name $_.Name -ErrorAction SilentlyContinue
    }
    Log "Optimization Completed."
}

# Automated Troubleshooting
Function Troubleshoot-Issues {
    Log "Starting Troubleshooting..."
    Write-Host "Running System File Checker..." -ForegroundColor Yellow
    sfc /scannow | Out-Null
    Write-Host "Running DISM RestoreHealth..." -ForegroundColor Yellow
    DISM /Online /Cleanup-Image /RestoreHealth | Out-Null

    Write-Host "Flushing DNS Cache..."
    ipconfig /flushdns | Out-Null
    Log "Troubleshooting Completed."
}

# Check for Windows Updates
Function Check-WindowsUpdates {
    Log "Checking for Windows Updates..."
    Write-Host "Checking for Windows Updates..." -ForegroundColor Yellow
    Get-WindowsUpdate -Install -AcceptAll -AutoReboot | Out-Null
    Log "Windows Updates Check Completed."
}

# Software Version Audit
Function Audit-Software {
    Log "Auditing Installed Software..."
    Write-Host "=== Installed Software ==="
    Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\* |
    Select-Object DisplayName, DisplayVersion | ForEach-Object {
        Write-Host "$($_.DisplayName): Version $($_.DisplayVersion)"
    }
    Log "Software Audit Completed."
}

# Performance Baseline Comparison
Function Compare-PerformanceBaseline {
    $BaselineFile = "$PSScriptRoot\PerformanceBaseline.json"
    Log "Comparing Performance Metrics with Baseline..."
    $CurrentMetrics = @{
        CPUUsage = (Get-Counter '\Processor(_Total)\% Processor Time').CounterSamples[0].CookedValue
        RAMUsage = [math]::Round(((Get-WmiObject Win32_OperatingSystem).TotalVisibleMemorySize - (Get-WmiObject Win32_OperatingSystem).FreePhysicalMemory) / 1MB, 2)
    }

    if (Test-Path $BaselineFile) {
        $BaselineMetrics = Get-Content -Path $BaselineFile | ConvertFrom-Json
        Write-Host "=== Performance Baseline Comparison ==="
        Write-Host "CPU Usage: Current = $($CurrentMetrics.CPUUsage)% | Baseline = $($BaselineMetrics.CPUUsage)%"
        Write-Host "RAM Usage: Current = $($CurrentMetrics.RAMUsage) MB | Baseline = $($BaselineMetrics.RAMUsage) MB"
    } else {
        Write-Host "No baseline found. Saving current metrics as baseline."
        $CurrentMetrics | ConvertTo-Json | Set-Content -Path $BaselineFile
    }
    Log "Baseline Comparison Completed."
}

# Backup User Data
Function Backup-UserData {
    Log "Starting Backup of User Data..."
    $BackupSource = "$env:USERPROFILE\Documents"
    $BackupDestination = "$PSScriptRoot\Backups"
    if (!(Test-Path -Path $BackupDestination)) {
        New-Item -ItemType Directory -Path $BackupDestination | Out-Null
    }
    Copy-Item -Path $BackupSource -Destination $BackupDestination -Recurse -Force
    Write-Host "Backup Completed: $BackupSource to $BackupDestination" -ForegroundColor Green
    Log "Backup Completed."
}

# Event Log Analysis
Function Analyze-EventLogs {
    Log "Analyzing Windows Event Logs..."
    $Errors = Get-WinEvent -LogName Application -MaxEvents 100 | Where-Object {$_.LevelDisplayName -eq "Error"}
    if ($Errors) {
        Write-Host "Found Application Errors:" -ForegroundColor Red
        $Errors | Format-Table -Property TimeCreated, Message -AutoSize
    } else {
        Write-Host "No Application Errors Found." -ForegroundColor Green
    }
    Log "Event Log Analysis Completed."
}

# Scheduling Task 
Function Schedule-Task {
    Log "Scheduling Task..."
    $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File $PSScriptRoot\AutomatedSystemHealthTool.ps1"
    $Trigger = New-ScheduledTaskTrigger -Daily -At "3:00AM"
    Register-ScheduledTask -TaskName "AutomatedSystemHealthCheck" -Action $Action -Trigger $Trigger -User "SYSTEM" -Force
    Log "Task Scheduled for Daily Execution."
}

# Main Script Execution
try {
    Log "Script Execution Started."
    Check-SystemHealth
    Run-SecurityScans
    Optimize-System
    Troubleshoot-Issues
    Check-WindowsUpdates
    Audit-Software
    Compare-PerformanceBaseline
    Backup-UserData
    Analyze-EventLogs
    Schedule-Task
    Log "Script Execution Completed Successfully."
} catch {
    Log "Error: $_"
    Write-Host "An error occurred: $_" -ForegroundColor Red
}
