Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $PSScriptRoot

function Resize-Png($path, $targetWidth) {
  $orig = [System.Drawing.Bitmap]::FromFile($path)
  $ratio = $targetWidth / $orig.Width
  $targetHeight = [int]([Math]::Round($orig.Height * $ratio))
  $bmp = New-Object System.Drawing.Bitmap $targetWidth, $targetHeight, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($orig, 0, 0, $targetWidth, $targetHeight)
  $g.Dispose(); $orig.Dispose()
  $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
  $bmp.Dispose()
  Write-Output ("PNG {0} -> {1}x{2}" -f $path, $targetWidth, $targetHeight)
}

function Resize-Jpeg($path, $targetWidth, $quality) {
  $orig = [System.Drawing.Bitmap]::FromFile($path)
  $ratio = $targetWidth / $orig.Width
  $targetHeight = [int]([Math]::Round($orig.Height * $ratio))
  $bmp = New-Object System.Drawing.Bitmap $targetWidth, $targetHeight
  $g = [System.Drawing.Graphics]::FromImage($bmp)
  $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
  $g.DrawImage($orig, 0, 0, $targetWidth, $targetHeight)
  $g.Dispose(); $orig.Dispose()

  $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
  $params = New-Object System.Drawing.Imaging.EncoderParameters(1)
  $params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [int64]$quality)
  $bmp.Save($path, $codec, $params)
  $bmp.Dispose()
  Write-Output ("JPG {0} -> {1}x{2} q{3}" -f $path, $targetWidth, $targetHeight, $quality)
}

Resize-Png (Join-Path $root "assets\logo-slat.png") 420
Resize-Jpeg (Join-Path $root "assets\camaron.jpg") 640 72
Resize-Jpeg (Join-Path $root "assets\banano.jpg") 560 72
