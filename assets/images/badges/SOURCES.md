# Badge asset sources

## New Oriental

- Official website: https://www.xdf.cn/
- Original logo asset used by the website header: https://g.xdfimage.cn/upload/6ab4049371e1a99ecbfc1c9c051587a2.png
- Local file: `new-oriental.png`
- Format and dimensions: PNG, 240 × 94 pixels, RGBA.
- Downloaded on 2026-11-06. The original image is preserved without cropping, recoloring, or resizing.

## Display assets

The files under `normalized/` are derived from the matching original files in
this directory. All originals are retained. The USTC, SpikeCV, Lingxin, and
Cambricon originals were already present in this repository; this change does
not establish new external source claims for them.

Processing on 2026-11-06:

1. Remove transparent outer padding and connected near-white outer background
   (RGB channels >= 245), preserving enclosed white details and all lettering.
2. Resize proportionally with Lanczos filtering, retaining the original colors.
3. Crop the derivative canvas to the complete visible mark. Derivative images
   deliberately have different dimensions and aspect ratios.

The experience component supplies the consistent visual boundary: a 52 × 52
CSS-pixel square with a quiet background and border. Inside it, each complete
mark fits within 36 × 28 pixels without distortion. Circular marks occupy about
28 × 28 pixels; horizontal wordmarks use up to 36 pixels of width. The frame,
centering, and surrounding whitespace provide consistency across those shapes.
Do not stretch a wordmark into a square or crop its letters to match an emblem.
