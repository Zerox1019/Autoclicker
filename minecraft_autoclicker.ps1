# Initialisierung der Variablen
$clickDelay = 0  # Kein Delay für Klicks
$scanDelay = 0   # Kein Delay beim Scannen
$triggerActive = $false  # Der Trigger ist zu Beginn inaktiv

# Skript- und EXE-Dateipfade
$scriptPath = $MyInvocation.MyCommand.Path
$exeName = "ColorTriggerBot.exe"  # Der Name der EXE-Datei
$exePath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($scriptPath), $exeName)

# Funktion zur Überwachung der "END"-Taste und zum Schließen des Skripts
Function Monitor-ENDKeyAndCleanUp {
    Write-Host "Warte auf 'END'-Taste, um das Skript zu schließen und Bereinigung durchzuführen..." -ForegroundColor Yellow

    while ($true) {
        # Überprüfen, ob die END-Taste gedrückt wurde
        if ([System.Windows.Forms.Control]::ModifierKeys -eq [System.Windows.Forms.Keys]::End) {
            # Bereinigung und Schließen durchführen
            Perform-CleanupAndExit
            break
        }
        Start-Sleep -Milliseconds 100  # Kurze Verzögerung für CPU-Schonung
    }
}

# Bereinigung und Löschen von relevanten Dateien (Logs, Temp, Prefetch, Recent)
Function Perform-CleanupAndExit {
    Write-Host "Bereinigung startet..." -ForegroundColor Green

    # Relevante temporäre Dateien, Logs und EXE löschen
    Clear-SpecificSpurs

    # PowerShell ISE und das Skript schließen
    Write-Host "Schließe PowerShell ISE und das Skript..." -ForegroundColor Green
    Stop-Process -Name "powershell_ise" -Force
    Exit
}

# Bereinigung von Dateien, die mit PowerShell ISE, dem Skript oder der EXE zu tun haben
Function Clear-SpecificSpurs {
    Write-Host "Bereinige spezifische Spuren von PowerShell ISE, .exe und dem Skript..." -ForegroundColor Yellow

    # Löschen der .exe-Datei, wenn sie vorhanden ist
    if (Test-Path $exePath) {
        Remove-Item -Path $exePath -Force
        Write-Host "Die .exe-Datei gelöscht." -ForegroundColor Green
    }

    # Löschen des Skripts, wenn gewünscht
    if (Test-Path $scriptPath) {
        Remove-Item -Path $scriptPath -Force
        Write-Host "Das Skript gelöscht." -ForegroundColor Green
    }

    # Temporäre Dateien (Temp)
    $tempPaths = @("$env:TEMP", "$env:USERPROFILE\AppData\Local\Temp")
    foreach ($tempPath in $tempPaths) {
        $files = Get-ChildItem -Path $tempPath -Recurse | Where-Object { $_.Name -match "$exeName|$scriptPath" }
        foreach ($file in $files) {
            Remove-Item -Path $file.FullName -Force
            Write-Host "Temporäre Datei $($file.FullName) gelöscht." -ForegroundColor Green
        }
    }

    # Löschen von Prefetch, Recent und Logs
    $prefetchPath = "C:\Windows\Prefetch"
    $recentPath = "$env:APPDATA\Microsoft\Windows\Recent"
    $logPaths = @(
        "$env:LOCALAPPDATA\Microsoft\Windows\PowerShell\ISE",
        "$env:USERPROFILE\AppData\Roaming\Microsoft\Windows\PowerShell\ISE",
        "$env:TEMP"
    )

    # Löschen von Log-Dateien und temporären Dateien
    foreach ($logPath in $logPaths) {
        if (Test-Path $logPath) {
            $logFiles = Get-ChildItem -Path $logPath -Recurse | Where-Object { $_.Name -match "PowerShell ISE|$exeName|$scriptPath" }
            foreach ($logFile in $logFiles) {
                Remove-Item -Path $logFile.FullName -Force
                Write-Host "Log-Datei $($logFile.FullName) gelöscht." -ForegroundColor Green
            }
        }
    }

    # Löschen von Prefetch und Recent
    if (Test-Path $prefetchPath) {
        $prefetchFiles = Get-ChildItem -Path $prefetchPath | Where-Object { $_.Name -match "PowerShell ISE|$exeName|$scriptPath" }
        foreach ($file in $prefetchFiles) {
            Remove-Item -Path $file.FullName -Force
            Write-Host "Prefetch-Datei $($file.FullName) gelöscht." -ForegroundColor Green
        }
    }

    if (Test-Path $recentPath) {
        $recentFiles = Get-ChildItem -Path $recentPath | Where-Object { $_.Name -match "PowerShell ISE|$exeName|$scriptPath" }
        foreach ($file in $recentFiles) {
            Remove-Item -Path $file.FullName -Force
            Write-Host "Recent-Datei $($file.FullName) gelöscht." -ForegroundColor Green
        }
    }
}

# Start der Farbüberwachung und der Trigger-Logik
Function Start-ColorTriggerBot {
    Write-Host "Farbüberwachung gestartet. Drücke und halte XBUTTON2, um den Trigger zu aktivieren." -ForegroundColor Green
    
    while ($true) {
        # Überprüfen, ob XBUTTON2 gedrückt ist
        $isXButton2Pressed = [System.Windows.Forms.Control]::ModifierKeys -eq [System.Windows.Forms.Keys]::XButton2
        
        if ($isXButton2Pressed -and -not $triggerActive) {
            $triggerActive = $true
            Write-Host "Trigger aktiviert!" -ForegroundColor Cyan
        }
        
        if (-not $isXButton2Pressed -and $triggerActive) {
            $triggerActive = $false
            Write-Host "Trigger deaktiviert!" -ForegroundColor Cyan
        }

        # Wenn der Trigger aktiv ist, den Bildschirm nach der Ziel-Farbe scannen
        if ($triggerActive) {
            # Beispielhafte Funktionsweise für Farbüberprüfung (z.B. nach einem roten Punkt suchen)
            Check-ForRedDot
        }

        # Echtzeit-Überprüfung alle 20 ms
        Start-Sleep -Milliseconds 20  # Sehr kurze Verzögerung für Echtzeit-Performance
    }
}

# Beispielhafte Funktion zum Überprüfen von Farben (Trigger)
Function Check-ForRedDot {
    # Placeholder-Funktion für das Erkennen einer Ziel-Farbe
    # Implementiere hier den Code zum Erkennen der roten Farbe
    Write-Host "Suche nach der Ziel-Farbe (roter Punkt)..." -ForegroundColor Yellow
}

# Hauptprogramm starten
Function Main {
    Write-Host "By XLII Bande" -ForegroundColor Green  # Copyright-Status
    
    # Parallel die Funktionen starten
    Start-ColorTriggerBot
    Monitor-ENDKeyAndCleanUp
}

# Main-Funktion aufrufen
Main
