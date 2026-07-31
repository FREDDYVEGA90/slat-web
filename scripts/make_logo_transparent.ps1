# Genera assets/logo-slat.png con fondo transparente a partir de "Logo SLAT.png".
# Vuelve transparentes los pixeles casi-blancos y recorta el margen sobrante.
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$src  = Join-Path $root "Logo SLAT.png"
$outDir = Join-Path $root "assets"
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }
$out = Join-Path $outDir "logo-slat.png"

$threshold = 238

$orig = [System.Drawing.Bitmap]::FromFile($src)
$bmp  = New-Object System.Drawing.Bitmap $orig.Width, $orig.Height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($orig, 0, 0, $orig.Width, $orig.Height)
$g.Dispose()
$orig.Dispose()

$w = $bmp.Width; $h = $bmp.Height
$rect = New-Object System.Drawing.Rectangle 0, 0, $w, $h
$data = $bmp.LockBits($rect, [System.Drawing.Imaging.ImageLockMode]::ReadWrite, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$bytes = $w * $h * 4
$buf = New-Object byte[] $bytes
[System.Runtime.InteropServices.Marshal]::Copy($data.Scan0, $buf, 0, $bytes)

$minX = $w; $minY = $h; $maxX = -1; $maxY = -1
for ($y = 0; $y -lt $h; $y++) {
  $rowBase = $y * $data.Stride
  for ($x = 0; $x -lt $w; $x++) {
    $i = $rowBase + $x * 4
    # orden BGRA
    $b = $buf[$i]; $gr = $buf[$i+1]; $r = $buf[$i+2]
    if ($b -ge $threshold -and $gr -ge $threshold -and $r -ge $threshold) {
      $buf[$i+3] = 0
    } else {
      if ($x -lt $minX) { $minX = $x }
      if ($x -gt $maxX) { $maxX = $x }
      if ($y -lt $minY) { $minY = $y }
      if ($y -gt $maxY) { $maxY = $y }
    }
  }
}

[System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $data.Scan0, $bytes)
$bmp.UnlockBits($data)

if ($maxX -lt 0) { $minX = 0; $minY = 0; $maxX = $w - 1; $maxY = $h - 1 }
$pad = 6
$minX = [Math]::Max(0, $minX - $pad); $minY = [Math]::Max(0, $minY - $pad)
$maxX = [Math]::Min($w - 1, $maxX + $pad); $maxY = [Math]::Min($h - 1, $maxY + $pad)
$cw = $maxX - $minX + 1; $ch = $maxY - $minY + 1

$cropRect = New-Object System.Drawing.Rectangle $minX, $minY, $cw, $ch
$cropped = $bmp.Clone($cropRect, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$cropped.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)

Write-Output ("OK -> {0}  ({1}x{2})" -f $out, $cw, $ch)
$cropped.Dispose(); $bmp.Dispose()
