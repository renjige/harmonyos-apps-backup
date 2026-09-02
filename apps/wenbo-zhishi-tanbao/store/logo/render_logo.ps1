# 知识探宝 — 宝藏罗盘 Logo 栅格化（System.Drawing）
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$AppScope = Join-Path $Root '../../app/AppScope/resources/base/media'
$EntryMedia = Join-Path $Root '../../app/entry/src/main/resources/base/media'
$Master = 1024

function New-TreasureMark([int]$Size) {
  $bmp = New-Object System.Drawing.Bitmap $Size, $Size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))

  $k = $Size / 1024.0
  $navy = [System.Drawing.Color]::FromArgb(255, 26, 42, 108)
  $navyDeep = [System.Drawing.Color]::FromArgb(255, 15, 22, 56)
  $gold = [System.Drawing.Color]::FromArgb(255, 201, 168, 76)
  $goldLight = [System.Drawing.Color]::FromArgb(255, 240, 208, 128)

  $brushN = New-Object System.Drawing.SolidBrush $navy
  $brushGold = New-Object System.Drawing.SolidBrush $gold
  $brushGoldL = New-Object System.Drawing.SolidBrush $goldLight
  $penGold = New-Object System.Drawing.Pen $gold, (22 * $k)
  $penGoldL = New-Object System.Drawing.Pen $goldLight, (14 * $k)
  $penGold.Width = 22 * $k
  $penGoldL.Width = 14 * $k
  $penGold.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $penGold.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $penGoldL.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $penGoldL.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

  # 背景圆盘（仅用于 preview 合成；foreground 透明）
  $cx = 512 * $k
  $cy = 512 * $k

  # 外圈罗盘
  $g.DrawEllipse($penGoldL, (232 * $k), (232 * $k), (560 * $k), (560 * $k))
  $g.DrawLine($penGoldL, (512 * $k), (280 * $k), (512 * $k), (744 * $k))
  $g.DrawLine($penGoldL, (280 * $k), (512 * $k), (744 * $k), (512 * $k))

  # 指针三角
  $needle = New-Object System.Drawing.Drawing2D.GraphicsPath
  $needle.AddPolygon(@(
    (New-Object System.Drawing.PointF (512 * $k), (248 * $k)),
    (New-Object System.Drawing.PointF (548 * $k), (312 * $k)),
    (New-Object System.Drawing.PointF (476 * $k), (312 * $k))
  ))
  $g.FillPath($brushGoldL, $needle)

  # 宝箱盖
  $lidPath = New-Object System.Drawing.Drawing2D.GraphicsPath
  $lidPath.AddPolygon(@(
    (New-Object System.Drawing.PointF (404 * $k), (560 * $k)),
    (New-Object System.Drawing.PointF (620 * $k), (560 * $k)),
    (New-Object System.Drawing.PointF (512 * $k), (480 * $k))
  ))
  $g.FillPath($brushGold, $lidPath)

  # 箱体
  $g.FillRectangle($brushGold, (460 * $k), (560 * $k), (104 * $k), (120 * $k))

  # 锁扣
  $g.FillEllipse($brushGoldL, (496 * $k), (592 * $k), (32 * $k), (32 * $k))

  $g.Dispose()
  $brushN.Dispose()
  $brushGold.Dispose()
  $brushGoldL.Dispose()
  $penGold.Dispose()
  $penGoldL.Dispose()
  $needle.Dispose()
  $lidPath.Dispose()
  return $bmp
}

function Save-Bmp($bmp, $path) {
  $dir = Split-Path $path -Parent
  if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
}

$fg = New-TreasureMark $Master

# preview / app_icon：深海蓝底 + 前景
$preview = New-Object System.Drawing.Bitmap $Master, $Master
$pg = [System.Drawing.Graphics]::FromImage($preview)
$pg.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$pg.Clear([System.Drawing.Color]::FromArgb(255, 26, 42, 108))
[void]$pg.DrawImageUnscaled($fg, 0, 0)
$pg.Dispose()

Save-Bmp $preview (Join-Path $Root 'preview-1024.png')
Save-Bmp $preview (Join-Path $Root 'app_icon.png')
Save-Bmp $fg (Join-Path $Root 'foreground.png')

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear([System.Drawing.Color]::FromArgb(255, 26, 42, 108))
$bgG.Dispose()
Save-Bmp $bg (Join-Path $Root 'background.png')
$bg.Dispose()

Save-Bmp $preview (Join-Path $AppScope 'app_icon.png')

$icon256 = $preview.GetThumbnailImage(256, 256, $null, [IntPtr]::Zero)
Save-Bmp $icon256 (Join-Path $EntryMedia 'icon.png')
Save-Bmp $icon256 (Join-Path $EntryMedia 'startIcon.png')
Save-Bmp ($preview.GetThumbnailImage(128, 128, $null, [IntPtr]::Zero)) (Join-Path $EntryMedia 'app_logo.png')
$icon256.Dispose()
$preview.Dispose()
$fg.Dispose()

Write-Host 'OK 知识探宝 Logo -> preview-1024 / app_icon / icon / startIcon / app_logo'
