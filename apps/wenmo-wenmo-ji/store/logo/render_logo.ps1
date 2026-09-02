# Rasterize 文墨集 mark — System.Drawing
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Master = 1024
$Agc = 216

function New-WenmoMark([int]$Size) {
  $bmp = New-Object System.Drawing.Bitmap $Size, $Size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))

  $k = $Size / 1024.0
  $ink = [System.Drawing.Color]::FromArgb(255, 26, 26, 46)
  $cream = [System.Drawing.Color]::FromArgb(255, 245, 240, 232)
  $cinnabar = [System.Drawing.Color]::FromArgb(255, 196, 26, 26)

  $brushInk = New-Object System.Drawing.SolidBrush $ink
  $brushCream = New-Object System.Drawing.SolidBrush $cream
  $brushCinnabar = New-Object System.Drawing.SolidBrush $cinnabar
  $penCream = New-Object System.Drawing.Pen $cream, ([Math]::Max(2, 56 * $k))
  $penCream.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $penCream.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $penCinnabar = New-Object System.Drawing.Pen $cinnabar, ([Math]::Max(2, 28 * $k))
  $penCinnabar.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $penCinnabar.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

  $g.FillRectangle($brushInk, 0, 0, $Size, $Size)

  $dotR = 30 * $k
  $g.FillEllipse($brushCream, (512 * $k - $dotR), (268 * $k - $dotR), ($dotR * 2), ($dotR * 2))
  $g.FillRectangle($brushCream, (300 * $k), (328 * $k), (424 * $k), (52 * $k))
  $g.DrawLine($penCream, (368 * $k), (420 * $k), (296 * $k), (748 * $k))
  $g.DrawLine($penCream, (656 * $k), (420 * $k), (728 * $k), (748 * $k))
  $brushCream92 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 245, 240, 232))
  $g.FillRectangle($brushCream92, (392 * $k), (468 * $k), (240 * $k), (38 * $k))

  $g.DrawBezier($penCinnabar,
    (168 * $k), (792 * $k),
    (360 * $k), (640 * $k),
    (520 * $k), (700 * $k),
    (680 * $k), (620 * $k))
  $g.DrawBezier($penCinnabar,
    (680 * $k), (620 * $k),
    (780 * $k), (560 * $k),
    (848 * $k), (588 * $k),
    (872 * $k), (520 * $k))

  $g.Dispose()
  $brushInk.Dispose()
  $brushCream.Dispose()
  $brushCream92.Dispose()
  $brushCinnabar.Dispose()
  $penCream.Dispose()
  $penCinnabar.Dispose()
  return $bmp
}

$mark = New-WenmoMark $Master
$preview = New-Object System.Drawing.Bitmap $Master, $Master
$pg = [System.Drawing.Graphics]::FromImage($preview)
$pg.Clear([System.Drawing.Color]::FromArgb(255, 26, 26, 46))
[void]$pg.DrawImageUnscaled($mark, 0, 0)
$pg.Dispose()
$preview.Save((Join-Path $Root 'preview-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear([System.Drawing.Color]::FromArgb(255, 26, 26, 46))
$bgG.Dispose()
$bg.Save((Join-Path $Root 'background.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bg.Dispose()

$fg = New-Object System.Drawing.Bitmap $Master, $Master
$fgG = [System.Drawing.Graphics]::FromImage($fg)
$fgG.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
$creamOnly = New-WenmoMark $Master
# foreground: transparent bg with mark only — redraw cream+cinnabar on transparent
$fgG2 = [System.Drawing.Graphics]::FromImage($fg)
$fgG2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$k = 1.0
$cream = [System.Drawing.Color]::FromArgb(255, 245, 240, 232)
$cinnabar = [System.Drawing.Color]::FromArgb(255, 196, 26, 26)
$brushCream = New-Object System.Drawing.SolidBrush $cream
$penCream = New-Object System.Drawing.Pen $cream, 56
$penCream.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$penCream.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$penCinnabar = New-Object System.Drawing.Pen $cinnabar, 28
$penCinnabar.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
$penCinnabar.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
$fgG2.FillEllipse($brushCream, 482, 238, 60, 60)
$fgG2.FillRectangle($brushCream, 300, 328, 424, 52)
$fgG2.DrawLine($penCream, 368, 420, 296, 748)
$fgG2.DrawLine($penCream, 656, 420, 728, 748)
$brushCream92 = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(235, 245, 240, 232))
$fgG2.FillRectangle($brushCream92, 392, 468, 240, 38)
$fgG2.DrawBezier($penCinnabar, 168, 792, 360, 640, 520, 700, 680, 620)
$fgG2.DrawBezier($penCinnabar, 680, 620, 780, 560, 848, 588, 872, 520)
$fgG2.Dispose()
$brushCream.Dispose()
$brushCream92.Dispose()
$penCream.Dispose()
$penCinnabar.Dispose()
$creamOnly.Dispose()
$fg.Save((Join-Path $Root 'foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$fg.Dispose()

$agcBmp = $preview.GetThumbnailImage($Agc, $Agc, $null, [IntPtr]::Zero)
$agcBmp.Save((Join-Path $Root 'agc-216.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$agcBmp.Dispose()
$preview.Dispose()
$mark.Dispose()
Write-Host 'OK rendered 文墨集 PNG masters'
