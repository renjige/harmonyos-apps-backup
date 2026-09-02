# Rasterize 知微集 insight-eye mark (no Python).
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Master = 1024
$Agc = 216
$Ink = [System.Drawing.Color]::FromArgb(255, 26, 26, 46)
$Ivory = [System.Drawing.Color]::FromArgb(255, 245, 247, 250)
$Page = [System.Drawing.Color]::FromArgb(255, 245, 247, 250)

function New-Mark([int]$Size, [bool]$Transparent) {
  $bmp = New-Object System.Drawing.Bitmap $Size, $Size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  if ($Transparent) {
    $g.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
  } else {
    $g.Clear($Ink)
  }
  $k = $Size / 1024.0
  $ringW = [Math]::Max(3, [int](22 * $k))
  $arcW = [Math]::Max(4, [int](28 * $k))
  $penRing = New-Object System.Drawing.Pen $Ivory, $ringW
  $penArc = New-Object System.Drawing.Pen $Ivory, $arcW
  $penArc.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $penArc.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $brush = New-Object System.Drawing.SolidBrush $Ivory

  $cx = [int](512 * $k)
  $cy = [int](512 * $k)
  $ringR = [int](292 * $k)
  $g.DrawEllipse($penRing, ($cx - $ringR), ($cy - $ringR), ($ringR * 2), ($ringR * 2))

  $eyeX = [int](268 * $k)
  $eyeW = [int](488 * $k)
  $upY = [int](338 * $k)
  $upH = [int](348 * $k)
  $g.DrawArc($penArc, $eyeX, $upY, $eyeW, $upH, 200, 140)
  $loY = [int](338 * $k)
  $g.DrawArc($penArc, $eyeX, $loY, $eyeW, $upH, 20, 140)

  $dotR = [int](42 * $k)
  $g.FillEllipse($brush, ($cx - $dotR), ($cy - $dotR), ($dotR * 2), ($dotR * 2))

  $g.Dispose()
  $penRing.Dispose()
  $penArc.Dispose()
  $brush.Dispose()
  return $bmp
}

$preview = New-Mark $Master $false
$preview.Save((Join-Path $Root 'preview-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear($Ink)
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
$bg2.Clear($Page)
$bg2.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$icon = New-Mark 288 $false
$bg2.DrawImage($icon, 48, 36, 288, 288)
$icon.Dispose()
$font = New-Object System.Drawing.Font 'Microsoft YaHei', 42, ([System.Drawing.FontStyle]::Bold)
$sub = New-Object System.Drawing.Font 'Microsoft YaHei', 14, ([System.Drawing.FontStyle]::Regular)
$brushInk = New-Object System.Drawing.SolidBrush $Ink
$brushMute = New-Object System.Drawing.SolidBrush ([System.Drawing.Color]::FromArgb(255, 74, 74, 106))
$titleText = [string]::Concat([char]0x77E5, [char]0x5FAE, [char]0x96C6)
$subText = 'ZhiWeiJi'
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
