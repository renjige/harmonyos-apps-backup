# Rasterize 筑科隐患排查 mark with System.Drawing (no Python).
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$Master = 1024
$Agc = 216

function New-RoundedRectPath([int]$X, [int]$Y, [int]$W, [int]$H, [int]$R) {
  $path = New-Object System.Drawing.Drawing2D.GraphicsPath
  $d = $R * 2
  $path.AddArc($X, $Y, $d, $d, 180, 90)
  $path.AddArc($X + $W - $d, $Y, $d, $d, 270, 90)
  $path.AddArc($X + $W - $d, $Y + $H - $d, $d, $d, 0, 90)
  $path.AddArc($X, $Y + $H - $d, $d, $d, 90, 90)
  $path.CloseFigure()
  return $path
}

function New-Mark([int]$Size) {
  $bmp = New-Object System.Drawing.Bitmap $Size, $Size
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
  $g.Clear([System.Drawing.Color]::FromArgb(255, 22, 50, 79))

  $k = $Size / 1024.0
  $navy = [System.Drawing.Color]::FromArgb(255, 22, 50, 79)
  $fg = [System.Drawing.Color]::FromArgb(255, 244, 247, 250)
  $orange = [System.Drawing.Color]::FromArgb(255, 242, 140, 40)
  $brushFg = New-Object System.Drawing.SolidBrush $fg
  $pen = New-Object System.Drawing.Pen $orange, (92 * $k)
  $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
  $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round

  $board = New-RoundedRectPath 0 0 ($Size - 1) ($Size - 1) ([int](220 * $k))
  $brushN = New-Object System.Drawing.SolidBrush $navy
  $g.FillPath($brushN, $board)

  $slabs = @(
    @(268, 248, 488, 92, 20),
    @(268, 372, 488, 92, 20),
    @(268, 496, 488, 92, 20),
    @(300, 608, 88, 168, 18),
    @(636, 608, 88, 168, 18)
  )
  foreach ($s in $slabs) {
    $p = New-RoundedRectPath ([int]($s[0] * $k)) ([int]($s[1] * $k)) ([int]($s[2] * $k)) ([int]($s[3] * $k)) ([int]($s[4] * $k))
    $g.FillPath($brushFg, $p)
    $p.Dispose()
  }

  $g.DrawLines($pen, @(
    (New-Object System.Drawing.PointF (430 * $k), (700 * $k)),
    (New-Object System.Drawing.PointF (520 * $k), (800 * $k)),
    (New-Object System.Drawing.PointF (760 * $k), (500 * $k))
  ))

  $g.Dispose()
  $brushFg.Dispose()
  $brushN.Dispose()
  $pen.Dispose()
  $board.Dispose()
  return $bmp
}

$mark = New-Mark $Master
$preview = New-Object System.Drawing.Bitmap $Master, $Master
$pg = [System.Drawing.Graphics]::FromImage($preview)
$pg.Clear([System.Drawing.Color]::FromArgb(255, 22, 50, 79))
[void]$pg.DrawImageUnscaled($mark, 0, 0)
$pg.Dispose()
$preview.Save((Join-Path $Root 'preview-1024.png'), [System.Drawing.Imaging.ImageFormat]::Png)

$bg = New-Object System.Drawing.Bitmap $Master, $Master
$bgG = [System.Drawing.Graphics]::FromImage($bg)
$bgG.Clear([System.Drawing.Color]::FromArgb(255, 22, 50, 79))
$bgG.Dispose()
$bg.Save((Join-Path $Root 'background.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$bg.Dispose()

$mark.Save((Join-Path $Root 'foreground.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$mark.Dispose()

$agcBmp = $preview.GetThumbnailImage($Agc, $Agc, $null, [IntPtr]::Zero)
$agcBmp.Save((Join-Path $Root 'agc-216.png'), [System.Drawing.Imaging.ImageFormat]::Png)
$agcBmp.Dispose()
$preview.Dispose()
Write-Host 'OK rendered PNG masters for Zhuke hazard inspect'
