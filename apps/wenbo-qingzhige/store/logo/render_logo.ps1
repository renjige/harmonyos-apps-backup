# Rasterize 轻知阁 mark with System.Drawing (no Python).
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
  $navy = [System.Drawing.Color]::FromArgb(255, 18, 42, 54)
  $cream = [System.Drawing.Color]::FromArgb(255, 246, 241, 234)
  $apricot = [System.Drawing.Color]::FromArgb(255, 212, 165, 116)
  $brushN = New-Object System.Drawing.SolidBrush $navy
  $brushC = New-Object System.Drawing.SolidBrush $cream
  $brushA = New-Object System.Drawing.SolidBrush $apricot

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

  $left = New-Object System.Drawing.Drawing2D.GraphicsPath
  $left.AddPolygon(@(
    (New-Object System.Drawing.PointF (214 * $k), (430 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (360 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (780 * $k)),
    (New-Object System.Drawing.PointF (248 * $k), (820 * $k))
  ))
  $g.FillPath($brushC, $left)

  $right = New-Object System.Drawing.Drawing2D.GraphicsPath
  $right.AddPolygon(@(
    (New-Object System.Drawing.PointF (810 * $k), (430 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (360 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (780 * $k)),
    (New-Object System.Drawing.PointF (776 * $k), (820 * $k))
  ))
  $g.FillPath($brushC, $right)

  $g.FillRectangle($brushN, (498 * $k), (368 * $k), (16 * $k), (408 * $k))

  $eave = New-Object System.Drawing.Drawing2D.GraphicsPath
  $eave.AddPolygon(@(
    (New-Object System.Drawing.PointF (250 * $k), (392 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (292 * $k)),
    (New-Object System.Drawing.PointF (774 * $k), (392 * $k)),
    (New-Object System.Drawing.PointF (742 * $k), (412 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (326 * $k)),
    (New-Object System.Drawing.PointF (282 * $k), (412 * $k))
  ))
  $g.FillPath($brushC, $eave)

  $cx = 512 * $k
  $cy = 292 * $k
  $r = 36 * $k
  $g.FillEllipse($brushA, ($cx - $r), ($cy - $r), ($r * 2), ($r * 2))

  $g.Dispose()
  $brushN.Dispose()
  $brushC.Dispose()
  $brushA.Dispose()
  $path.Dispose()
  $left.Dispose()
  $right.Dispose()
  $eave.Dispose()
  return $bmp
}

$mark = New-Mark $Master
$preview = New-Object System.Drawing.Bitmap $Master, $Master
$pg = [System.Drawing.Graphics]::FromImage($preview)
$pg.Clear([System.Drawing.Color]::FromArgb(255, 18, 42, 54))
[void]$pg.DrawImageUnscaled($mark, 0, 0)
$pg.Dispose()
$preview.Save((Join-Path $Root 'preview-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear([System.Drawing.Color]::FromArgb(255, 246, 241, 234))
$bgG.Dispose()
$bg.Save((Join-Path $Root 'background.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bg.Dispose()

$mark.Save((Join-Path $Root 'foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$mark.Dispose()

$agcBmp = $preview.GetThumbnailImage($Agc, $Agc, $null, [IntPtr]::Zero)
$agcBmp.Save((Join-Path $Root 'agc-216.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$agcBmp.Dispose()
$preview.Dispose()
Write-Host 'OK rendered PNG masters for Qingzhige'
