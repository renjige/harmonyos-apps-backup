Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $MyInvocation.MyCommand.Path
$master = 1024
$agc = 216
$navy = [System.Drawing.Color]::FromArgb(255, 27, 39, 68)
$cream = [System.Drawing.Color]::FromArgb(255, 246, 245, 242)
$blue = [System.Drawing.Color]::FromArgb(255, 76, 126, 212)
$muted = [System.Drawing.Color]::FromArgb(255, 138, 147, 163)

function New-RoundRectPath([float]$x, [float]$y, [float]$w, [float]$h, [float]$r) {
  $p = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $p.AddArc($x, $y, $d, $d, 180, 90)
  $p.AddArc($x + $w - $d, $y, $d, $d, 270, 90)
  $p.AddArc($x + $w - $d, $y + $h - $d, $d, $d, 0, 90)
  $p.AddArc($x, $y + $h - $d, $d, $d, 90, 90)
  $p.CloseFigure()
  return $p
}

$bmp = New-Object System.Drawing.Bitmap $master, $master
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::Transparent)
$tile = New-RoundRectPath 0 0 $master $master 220
$g.FillPath((New-Object System.Drawing.SolidBrush $navy), $tile)
$g.FillPath((New-Object System.Drawing.SolidBrush $cream), (New-RoundRectPath 392 236 36 552 18))
$g.FillEllipse((New-Object System.Drawing.SolidBrush $cream), 376, 298, 68, 68)
$g.FillEllipse((New-Object System.Drawing.SolidBrush $blue), 382, 504, 56, 56)
$g.FillEllipse((New-Object System.Drawing.SolidBrush $cream), 394, 516, 32, 32)
$g.FillEllipse((New-Object System.Drawing.SolidBrush $cream), 376, 690, 68, 68)
$g.FillPath((New-Object System.Drawing.SolidBrush $cream), (New-RoundRectPath 500 430 268 196 36))
$g.FillPath((New-Object System.Drawing.SolidBrush $navy), (New-RoundRectPath 536 486 148 18 9))
$g.FillPath((New-Object System.Drawing.SolidBrush $muted), (New-RoundRectPath 536 532 96 14 7))
$g.Dispose()

$preview = Join-Path $root 'preview-1024.png'
$fg = Join-Path $root 'foreground.png'
$bg = Join-Path $root 'background.png'
$agcPath = Join-Path $root 'agc-216.png'
$bmp.Save($preview, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Save($fg, [System.Drawing.Imaging.ImageFormat]::Png)

$bgBmp = New-Object System.Drawing.Bitmap $master, $master
$bgG = [System.Drawing.Graphics]::FromImage($bgBmp)
$bgG.Clear($cream)
$bgG.Dispose()
$bgBmp.Save($bg, [System.Drawing.Imaging.ImageFormat]::Png)
$bgBmp.Dispose()

$agcBmp = New-Object System.Drawing.Bitmap $agc, $agc
$agcG = [System.Drawing.Graphics]::FromImage($agcBmp)
$agcG.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$agcG.DrawImage($bmp, 0, 0, $agc, $agc)
$agcG.Dispose()
$agcBmp.Save($agcPath, [System.Drawing.Imaging.ImageFormat]::Png)
$agcBmp.Dispose()

$board = New-Object System.Drawing.Bitmap 1280, 360
$bg2 = [System.Drawing.Graphics]::FromImage($board)
$bg2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$bg2.Clear($cream)
$bg2.DrawImage($bmp, 48, 36, 288, 288)
$fontFamily = New-Object System.Drawing.FontFamily 'Microsoft YaHei UI'
try {
  $font = New-Object System.Drawing.Font $fontFamily, 42, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel
} catch {
  $font = New-Object System.Drawing.Font ([System.Drawing.FontFamily]::GenericSansSerif), 42, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel
}
$font2 = New-Object System.Drawing.Font ([System.Drawing.FontFamily]::GenericSerif), 18, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel
$bg2.DrawString('行程备忘', $font, (New-Object System.Drawing.SolidBrush $navy), 372, 108)
$bg2.DrawString('Itinerary Memo', $font2, (New-Object System.Drawing.SolidBrush $muted), 372, 210)
$bg2.Dispose()
$board.Save((Join-Path $root 'logo-horizontal.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$board.Dispose()
$bmp.Dispose()
Write-Output 'logo rendered'
