# Rasterize 学见 mark (open book + gold light). Square, no self-rounding.
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Master = 1024
$Agc = 216
$navy = [System.Drawing.Color]::FromArgb(255, 26, 42, 74)
$paper = [System.Drawing.Color]::FromArgb(255, 247, 244, 238)
$gold = [System.Drawing.Color]::FromArgb(255, 245, 166, 35)

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
    (New-Object System.Drawing.PointF (188 * $k), (500 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (412 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (848 * $k)),
    (New-Object System.Drawing.PointF (220 * $k), (892 * $k))
  ))
  $g.FillPath($brushP, $left)

  $right = New-Object System.Drawing.Drawing2D.GraphicsPath
  $right.AddPolygon(@(
    (New-Object System.Drawing.PointF (836 * $k), (500 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (412 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (848 * $k)),
    (New-Object System.Drawing.PointF (804 * $k), (892 * $k))
  ))
  $g.FillPath($brushP, $right)

  $g.FillRectangle($brushN, (500 * $k), (420 * $k), (24 * $k), (428 * $k))
  $g.FillEllipse($brushG, ((512 - 56) * $k), ((268 - 56) * $k), (112 * $k), (112 * $k))

  $g.Dispose()
  $brushP.Dispose()
  $brushN.Dispose()
  $brushG.Dispose()
  $left.Dispose()
  $right.Dispose()
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
Write-Host 'OK rendered PNG masters for XueJian'
