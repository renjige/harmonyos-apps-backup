# Rasterize 常识集 mark with System.Drawing (no Python).
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Master = 1024
$Agc = 216

function New-Mark([int]$Size, [bool]$TransparentBg) {
  $bmp = New-Object System.Drawing.Bitmap $Size, $Size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::None
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::Half
  if ($TransparentBg) {
    $g.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
  } else {
    $g.Clear([System.Drawing.Color]::FromArgb(255, 10, 37, 64))
  }

  $k = $Size / 1024.0
  $navy = [System.Drawing.Color]::FromArgb(255, 10, 37, 64)
  $white = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
  $mist = [System.Drawing.Color]::FromArgb(255, 244, 247, 251)
  $gold = [System.Drawing.Color]::FromArgb(255, 245, 166, 35)
  $brushN = New-Object System.Drawing.SolidBrush $navy
  $brushW = New-Object System.Drawing.SolidBrush $white
  $brushM = New-Object System.Drawing.SolidBrush $mist
  $brushG = New-Object System.Drawing.SolidBrush $gold

  if ($TransparentBg) {
    # foreground only: stacked cards + gold bar
  } else {
    $g.FillRectangle($brushN, 0, 0, $Size, $Size)
  }

  $g.FillRectangle($brushW, [int](268 * $k), [int](430 * $k), [int](488 * $k), [int](268 * $k))
  $g.FillRectangle($brushM, [int](300 * $k), [int](372 * $k), [int](424 * $k), [int](268 * $k))
  $g.FillRectangle($brushW, [int](332 * $k), [int](314 * $k), [int](360 * $k), [int](268 * $k))
  $g.FillRectangle($brushG, [int](356 * $k), [int](348 * $k), [int](200 * $k), [int](28 * $k))

  $g.Dispose()
  $brushN.Dispose()
  $brushW.Dispose()
  $brushM.Dispose()
  $brushG.Dispose()
  return $bmp
}

$preview = New-Mark $Master $false
$preview.Save((Join-Path $Root 'preview-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear([System.Drawing.Color]::FromArgb(255, 10, 37, 64))
$bgG.Dispose()
$bg.Save((Join-Path $Root 'background.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bg.Dispose()

$fg = New-Mark $Master $true
$fg.Save((Join-Path $Root 'foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$fg.Dispose()

$agcBmp = $preview.GetThumbnailImage($Agc, $Agc, $null, [IntPtr]::Zero)
$agcBmp.Save((Join-Path $Root 'agc-216.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$agcBmp.Dispose()
$preview.Dispose()
Write-Host 'OK rendered PNG masters for Changshiji'
