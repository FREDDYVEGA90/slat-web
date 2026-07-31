Add-Type -AssemblyName System.Drawing
$root = Split-Path -Parent $PSScriptRoot
$src = Join-Path $root "assets\logo-slat.png"
$targetWidth = 640

$orig = [System.Drawing.Bitmap]::FromFile($src)
$ratio = $targetWidth / $orig.Width
$targetHeight = [int]([Math]::Round($orig.Height * $ratio))

$bmp = New-Object System.Drawing.Bitmap $targetWidth, $targetHeight, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.DrawImage($orig, 0, 0, $targetWidth, $targetHeight)
$g.Dispose()
$orig.Dispose()

$bmp.Save($src, [System.Drawing.Imaging.ImageFormat]::Png)
$bmp.Dispose()
Write-Output ("Resized -> {0}x{1}" -f $targetWidth, $targetHeight)
