# Sync logo PNG masters to 1024x1024 and copy into HarmonyOS media folders.
param(
  [string]$Source = "$PSScriptRoot\..\..\..\..\assets\preview-1024.png",
  [string]$LogoDir = "$PSScriptRoot",
  [string]$AppRoot = "$PSScriptRoot\..\..\app"
)

Add-Type -AssemblyName System.Drawing

function Save-SquareImage {
  param(
    [System.Drawing.Image]$Image,
    [int]$Size,
    [string]$Path
  )
  $side = [Math]::Min($Image.Width, $Image.Height)
  $left = [Math]::Floor(($Image.Width - $side) / 2)
  $top = [Math]::Floor(($Image.Height - $side) / 2)
  $bmp = New-Object System.Drawing.Bitmap $Size, $Size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($Image, 0, 0, (New-Object System.Drawing.Rectangle $left, $top, $side, $side), [System.Drawing.GraphicsUnit]::Pixel)
  $g.Dispose()
  $dir = Split-Path $Path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
  $bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
}

$srcPath = Resolve-Path $Source -ErrorAction Stop
$logoDir = Resolve-Path $LogoDir -ErrorAction Stop
$appRoot = Resolve-Path $AppRoot -ErrorAction Stop

$img = [System.Drawing.Image]::FromFile($srcPath)
Write-Host "Source:" $srcPath "->" $img.Width "x" $img.Height

$preview = Join-Path $logoDir "preview-1024.png"
$background = Join-Path $logoDir "background.png"
$agc = Join-Path $logoDir "agc-216.png"

Save-SquareImage -Image $img -Size 1024 -Path $preview

$bg = New-Object System.Drawing.Bitmap 1024, 1024
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear([System.Drawing.Color]::FromArgb(255, 26, 26, 46))
$bgG.Dispose()
$bg.Save($background, [System.Drawing.Imaging.ImageFormat]::Png)
$bg.Dispose()

$previewImg = [System.Drawing.Image]::FromFile($preview)
Save-SquareImage -Image $previewImg -Size 216 -Path $agc
$previewImg.Dispose()
$img.Dispose()

$iconTargets = @(
  "AppScope\resources\base\media\app_icon.png",
  "entry\src\main\resources\base\media\icon.png",
  "entry\src\main\resources\base\media\startIcon.png",
  "entry\src\main\resources\base\media\app_icon.png"
)

foreach ($rel in $iconTargets) {
  $dest = Join-Path $appRoot $rel
  Copy-Item $preview $dest -Force
  Write-Host "Synced" $dest
}

$check = [System.Drawing.Image]::FromFile($preview)
Write-Host "preview-1024.png ->" $check.Width "x" $check.Height
$check.Dispose()
