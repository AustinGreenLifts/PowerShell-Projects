# Define the log file path
$logFilePath = "C:\Users\austi\Documents\LogonAttempts.log"

# Define the time frame for logon events (in hours)
$logonTimeFrame = 24

# Get the current date and time
$currentTime = Get-Date

# Calculate the start time based on the time frame
$startTime = $currentTime.AddHours(-$logonTimeFrame)

# Get logon events from the Security event log within the specified time frame
$logonEvents = Get-WinEvent -FilterHashtable @{
    LogName   = 'Security'
    ID        = 4624, 4625  # Logon success and failure events
    StartTime = $startTime
} | Sort-Object TimeCreated -Descending

# Iterate through logon events and write them to the log file
$logEntries = foreach ($event in $logonEvents) {
    $eventTime = $event.TimeCreated
    $eventType = if ($event.Id -eq 4624) { "Logon Success" } else { "Logon Failure" }

    $logEntry = "Time: $($eventTime.ToString('yyyy-MM-dd HH:mm:ss'))`tType: $($eventType)`tUser: $($event.Properties[5].Value)`tSource: $($event.Properties[8].Value)"
    Write-Output $logEntry
}

# Write log entries to the log file
$logEntries | Out-File -FilePath $logFilePath -Append

Write-Host "Logon attempts logged to $logFilePath."
