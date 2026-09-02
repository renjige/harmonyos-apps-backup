# Rasterize 心笺日常 mark with System.Drawing (no Python).
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
  $apricot = [System.Drawing.Color]::FromArgb(255, 233, 141, 131)
  $cream = [System.Drawing.Color]::FromArgb(255, 255, 249, 246)
  $brushA = New-Object System.Drawing.SolidBrush $apricot
  $brushC = New-Object System.Drawing.SolidBrush $cream

  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $radius = [int](228 * $k)
  $d = $radius * 2
  $rect = New-Object System.Drawing.Rectangle 0, 0, ($Size - 1), ($Size - 1)
  $path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
  $path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
  $path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
  $path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  $g.FillPath($brushA, $path)

  $paper = New-Object System.Drawing.Drawing2D.GraphicsPath
  $pts = @(
    (New-Object System.Drawing.PointF (236 * $k), (252 * $k)),
    (New-Object System.Drawing.PointF (666 * $k), (252 * $k)),
    (New-Object System.Drawing.PointF (818 * $k), (404 * $k)),
    (New-Object System.Drawing.PointF (818 * $k), (776 * $k)),
    (New-Object System.Drawing.PointF (742 * $k), (852 * $k)),
    (New-Object System.Drawing.PointF (312 * $k), (852 * $k)),
    (New-Object System.Drawing.PointF (236 * $k), (776 * $k)),
    (New-Object System.Drawing.PointF (236 * $k), (328 * $k))
  )
  $paper.AddPolygon($pts)
  $g.FillPath($brushC, $paper)

  $heart = New-Object System.Drawing.Drawing2D.GraphicsPath
  $cx = 512 * $k
  $cy = 620 * $k
  $s = 9.2 * $k
  $hpts = New-Object 'System.Drawing.PointF[]' 72
  for ($i = 0; $i -lt 72; $i++) {
    $t = ($i / 72.0) * [Math]::PI * 2
    $x = $s * 16 * [Math]::Pow([Math]::Sin($t), 3)
    $y = -$s * (13 * [Math]::Cos($t) - 5 * [Math]::Cos(2 * $t) - 2 * [Math]::Cos(3 * $t) - [Math]::Cos(4 * $t))
    $hpts[$i] = New-Object System.Drawing.PointF ($cx + $x), ($cy + $y * 0.92)
  }
  $heart.AddPolygon($hpts)
  $g.FillPath($brushA, $heart)

  $cx2 = 768 * $k
  $cy2 = 328 * $k
  $g.FillEllipse($brushC, ($cx2 - 46 * $k), ($cy2 - 46 * $k), (92 * $k), (92 * $k))
  $g.FillEllipse($brushA, ($cx2 - 18 * $k), ($cy2 - 18 * $k), (36 * $k), (36 * $k))

  $g.Dispose()
  $brushA.Dispose()
  $brushC.Dispose()
  $path.Dispose()
  $paper.Dispose()
  $heart.Dispose()
  return $bmp
}

$mark = New-Mark $Master
$preview = New-Object System.Drawing.Bitmap $Master, $Master
$pg = [System.Drawing.Graphics]::FromImage($preview)
$pg.Clear([System.Drawing.Color]::FromArgb(255, 233, 141, 131))
[void]$pg.DrawImageUnscaled($mark, 0, 0)
$pg.Dispose()
$preview.Save((Join-Path $Root 'preview-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear([System.Drawing.Color]::FromArgb(255, 255, 249, 246))
$bgG.Dispose()
$bg.Save((Join-Path $Root 'background.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bg.Dispose()

$mark.Save((Join-Path $Root 'foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$mark.Dispose()

$agcBmp = $preview.GetThumbnailImage($Agc, $Agc, $null, [IntPtr]::Zero)
$agcBmp.Save((Join-Path $Root 'agc-216.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$agcBmp.Dispose()
$preview.Dispose()
Write-Host 'OK rendered PNG masters for 心笺日常'
