$dir = Split-Path -Parent $MyInvocation.MyCommand.Path
$svg = Join-Path $dir "symbol.svg"
$preview = Join-Path $dir "preview-1024.png"
$fg = Join-Path $dir "foreground.png"
$bg = Join-Path $dir "background.png"
$agc = Join-Path $dir "agc-216.png"

# Use magick if available, else copy placeholder from node script
if (Get-Command magick -ErrorAction SilentlyContinue) {
  magick -background none -density 300 $svg -resize 1024x1024 $preview
  magick $preview -resize 1024x1024 $fg
  magick -size 1024x1024 xc:"#2D4A3E" $bg
  magick $preview -resize 216x216 $agc
  Write-Host "Logo PNGs rendered via ImageMagick"
  exit 0
}

Write-Host "ImageMagick not found; run node render_logo.mjs fallback"
exit 1
