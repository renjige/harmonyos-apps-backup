# 森野小记 — 打包 HAP（自动配置 DevEco 自带 JDK）
# 用法：在 PowerShell 中 cd 到本目录后执行 .\build-hap.ps1

$ErrorActionPreference = "Stop"

$DevecoRoot = "E:\software\DevEco Studio"
$env:JAVA_HOME = "$DevecoRoot\jbr"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"

$Node = "$DevecoRoot\tools\node\node.exe"
$Hvigor = "$DevecoRoot\tools\hvigor\bin\hvigorw.js"

if (-not (Test-Path $Node)) {
  Write-Host "未找到 DevEco Node: $Node" -ForegroundColor Red
  Write-Host "请修改 build-hap.ps1 中的 `$DevecoRoot 为本机 DevEco 安装路径"
  exit 1
}

if (-not (Test-Path "$env:JAVA_HOME\bin\java.exe")) {
  Write-Host "未找到 Java: $env:JAVA_HOME\bin\java.exe" -ForegroundColor Red
  exit 1
}

Write-Host "JAVA_HOME=$env:JAVA_HOME"
& "$env:JAVA_HOME\bin\java.exe" -version

Write-Host "`n==> assembleHap"
& $Node $Hvigor --stop-daemon 2>$null
& $Node $Hvigor --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone assembleHap --analyze=normal --parallel --incremental --no-daemon

if ($LASTEXITCODE -eq 0) {
  Write-Host ""
  Write-Host "HAP built: entry\build\default\outputs\default\entry-default-unsigned.hap" -ForegroundColor Green
} else {
  exit $LASTEXITCODE
}
