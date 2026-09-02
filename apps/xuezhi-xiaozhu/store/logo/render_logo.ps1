# Rasterize 学知小筑 mark (book + cottage). Square, no self-rounding.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Master = 1024
$Agc = 216
$navy = [System.Drawing.Color]::FromArgb(255, 18, 32, 58)
$paper = [System.Drawing.Color]::FromArgb(255, 247, 244, 238)
$gold = [System.Drawing.Color]::FromArgb(255, 212, 165, 58)

function New-Glyph([int]$Size, [bool]$WithNavyFill) {
  $bmp = New-Object System.Drawing.Bitmap $Size, $Size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  if ($WithNavyFill) {
    $g.Clear($navy)
  } else {
    $g.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
  }
  $k = $Size / 1024.0
  $brushP = New-Object System.Drawing.SolidBrush $paper
  $brushN = New-Object System.Drawing.SolidBrush $navy
  $brushG = New-Object System.Drawing.SolidBrush $gold

  $left = New-Object System.Drawing.Drawing2D.GraphicsPath
  $left.AddPolygon(@(
    (New-Object System.Drawing.PointF (196 * $k), (470 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (392 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (820 * $k)),
    (New-Object System.Drawing.PointF (228 * $k), (868 * $k))
  ))
  $g.FillPath($brushP, $left)

  $right = New-Object System.Drawing.Drawing2D.GraphicsPath
  $right.AddPolygon(@(
    (New-Object System.Drawing.PointF (828 * $k), (470 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (392 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (820 * $k)),
    (New-Object System.Drawing.PointF (796 * $k), (868 * $k))
  ))
  $g.FillPath($brushP, $right)

  $g.FillRectangle($brushN, (500 * $k), (400 * $k), (24 * $k), (420 * $k))

  $roof = New-Object System.Drawing.Drawing2D.GraphicsPath
  $roof.AddPolygon(@(
    (New-Object System.Drawing.PointF (320 * $k), (392 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (188 * $k)),
    (New-Object System.Drawing.PointF (704 * $k), (392 * $k))
  ))
  $g.FillPath($brushP, $roof)
  $g.FillRectangle($brushP, (400 * $k), (392 * $k), (224 * $k), (56 * $k))
  $g.FillRectangle($brushG, (476 * $k), (268 * $k), (72 * $k), (72 * $k))

  $g.Dispose()
  $brushP.Dispose()
  $brushN.Dispose()
  $brushG.Dispose()
  $left.Dispose()
  $right.Dispose()
  $roof.Dispose()
  return $bmp
}

$preview = New-Glyph $Master $true
$preview.Save((Join-Path $Root 'preview-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$fg = New-Glyph $Master $false
$fg.Save((Join-Path $Root 'foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$fg.Dispose()

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear($navy)
$bgG.Dispose()
$bg.Save((Join-Path $Root 'background.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bg.Dispose()

$agcBmp = $preview.GetThumbnailImage($Agc, $Agc, $null, [IntPtr]::Zero)
$agcBmp.Save((Join-Path $Root 'agc-216.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$agcBmp.Dispose()
$preview.Dispose()
Write-Host 'OK rendered PNG masters for Xuezhi Xiaozhu'
