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

The experience component aligns each logo with the first line of the bold
organization name. An unadorned 44 × 22 CSS-pixel layout slot keeps text columns
aligned; it has no background or border. Logos retain their original proportions:

- Default emblems and vertical marks fit within 22 × 22 pixels.
- `logo_variant: wordmark` fits horizontal lettering within 44 × 18 pixels.
- `logo_variant: symbol` fits dense geometric marks within 30 × 20 pixels.

Set the optional variant on the education or experience item in
`_data/profile.yml`. Keep logos aligned to the title's first line on mobile as
well, rather than centering them across the entire title and role. Do not stretch
a wordmark into a square or crop its letters to match an emblem.
