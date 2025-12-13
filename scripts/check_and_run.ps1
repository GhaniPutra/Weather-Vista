# scripts/check_and_run.ps1
# This script checks the free disk space on the drive containing TEMP and
# if there is enough free space, it runs `flutter run -d chrome`.
# Usage:
#   PowerShell -ExecutionPolicy Bypass -File .\scripts\check_and_run.ps1

$minBytes = 1024 * 1024 * 1024 # 1 GB
$tempDrive = [System.IO.Path]::GetPathRoot($env:TEMP)
$driveInfo = Get-PSDrive -Name $tempDrive.TrimEnd('\')

if ($driveInfo.Free -lt $minBytes) {
  Write-Host "Free space on drive $($tempDrive) is below 1GB ($([math]::Round($driveInfo.Free/1GB, 2)) GB)." -ForegroundColor Yellow
  Write-Host "Try freeing disk space, or set TMP/TEMP to another drive with sufficient space."
  Write-Host "Example: set TMP=D:\temp; set TEMP=D:\temp" -ForegroundColor Cyan
  exit 1
}

Write-Host "Sufficient free space available ($([math]::Round($driveInfo.Free/1GB, 2)) GB). Running flutter..." -ForegroundColor Green
flutter run -d chrome
