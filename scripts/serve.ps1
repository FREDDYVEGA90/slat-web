# Servidor estatico minimo para previsualizar el sitio (sin dependencias).
param([int]$Port = 5511)

$root = Split-Path -Parent $PSScriptRoot
$prefix = "http://localhost:$Port/"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefix)
$listener.Start()
Write-Output "Serving $root at $prefix"

$mime = @{
  ".html" = "text/html; charset=utf-8"; ".css" = "text/css; charset=utf-8";
  ".js" = "application/javascript; charset=utf-8"; ".png" = "image/png";
  ".jpg" = "image/jpeg"; ".jpeg" = "image/jpeg"; ".svg" = "image/svg+xml";
  ".ico" = "image/x-icon"; ".json" = "application/json; charset=utf-8";
  ".webp" = "image/webp"; ".woff2" = "font/woff2"
}

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $rel = [System.Uri]::UnescapeDataString($ctx.Request.Url.AbsolutePath.TrimStart("/"))
    if ([string]::IsNullOrWhiteSpace($rel)) { $rel = "index.html" }
    $path = Join-Path $root $rel
    if (Test-Path $path -PathType Container) { $path = Join-Path $path "index.html" }

    if (Test-Path $path -PathType Leaf) {
      $ext = [System.IO.Path]::GetExtension($path).ToLower()
      $ct = $mime[$ext]; if (-not $ct) { $ct = "application/octet-stream" }
      $bytes = [System.IO.File]::ReadAllBytes($path)
      $ctx.Response.ContentType = $ct
      $ctx.Response.ContentLength64 = $bytes.Length
      $ctx.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $ctx.Response.StatusCode = 404
      $msg = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found: $rel")
      $ctx.Response.OutputStream.Write($msg, 0, $msg.Length)
    }
    $ctx.Response.OutputStream.Close()
  } catch {
    # continuar sirviendo
  }
}
