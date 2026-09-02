# 诗词挑战 — DevEco 工程构建（自动补全 Java PATH）
# 用法：在 app/ 目录执行  .\build.ps1

$ErrorActionPreference = "Stop"
$DevecoRoot = "E:\software\DevEco Studio"
$Jbr = Join-Path $DevecoRoot "jbr"
$Node = Join-Path $DevecoRoot "tools\node\node.exe"
$Hvigor = Join-Path $DevecoRoot "tools\hvigor\bin\hvigorw.js"

if (-not (Test-Path (Join-Path $Jbr "bin\java.exe"))) {
  Write-Host "未找到 DevEco 自带 JBR：$Jbr" -ForegroundColor Red
  Write-Host "请在 DevEco Studio → Settings → 搜索 JDK，或修改本脚本 DevecoRoot 路径。"
  exit 1
}

$env:JAVA_HOME = $Jbr
$env:PATH = "$Jbr\bin;$env:PATH"
$env:DEVECO_SDK_HOME = Join-Path $DevecoRoot "sdk"

Write-Host "JAVA_HOME=$env:JAVA_HOME"
Write-Host "Stopping stale hvigor daemon (fixes spawn java ENOENT)..."
& $Node $Hvigor --stop-daemon 2>&1 | Out-Null

& $Node $Hvigor --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone assembleHap --analyze=normal --parallel --incremental --daemon
exit $LASTEXITCODE
