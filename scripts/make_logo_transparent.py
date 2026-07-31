"""Genera una version con fondo transparente del logo de SLAT.

Toma 'Logo SLAT.png' (fondo blanco) y convierte a transparente todos los
pixeles casi-blancos, recortando ademas el espacio en blanco sobrante.
Salida: assets/logo-slat.png
"""
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parent.parent
SRC = ROOT / "Logo SLAT.png"
OUT = ROOT / "assets" / "logo-slat.png"
OUT.parent.mkdir(parents=True, exist_ok=True)

THRESHOLD = 238  # pixeles con R,G,B por encima de esto se vuelven transparentes

img = Image.open(SRC).convert("RGBA")
px = img.load()
w, h = img.size

for y in range(h):
    for x in range(w):
        r, g, b, a = px[x, y]
        if r >= THRESHOLD and g >= THRESHOLD and b >= THRESHOLD:
            px[x, y] = (r, g, b, 0)

# Recorte al contenido visible (bounding box del canal alfa)
bbox = img.getbbox()
if bbox:
    img = img.crop(bbox)

img.save(OUT)
print(f"OK -> {OUT}  ({img.size[0]}x{img.size[1]})")
