# Rasterize 问知 mark with System.Drawing (no Python).
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Master = 1024
$Agc = 216

function New-Mark([int]$Size, [bool]$Transparent) {
  $bmp = New-Object System.Drawing.Bitmap $Size, $Size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  if ($Transparent) {
    $g.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
  } else {
    $g.Clear([System.Drawing.Color]::FromArgb(255, 11, 31, 58))
  }

  $k = $Size / 1024.0
  $navy = [System.Drawing.Color]::FromArgb(255, 11, 31, 58)
  $white = [System.Drawing.Color]::FromArgb(255, 255, 255, 255)
  $orange = [System.Drawing.Color]::FromArgb(255, 255, 140, 0)
  $brushN = New-Object System.Drawing.SolidBrush $navy
  $brushO = New-Object System.Drawing.SolidBrush $orange
  $pen = New-Object System.Drawing.Pen $white, (92 * $k)
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

  if (-not $Transparent) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $radius = [int](220 * $k)
    $d = $radius * 2
    $rect = New-Object System.Drawing.Rectangle 0, 0, ($Size - 1), ($Size - 1)
    $path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
    $path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
    $path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    $g.FillPath($brushN, $path)
    $path.Dispose()
  }

  # Question-mark hook: three cubic-ish arcs approximated with Bezier
  $gp = New-Object System.Drawing.Drawing2D.GraphicsPath
  $p0 = New-Object System.Drawing.PointF (318 * $k), (390 * $k)
  $p1 = New-Object System.Drawing.PointF (318 * $k), (272 * $k)
  $p2 = New-Object System.Drawing.PointF (414 * $k), (192 * $k)
  $p3 = New-Object System.Drawing.PointF (512 * $k), (192 * $k)
  $p4 = New-Object System.Drawing.PointF (614 * $k), (192 * $k)
  $p5 = New-Object System.Drawing.PointF (704 * $k), (266 * $k)
  $p6 = New-Object System.Drawing.PointF (704 * $k), (378 * $k)
  $p7 = New-Object System.Drawing.PointF (704 * $k), (466 * $k)
  $p8 = New-Object System.Drawing.PointF (656 * $k), (510 * $k)
  $p9 = New-Object System.Drawing.PointF (592 * $k), (546 * $k)
  $p10 = New-Object System.Drawing.PointF (540 * $k), (576 * $k)
  $p11 = New-Object System.Drawing.PointF (512 * $k), (622 * $k)
  $p12 = New-Object System.Drawing.PointF (512 * $k), (676 * $k)
  $gp.AddBezier($p0, $p1, $p2, $p3)
  $gp.AddBezier($p3, $p4, $p5, $p6)
  $gp.AddBezier($p6, $p7, $p8, $p9)
  $gp.AddBezier($p9, $p10, $p11, $p12)
  $g.DrawPath($pen, $gp)

  $cx = 512 * $k
  $cy = 812 * $k
  $r = 52 * $k
  $g.FillEllipse($brushO, ($cx - $r), ($cy - $r), ($r * 2), ($r * 2))

  $g.Dispose()
  $brushN.Dispose()
  $brushO.Dispose()
  $pen.Dispose()
  $gp.Dispose()
  return $bmp
}

$preview = New-Mark $Master $false
$preview.Save((Join-Path $Root 'preview-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear([System.Drawing.Color]::FromArgb(255, 11, 31, 58))
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
Write-Host 'OK rendered PNG masters for WenZhi'
