# Automated-System-Health-Check-and-Optimization-Tool
The project is a comprehensive PowerShell script that automates the routine maintenance and optimization of a Windows 11 Home environment. It combines several functionalities to enhance system performance, troubleshoot issues, and ensure security, demonstrating expertise in scripting, automation, and system management.

Below is a detailed breakdown of what each section and function accomplishes:
### Setup: Log Folder Initialization

- Ensures that a Logs folder exists in the script directory.Creates the folder if it doesn't exist.
- Logs messages to a uniquely named log file based on the current timestamp


### Logging Function (Log)
- A utility function to log messages with timestamps.
- Appends the log messages to the log file for documentation and troubleshooting.

### System Health Monitoring (Check-SystemHealth)

- CPU Usage: Measures the system's CPU usage percentage using performance counters.
- Memory Usage:
    - Retrieves total and free physical memory.
    - Calculates memory usage as a percentage.
- Disk Space:
    - Enumerates file system drives.
    - Displays free and total space for each drive.

### Security Scans (Run-SecurityScans)

- Quick Scan: Uses Windows Defender to perform a quick malware scan.
- Audit Services:
  - Lists services that are running but set to manual start.
  - Helps identify unnecessary or suspicious running services.

### Optimization Tasks (Optimize-System)
- Temporary Files Cleanup: Deletes all files in the TEMP folder to free up disk space.
- Startup Program Optimization: Disables non-essential startup programs to improve system boot performance.

### Troubleshooting (Troubleshoot-Issues)
- System File Checker (SFC):
  Scans and repairs corrupted system files.
- DISM RestoreHealth:
    Checks and repairs Windows component store corruption.
- DNS Cache Flush:
    Clears the DNS cache to resolve potential networking issues.

### Check for Windows Updates (Check-WindowsUpdates)

- Automates the Windows Update process.
- Installs updates, accepts prompts, and reboots the system if necessary.

Software Audit (Audit-Software)

- Lists all installed software and their versions.
- Useful for tracking installed programs and identifying outdated software.

### Performance Baseline Comparison (Compare-PerformanceBaseline)

- Current Metrics:
    Captures current CPU and RAM usage.
- Baseline Metrics:
    Compares current metrics against a saved baseline if available.
    Saves the current metrics as a new baseline if no baseline exists.

### Backup User Data (Backup-UserData)

- Source: The user’s Documents folder.
- Destination: A backup folder in the script directory.
- Ensures important user data is safely backed up.

### Event Log Analysis (Analyze-EventLogs)

- Analyzes Windows Event Logs for application errors.
- Displays and logs error messages if found.

### Scheduling Task (Schedule-Task)

- Automates the script’s execution by scheduling it in Windows Task Scheduler.
- Executes daily at a specified time (3:00 AM).

### Error Handling

- Uses a try-catch block to handle exceptions during script execution.
- Logs errors and displays them in red for immediate attention.


## Steps to Run the Script:

#### Save the Script as:
```
    AutomatedSystemHealthTool.ps1.
```

#### Run PowerShell as Administrator:
- Right-click on the Windows Start button → Click PowerShell (Admin).

#### Enable Script Execution:
- Run the command:
- Set-ExecutionPolicy RemoteSigned
- Confirm with Y if prompted.
```
Set-ExecutionPolicy RemoteSigned
```

#### Execute the Script:
- Navigate to the folder containing the script.

```
Run: .\AutomatedSystemHealthTool.ps1
```

#### Review Logs:

- Check the Logs folder in the script's directory for detailed logs.

#### Required Modules:

- Install the PSWindowsUpdate module for Windows Update functionality:
```
    Install-Module -Name PSWindowsUpdate -Force -SkipPublisherCheck
```
