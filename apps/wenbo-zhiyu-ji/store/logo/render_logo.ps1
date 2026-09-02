# Rasterize 知语集 mark with System.Drawing (no Python).
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Master = 1024
$Agc = 216

function New-Mark([int]$Size) {
  $bmp = New-Object System.Drawing.Bitmap $Size, $Size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))

  $k = $Size / 1024.0
  $ink = [System.Drawing.Color]::FromArgb(255, 26, 42, 58)
  $gold = [System.Drawing.Color]::FromArgb(255, 201, 169, 110)
  $cream = [System.Drawing.Color]::FromArgb(255, 247, 245, 240)
  $brushInk = New-Object System.Drawing.SolidBrush $ink
  $brushGold = New-Object System.Drawing.SolidBrush $gold
  $brushCream = New-Object System.Drawing.SolidBrush $cream
  $penGold = New-Object System.Drawing.Pen $gold, ([Math]::Max(1, 6 * $k))

  $g.FillRectangle($brushInk, 0, 0, $Size, $Size)
  $paperRect = New-Object System.Drawing.Rectangle ([int](220 * $k)), ([int](260 * $k)), ([int](584 * $k)), ([int](504 * $k))
  $brushPaper = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(20, 247, 245, 240))
  $g.FillRectangle($brushPaper, $paperRect)
  $g.DrawLine($penGold, (512 * $k), (260 * $k), (512 * $k), (764 * $k))

  $g.FillRectangle($brushGold, (340 * $k), (300 * $k), (344 * $k), (56 * $k))
  foreach ($x in @(380, 460, 540, 620)) {
    $g.FillRectangle($brushCream, ($x * $k), (380 * $k), (48 * $k), (220 * $k))
  }
  $brushGold85 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(217, 201, 169, 110))
  $brushGold65 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(166, 201, 169, 110))
  $g.FillRectangle($brushGold85, (420 * $k), (460 * $k), (184 * $k), (40 * $k))
  $g.FillRectangle($brushGold65, (420 * $k), (540 * $k), (184 * $k), (40 * $k))
  $brushQuote = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(128, 201, 169, 110))
  $g.FillEllipse($brushQuote, (280 * $k), (580 * $k), (80 * $k), (60 * $k))
  $g.FillEllipse($brushQuote, (664 * $k), (580 * $k), (80 * $k), (60 * $k))

  $g.Dispose()
  $brushInk.Dispose()
  $brushGold.Dispose()
  $brushCream.Dispose()
  $brushPaper.Dispose()
  $brushGold85.Dispose()
  $brushGold65.Dispose()
  $brushQuote.Dispose()
  $penGold.Dispose()
  return $bmp
}

$mark = New-Mark $Master
$preview = New-Object System.Drawing.Bitmap $Master, $Master
$pg = [System.Drawing.Graphics]::FromImage($preview)
$pg.Clear([System.Drawing.Color]::FromArgb(255, 26, 42, 58))
[void]$pg.DrawImageUnscaled($mark, 0, 0)
$pg.Dispose()
$preview.Save((Join-Path $Root 'preview-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear([System.Drawing.Color]::FromArgb(255, 247, 245, 240))
$bgG.Dispose()
$bg.Save((Join-Path $Root 'background.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bg.Dispose()

$mark.Save((Join-Path $Root 'foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$agcBmp = $preview.GetThumbnailImage($Agc, $Agc, $null, [IntPtr]::Zero)
$agcBmp.Save((Join-Path $Root 'agc-216.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$agcBmp.Dispose()
$preview.Dispose()
$mark.Dispose()
Write-Host 'OK rendered 知语集 PNG masters'
