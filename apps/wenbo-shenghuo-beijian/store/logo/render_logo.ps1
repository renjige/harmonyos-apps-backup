# Rasterize 生活备笺 mark with System.Drawing (no Python).
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
  $teal = [System.Drawing.Color]::FromArgb(255, 61, 130, 119)
  $cream = [System.Drawing.Color]::FromArgb(255, 247, 245, 239)
  $brushT = New-Object System.Drawing.SolidBrush $teal
  $brushC = New-Object System.Drawing.SolidBrush $cream

  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $radius = [int](220 * $k)
  $d = $radius * 2
  $rect = New-Object System.Drawing.Rectangle 0, 0, ($Size - 1), ($Size - 1)
  $path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
  $path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
  $path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
  $path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  $g.FillPath($brushT, $path)

  $paper = New-Object System.Drawing.Drawing2D.GraphicsPath
  $pts = @(
    (New-Object System.Drawing.PointF (268 * $k), (248 * $k)),
    (New-Object System.Drawing.PointF (660 * $k), (248 * $k)),
    (New-Object System.Drawing.PointF (796 * $k), (384 * $k)),
    (New-Object System.Drawing.PointF (796 * $k), (776 * $k)),
    (New-Object System.Drawing.PointF (716 * $k), (856 * $k)),
    (New-Object System.Drawing.PointF (348 * $k), (856 * $k)),
    (New-Object System.Drawing.PointF (268 * $k), (776 * $k)),
    (New-Object System.Drawing.PointF (268 * $k), (328 * $k))
  )
  $paper.AddPolygon($pts)
  $g.FillPath($brushC, $paper)

  $fold = New-Object System.Drawing.Drawing2D.GraphicsPath
  $fpts = @(
    (New-Object System.Drawing.PointF (660 * $k), (248 * $k)),
    (New-Object System.Drawing.PointF (796 * $k), (384 * $k)),
    (New-Object System.Drawing.PointF (708 * $k), (384 * $k)),
    (New-Object System.Drawing.PointF (660 * $k), (336 * $k))
  )
  $fold.AddPolygon($fpts)
  $g.FillPath($brushT, $fold)

  $lineBrush = $brushT
  $g.FillRectangle($lineBrush, (348 * $k), (488 * $k), (248 * $k), (28 * $k))

  $cx2 = 732 * $k
  $cy2 = 332 * $k
  $g.FillEllipse($brushC, ($cx2 - 42 * $k), ($cy2 - 42 * $k), (84 * $k), (84 * $k))

  $g.Dispose()
  $brushT.Dispose()
  $brushC.Dispose()
  $path.Dispose()
  $paper.Dispose()
  $fold.Dispose()
  return $bmp
}

$mark = New-Mark $Master
$preview = New-Object System.Drawing.Bitmap $Master, $Master
$pg = [System.Drawing.Graphics]::FromImage($preview)
$pg.Clear([System.Drawing.Color]::FromArgb(255, 61, 130, 119))
[void]$pg.DrawImageUnscaled($mark, 0, 0)
$pg.Dispose()
$preview.Save((Join-Path $Root 'preview-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear([System.Drawing.Color]::FromArgb(255, 247, 245, 239))
$bgG.Dispose()
$bg.Save((Join-Path $Root 'background.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bg.Dispose()

$mark.Save((Join-Path $Root 'foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$mark.Dispose()

$agcBmp = $preview.GetThumbnailImage($Agc, $Agc, $null, [IntPtr]::Zero)
$agcBmp.Save((Join-Path $Root 'agc-216.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$agcBmp.Dispose()
$preview.Dispose()
Write-Host 'OK rendered PNG masters for 生活备笺'
