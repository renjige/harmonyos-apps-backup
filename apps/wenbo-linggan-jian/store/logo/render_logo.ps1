# Rasterize 灵感笺 mark with System.Drawing (no Python).
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
  $ink = [System.Drawing.Color]::FromArgb(255, 24, 35, 58)
  $gold = [System.Drawing.Color]::FromArgb(255, 229, 184, 107)
  $cream = [System.Drawing.Color]::FromArgb(255, 247, 243, 234)
  $brushInk = New-Object System.Drawing.SolidBrush $ink
  $brushGold = New-Object System.Drawing.SolidBrush $gold
  $brushCream = New-Object System.Drawing.SolidBrush $cream

  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $radius = [int](228 * $k)
  $d = $radius * 2
  $rect = New-Object System.Drawing.Rectangle 0, 0, ($Size - 1), ($Size - 1)
  $path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
  $path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
  $path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
  $path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  $g.FillPath($brushInk, $path)

  $paper = New-Object System.Drawing.Drawing2D.GraphicsPath
  $pts = @(
    (New-Object System.Drawing.PointF (268 * $k), (236 * $k)),
    (New-Object System.Drawing.PointF (660 * $k), (236 * $k)),
    (New-Object System.Drawing.PointF (808 * $k), (384 * $k)),
    (New-Object System.Drawing.PointF (808 * $k), (780 * $k)),
    (New-Object System.Drawing.PointF (728 * $k), (860 * $k)),
    (New-Object System.Drawing.PointF (348 * $k), (860 * $k)),
    (New-Object System.Drawing.PointF (268 * $k), (780 * $k)),
    (New-Object System.Drawing.PointF (268 * $k), (316 * $k))
  )
  $paper.AddPolygon($pts)
  $g.FillPath($brushGold, $paper)

  $fold = New-Object System.Drawing.Drawing2D.GraphicsPath
  $fpts = @(
    (New-Object System.Drawing.PointF (660 * $k), (236 * $k)),
    (New-Object System.Drawing.PointF (808 * $k), (384 * $k)),
    (New-Object System.Drawing.PointF (708 * $k), (384 * $k)),
    (New-Object System.Drawing.PointF (660 * $k), (336 * $k))
  )
  $fold.AddPolygon($fpts)
  $g.FillPath($brushInk, $fold)

  $star = New-Object System.Drawing.Drawing2D.GraphicsPath
  $cx = 512 * $k
  $cy = 620 * $k
  $rOut = 118 * $k
  $rIn = 48 * $k
  $spts = New-Object 'System.Drawing.PointF[]' 8
  for ($i = 0; $i -lt 8; $i++) {
    $ang = -[Math]::PI / 2 + $i * [Math]::PI / 4
    $r = if ($i % 2 -eq 0) { $rOut } else { $rIn }
    $spts[$i] = New-Object System.Drawing.PointF ($cx + $r * [Math]::Cos($ang)), ($cy + $r * [Math]::Sin($ang))
  }
  $star.AddPolygon($spts)
  $g.FillPath($brushCream, $star)

  $g.Dispose()
  $brushInk.Dispose()
  $brushGold.Dispose()
  $brushCream.Dispose()
  $path.Dispose()
  $paper.Dispose()
  $fold.Dispose()
  $star.Dispose()
  return $bmp
}

$mark = New-Mark $Master
$preview = New-Object System.Drawing.Bitmap $Master, $Master
$pg = [System.Drawing.Graphics]::FromImage($preview)
$pg.Clear([System.Drawing.Color]::FromArgb(255, 24, 35, 58))
[void]$pg.DrawImageUnscaled($mark, 0, 0)
$pg.Dispose()
$preview.Save((Join-Path $Root 'preview-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear([System.Drawing.Color]::FromArgb(255, 247, 243, 234))
$bgG.Dispose()
$bg.Save((Join-Path $Root 'background.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bg.Dispose()

$mark.Save((Join-Path $Root 'foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$board = New-Object System.Drawing.Bitmap 1280, 360
$bgd = [System.Drawing.Graphics]::FromImage($board)
$bgd.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$bgd.Clear([System.Drawing.Color]::FromArgb(255, 247, 243, 234))
$icon = New-Mark 288
[void]$bgd.DrawImage($icon, 40, 36, 288, 288)
$inkBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 24, 35, 58))
$secBrush = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 133, 139, 153))
$font = New-Object System.Drawing.Font 'Microsoft YaHei UI', 42, ([System.Drawing.FontStyle]::Bold)
$sub = New-Object System.Drawing.Font 'Microsoft YaHei UI', 14
$bgd.DrawString('Linggan Jian', $font, $inkBrush, 360, 110)
$bgd.DrawString('Linggan Jian', $sub, $secBrush, 360, 210)
$board.Save((Join-Path $Root 'logo-horizontal.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bgd.Dispose()
$board.Dispose()
$icon.Dispose()
$inkBrush.Dispose()
$secBrush.Dispose()
$font.Dispose()
$sub.Dispose()

$agcBmp = $preview.GetThumbnailImage($Agc, $Agc, $null, [IntPtr]::Zero)
$agcBmp.Save((Join-Path $Root 'agc-216.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$agcBmp.Dispose()
$preview.Dispose()
$mark.Dispose()
Write-Host 'OK rendered PNG masters'
