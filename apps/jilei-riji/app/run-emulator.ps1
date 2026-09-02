# 积累日记 — 模拟器运行脚本
$ErrorActionPreference = "Stop"
$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$DevecoRoot = "E:\software\DevEco Studio"
$env:JAVA_HOME = "$DevecoRoot\jbr"
$env:PATH = "$env:JAVA_HOME\bin;$env:PATH"
$Hdc = "$DevecoRoot\sdk\default\openharmony\toolchains\hdc.exe"
$Node = "$DevecoRoot\tools\node\node.exe"
$Hvigor = "$DevecoRoot\tools\hvigor\bin\hvigorw.js"
$Bundle = "jlrj.lwl.huawei"
$Hap = Join-Path $Root "entry\build\default\outputs\default\entry-default-signed.hap"

Write-Host ">> Stop hvigor daemon + Build HAP..."
Push-Location $Root
& $Node $Hvigor --stop-daemon 2>$null
& $Node $Hvigor --mode module -p module=entry@default -p product=default -p requiredDeviceType=phone assembleHap --parallel --incremental --no-daemon
if ($LASTEXITCODE -ne 0) { Pop-Location; exit $LASTEXITCODE }

Write-Host ">> Uninstall legacy bundle (if any)..."
& $Hdc shell bm uninstall -n com.qingjilei.jileiriji 2>$null | Out-Null

Write-Host ">> Install $Hap"
& $Hdc install -r $Hap
if ($LASTEXITCODE -ne 0) { Pop-Location; exit $LASTEXITCODE }

Write-Host ">> Start $Bundle / EntryAbility"
& $Hdc shell aa start -a EntryAbility -b $Bundle -m entry
Pop-Location
Write-Host ">> Done"
