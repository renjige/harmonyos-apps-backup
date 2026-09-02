# DevEco assembleHap helper - fixes spawn java ENOENT
$ErrorActionPreference = "Stop"

$DevEcoRoot = "E:\software\DevEco Studio"
$Node = Join-Path $DevEcoRoot "tools\node\node.exe"
$Hvigor = Join-Path $DevEcoRoot "tools\hvigor\bin\hvigorw.js"
$JbrBin = Join-Path $DevEcoRoot "jbr\bin"

if (-not (Test-Path $Node)) {
  Write-Error "DevEco node not found: $Node. Edit DevEcoRoot in this script."
}
if (-not (Test-Path (Join-Path $JbrBin "java.exe"))) {
  Write-Error "DevEco JBR not found: $JbrBin\java.exe"
}

$env:JAVA_HOME = Join-Path $DevEcoRoot "jbr"
$env:Path = "$JbrBin;" + $env:Path

Set-Location $PSScriptRoot

& $Node $Hvigor --stop-daemon 2>$null | Out-Null
& $Node $Hvigor --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone assembleHap --no-daemon

if ($LASTEXITCODE -ne 0) { exit $LASTEXITCODE }

Write-Host ""
Write-Host "HAP output:" -ForegroundColor Green
Get-ChildItem "entry\build\default\outputs\default\*.hap" | Select-Object FullName, Length, LastWriteTime
