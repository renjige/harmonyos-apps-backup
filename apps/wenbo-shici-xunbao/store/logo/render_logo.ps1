Add-Type -AssemblyName System.Drawing

$root = 'E:\huawei001-master\apps\wenbo-shici-xunbao\store\logo'
$master = 1024
$ink = [System.Drawing.Color]::FromArgb(26, 26, 46)
$gold = [System.Drawing.Color]::FromArgb(201, 168, 76)

function Get-CjkFont([int]$size) {
  $names = @('SimSun', 'NSimSun', 'Microsoft YaHei', 'SimHei', 'KaiTi')
  foreach ($n in $names) {
    try {
      return New-Object System.Drawing.Font $n, $size, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
    } catch { }
  }
  return New-Object System.Drawing.Font 'Microsoft YaHei', $size, ([System.Drawing.FontStyle]::Bold), ([System.Drawing.GraphicsUnit]::Pixel)
}

function Draw-Mark([System.Drawing.Bitmap]$bmp, [bool]$transparent) {
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
  $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
  if (-not $transparent) {
    $g.Clear($ink)
  } else {
    $g.Clear([System.Drawing.Color]::Transparent)
  }
  $penW = [Math]::Max(4, [int](28 * $bmp.Width / 1024))
  $pen = New-Object System.Drawing.Pen $gold, $penW
  $pad = [int](196 * $bmp.Width / 1024)
  $g.DrawRectangle($pen, $pad, $pad, $bmp.Width - 2 * $pad, $bmp.Height - 2 * $pad)
  $pen2 = New-Object System.Drawing.Pen $gold, ([Math]::Max(2, [int](8 * $bmp.Width / 1024)))
  $inner = [int](236 * $bmp.Width / 1024)
  $g.DrawRectangle($pen2, $inner, $inner, $bmp.Width - 2 * $inner, $bmp.Height - 2 * $inner)
  $font = Get-CjkFont ([int](360 * $bmp.Width / 1024))
  $brush = New-Object System.Drawing.SolidBrush $gold
  $sf = New-Object System.Drawing.StringFormat
  $sf.Alignment = [System.Drawing.StringAlignment]::Center
  $sf.LineAlignment = [System.Drawing.StringAlignment]::Center
  $rect = New-Object System.Drawing.RectangleF 0, 0, $bmp.Width, $bmp.Height
  $g.DrawString([char]0x8BD7, $font, $brush, $rect, $sf)
  $cx = [int](760 * $bmp.Width / 1024)
  $cy = [int](268 * $bmp.Height / 1024)
  $pts = @(
    (New-Object System.Drawing.Point ($cx), ($cy)),
    (New-Object System.Drawing.Point ($cx + [int](36 * $bmp.Width / 1024)), ($cy - [int](36 * $bmp.Height / 1024))),
    (New-Object System.Drawing.Point ($cx + [int](16 * $bmp.Width / 1024)), ($cy + [int](12 * $bmp.Height / 1024)))
  )
  $g.FillPolygon($brush, $pts)
  $g.Dispose()
  $pen.Dispose()
  $pen2.Dispose()
  $brush.Dispose()
  $font.Dispose()
}

$preview = New-Object System.Drawing.Bitmap $master, $master
Draw-Mark $preview $false
$preview.Save("$root\preview-1024.png", [System.Drawing.Imaging.ImageFormat]::Png)

$bg = New-Object System.Drawing.Bitmap $master, $master
$gb = [System.Drawing.Graphics]::FromImage($bg)
$gb.Clear($ink)
$gb.Dispose()
$bg.Save("$root\background.png", [System.Drawing.Imaging.ImageFormat]::Png)

$fg = New-Object System.Drawing.Bitmap $master, $master, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
Draw-Mark $fg $true
$fg.Save("$root\foreground.png", [System.Drawing.Imaging.ImageFormat]::Png)

$agc = $preview.GetThumbnailImage(216, 216, $null, [IntPtr]::Zero)
$agc.Save("$root\agc-216.png", [System.Drawing.Imaging.ImageFormat]::Png)

$preview.Dispose(); $bg.Dispose(); $fg.Dispose(); $agc.Dispose()
Write-Output 'OK logo png'
