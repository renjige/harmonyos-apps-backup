# Rasterize 悠隅纪 window-corner mark (no Python).
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Master = 1024
$Agc = 216
$Walnut = [System.Drawing.Color]::FromArgb(255, 61, 43, 31)
$Apricot = [System.Drawing.Color]::FromArgb(255, 212, 165, 116)
$Cream = [System.Drawing.Color]::FromArgb(255, 244, 230, 212)
$Ivory = [System.Drawing.Color]::FromArgb(255, 249, 246, 240)
$Ink = [System.Drawing.Color]::FromArgb(255, 61, 43, 31)

function New-Mark([int]$Size, [bool]$Transparent) {
  $bmp = New-Object System.Drawing.Bitmap $Size, $Size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  if ($Transparent) {
    $g.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
  } else {
    $g.Clear($Walnut)
  }
  $k = $Size / 1024.0
  $penW = [Math]::Max(4, [int](36 * $k))
  $mullionW = [Math]::Max(3, [int](28 * $k))
  $pen = New-Object System.Drawing.Pen $Apricot, $penW
  $mullion = New-Object System.Drawing.Pen $Apricot, $mullionW
  $brushC = New-Object System.Drawing.SolidBrush $Cream
  $brushW = New-Object System.Drawing.SolidBrush $Walnut

  if ($Transparent) {
    $g.FillRectangle($brushW, 0, 0, $Size, $Size)
  }

  $x = [int](268 * $k)
  $y = [int](268 * $k)
  $w = [int](488 * $k)
  $h = [int](488 * $k)
  $r = [int](56 * $k)
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $r * 2
  $path.AddArc($x, $y, $d, $d, 180, 90)
  $path.AddArc(($x + $w - $d), $y, $d, $d, 270, 90)
  $path.AddArc(($x + $w - $d), ($y + $h - $d), $d, $d, 0, 90)
  $path.AddArc($x, ($y + $h - $d), $d, $d, 90, 90)
  $path.CloseFigure()
  $g.DrawPath($pen, $path)

  $cx = [int](512 * $k)
  $cy = [int](512 * $k)
  $g.DrawLine($mullion, $cx, [int](286 * $k), $cx, [int](738 * $k))
  $g.DrawLine($mullion, [int](286 * $k), $cy, [int](738 * $k), $cy)

  $tri = @(
    (New-Object System.Drawing.PointF ([single](540 * $k)), ([single](286 * $k))),
    (New-Object System.Drawing.PointF ([single](738 * $k)), ([single](286 * $k))),
    (New-Object System.Drawing.PointF ([single](738 * $k)), ([single](430 * $k)))
  )
  $g.FillPolygon($brushC, $tri)

  $g.Dispose()
  $pen.Dispose()
  $mullion.Dispose()
  $brushC.Dispose()
  $brushW.Dispose()
  $path.Dispose()
  return $bmp
}

$preview = New-Mark $Master $false
$preview.Save((Join-Path $Root 'preview-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear($Walnut)
$bgG.Dispose()
$bg.Save((Join-Path $Root 'background.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bg.Dispose()

$fg = New-Mark $Master $true
$fg.Save((Join-Path $Root 'foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$fg.Dispose()

$agc = $preview.GetThumbnailImage($Agc, $Agc, $null, [IntPtr]::Zero)
$agc.Save((Join-Path $Root 'agc-216.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$agc.Dispose()

$board = New-Object System.Drawing.Bitmap 1280, 360
$bg2 = [System.Drawing.Graphics]::FromImage($board)
$bg2.Clear($Ivory)
$bg2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$icon = New-Mark 288 $false
$bg2.DrawImage($icon, 48, 36, 288, 288)
$icon.Dispose()
$font = New-Object System.Drawing.Font 'Microsoft YaHei', 42, ([System.Drawing.FontStyle]::Bold)
$sub = New-Object System.Drawing.Font 'Microsoft YaHei', 14, ([System.Drawing.FontStyle]::Regular)
$brushInk = New-Object System.Drawing.SolidBrush $Ink
$brushMute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 107, 100, 92))
$titleText = [string]::Concat([char]0x60A0, [char]0x9685, [char]0x7EAA)
$subText = 'Quiet Corner Journal'
$bg2.DrawString($titleText, $font, $brushInk, 380, 88)
$bg2.DrawString($subText, $sub, $brushMute, 380, 210)
$board.Save((Join-Path $Root 'logo-horizontal.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bg2.Dispose()
$board.Dispose()
$preview.Dispose()
$font.Dispose()
$sub.Dispose()
$brushInk.Dispose()
$brushMute.Dispose()
Write-Host 'OK rendered PNG masters'
