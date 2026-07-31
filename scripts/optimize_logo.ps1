# Reduce el peso del PNG del logo posterizando canales RGB y normalizando los pixeles
# totalmente transparentes. Mantiene el alfa suave (bordes sin dientes de sierra).
# Uso: pwsh -File scripts/optimize_logo.ps1 -Levels 16
param(
  [string]$Path = "",
  [int]$Levels = 16
)

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($Path)) { $Path = Join-Path $root "assets\logo-slat.png" }

$before = (Get-Item $Path).Length

$orig = [System.Drawing.Bitmap]::FromFile($Path)
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

$step = [int]([Math]::Round(255 / ($Levels - 1)))

for ($y = 0; $y -lt $h; $y++) {
  $rowBase = $y * $data.Stride
  for ($x = 0; $x -lt $w; $x++) {
    $i = $rowBase + $x * 4
    $a = $buf[$i+3]
    if ($a -eq 0) {
      # Pixel invisible: color uniforme -> comprime mucho mejor
      $buf[$i] = 0; $buf[$i+1] = 0; $buf[$i+2] = 0
      continue
    }
    # Posteriza BGR a $Levels niveles por canal
    for ($c = 0; $c -lt 3; $c++) {
      $v = [int]$buf[$i+$c]
      $q = [int]([Math]::Round($v / $step)) * $step
      if ($q -gt 255) { $q = 255 }
      $buf[$i+$c] = [byte]$q
    }
  }
}

[System.Runtime.InteropServices.Marshal]::Copy($buf, 0, $data.Scan0, $bytes)
$bmp.UnlockBits($data)

$bmp.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()

$after = (Get-Item $Path).Length
Write-Output ("{0}x{1}  {2} -> {3} bytes  ({4}% menos, {5} niveles)" -f $w, $h, $before, $after, [int]((1 - $after/$before) * 100), $Levels)
