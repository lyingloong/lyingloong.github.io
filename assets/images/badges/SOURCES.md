# Badge asset sources

## New Oriental

- Official website: https://www.xdf.cn/
- Original logo asset used by the website header: https://g.xdfimage.cn/upload/6ab4049371e1a99ecbfc1c9c051587a2.png
- Local file: `new-oriental.png`
- Format and dimensions: PNG, 240 × 94 pixels, RGBA.
- Downloaded on 2026-11-06. The original image is preserved without cropping, recoloring, or resizing.

## Optically balanced derivatives

The files under `normalized/` are derived from the matching original files in
this directory. All originals are retained. Each derivative uses a transparent
192 × 128 pixel canvas, intended to display at 48 × 32 CSS pixels (4× assets).

Processing on 2026-11-06:

1. Remove transparent outer padding and connected near-white outer background
   (RGB channels >= 245), while preserving enclosed white details.
2. Crop to the full visible mark, without cutting lettering or changing colors.
3. Resize proportionally with Lanczos filtering and center on the common canvas.
4. Adjust the occupied area for each mark's proportions and visual density.

| File in `normalized/` | Original crop (left, top, right, bottom) | Visible output size | Visible size at 48 × 32 CSS pixels |
| --- | --- | --- | --- |
| `USTC_blue.png` | 0, 0, 96, 96 | 112 × 112 | 28 × 28 |
| `spikecv.png` | 10, 0, 117, 127 | 94 × 112 | 23.5 × 28 |
| `lingxin_logo.png` | 6, 33, 121, 93 | 152 × 79 | 38 × 19.75 |
| `cambricon.png` | 0, 42, 128, 86 | 192 × 66 | 48 × 16.5 |
| `new-oriental.png` | 5, 3, 232, 93 | 168 × 67 | 42 × 16.75 |

The USTC, SpikeCV, Lingxin, and Cambricon originals were already present in this
repository; this change does not establish new external source claims for them.
The New Oriental original is sourced from its official website as recorded above.
