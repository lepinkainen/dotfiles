# beui loaders — vanilla HTML/CSS/JS ports

Faithful ports of the beui `Loader` component (see `loader-source.tsx` for the React original).
Every snippet is framework-free: paste the HTML where the loader goes, the CSS once per page/stylesheet, and (for the three JS variants) the small init function.

## Contents

- [Shared base (required for all variants)](#shared-base)
- CSS-only: [spinner](#spinner) · [dots](#dots) · [bars](#bars) · [dot-matrix](#dot-matrix) · [dither](#dither) · [comet](#comet) · [newton](#newton) · [helix](#helix) · [metaballs](#metaballs) · [morph](#morph)
- JS-driven: [ascii (5 frame sets)](#ascii) · [scramble](#scramble) · [percent](#percent)

## Conventions

- **Size**: set `--size` on the root element (default `32px`). Every internal dimension derives from it, same scaling math as the original.
- **Speed**: set `--speed` (default `1s`) = seconds per animation cycle. Multipliers a variant applies internally (e.g. morph runs at `--speed * 5`) match the original.
- **Color**: everything paints with `currentColor` — set `color` on the loader or any ancestor.
- **Easing**: the original's `EASE_IN_OUT` is `cubic-bezier(0.77, 0, 0.175, 1)`, exposed as `--bl-ease`.
- **Class prefix**: all classes use a `bl-` prefix. Rename freely if it collides with the host project.
- **Accessibility**: the root carries `role="status"` and `aria-label`, so screen readers announce it. Decorative internals use `<i>` elements (no semantics needed) and SVGs are `aria-hidden`.

## Shared base

Required once, before any variant CSS:

```css
.bl {
  --size: 32px;
  --speed: 1s;
  --bl-ease: cubic-bezier(0.77, 0, 0.175, 1);
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: inherit;
}
@keyframes bl-rotate { to { transform: rotate(1turn); } }
@keyframes bl-fade { 0%, 100% { opacity: 1; } 50% { opacity: 0.4; } }

/* Reduced motion: drop every transform animation, keep a calm opacity pulse
   on the root — mirrors the original's REDUCED fallback. */
@media (prefers-reduced-motion: reduce) {
  .bl * { animation: none !important; }
  .bl { animation: bl-fade 1.4s var(--bl-ease) infinite; }
}
```

The JS variants handle reduced motion inside their init functions (slower cycle or static text), matching the original's behavior.

---

## Spinner

Track circle + quarter arc, linear rotation.

```html
<span class="bl bl-spinner" role="status" aria-label="Loading">
  <svg viewBox="0 0 32 32" aria-hidden="true">
    <circle cx="16" cy="16" r="14.5" fill="none" stroke="currentColor" stroke-opacity="0.2" stroke-width="3"/>
    <path d="M16 1.5 A14.5 14.5 0 0 1 30.5 16" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round"/>
  </svg>
</span>
```

```css
.bl-spinner svg {
  width: var(--size);
  height: var(--size);
  animation: bl-rotate var(--speed) linear infinite;
}
```

## Dots

Three dots bouncing with a stagger.

```html
<span class="bl bl-dots" role="status" aria-label="Loading"><i></i><i></i><i></i></span>
```

```css
.bl-dots { gap: calc(var(--size) * 0.14); }
.bl-dots i {
  width: calc(var(--size) * 0.24);
  height: calc(var(--size) * 0.24);
  border-radius: 50%;
  background: currentColor;
  animation: bl-dot var(--speed) var(--bl-ease) infinite;
}
.bl-dots i:nth-child(2) { animation-delay: calc(var(--speed) * 0.16); }
.bl-dots i:nth-child(3) { animation-delay: calc(var(--speed) * 0.32); }
@keyframes bl-dot {
  0%, 100% { transform: translateY(0); opacity: 0.5; }
  50% { transform: translateY(calc(var(--size) * -0.3)); opacity: 1; }
}
```

## Bars

Four bars pulsing scaleY from the bottom.

```html
<span class="bl bl-bars" role="status" aria-label="Loading"><i></i><i></i><i></i><i></i></span>
```

```css
.bl-bars { gap: calc(var(--size) * 0.1); height: var(--size); }
.bl-bars i {
  width: calc(var(--size) * 0.16);
  height: var(--size);
  border-radius: 999px;
  background: currentColor;
  transform-origin: center bottom;
  animation: bl-bar var(--speed) var(--bl-ease) infinite;
}
.bl-bars i:nth-child(2) { animation-delay: calc(var(--speed) * 0.12); }
.bl-bars i:nth-child(3) { animation-delay: calc(var(--speed) * 0.24); }
.bl-bars i:nth-child(4) { animation-delay: calc(var(--speed) * 0.36); }
@keyframes bl-bar {
  0%, 100% { transform: scaleY(0.3); }
  50% { transform: scaleY(1); }
}
```

## Dot-matrix

3×3 grid, diagonal wave (delay by distance from top-left corner).

```html
<span class="bl bl-matrix" role="status" aria-label="Loading">
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
</span>
```

```css
.bl-matrix {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: calc(var(--size) * 0.14);
  width: var(--size);
}
.bl-matrix i {
  aspect-ratio: 1;
  border-radius: 50%;
  background: currentColor;
  animation: bl-cell var(--speed) var(--bl-ease) infinite;
}
/* delay = (col + row) / 4 * speed */
.bl-matrix i:nth-child(2), .bl-matrix i:nth-child(4) { animation-delay: calc(var(--speed) * 0.25); }
.bl-matrix i:nth-child(3), .bl-matrix i:nth-child(5), .bl-matrix i:nth-child(7) { animation-delay: calc(var(--speed) * 0.5); }
.bl-matrix i:nth-child(6), .bl-matrix i:nth-child(8) { animation-delay: calc(var(--speed) * 0.75); }
.bl-matrix i:nth-child(9) { animation-delay: var(--speed); }
@keyframes bl-cell {
  0%, 100% { opacity: 0.2; transform: scale(0.7); }
  50% { opacity: 1; transform: scale(1); }
}
```

## Dither

4×4 grid, cells flash in ordered-Bayer-matrix order — dissolving halftone shimmer.
Delay for cell at index *i* (row-major) = `BAYER[i] / 16 * speed` with
`BAYER = [0,8,2,10, 12,4,14,6, 3,11,1,9, 15,7,13,5]`.

```html
<span class="bl bl-dither" role="status" aria-label="Loading">
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
  <i></i><i></i><i></i><i></i><i></i><i></i><i></i><i></i>
</span>
```

```css
.bl-dither {
  display: grid;
  grid-template-columns: repeat(4, 1fr);
  gap: max(1px, calc(var(--size) * 0.05));
  width: var(--size);
}
.bl-dither i {
  aspect-ratio: 1;
  background: currentColor;
  animation: bl-dith var(--speed) var(--bl-ease) infinite;
}
.bl-dither i:nth-child(1)  { animation-delay: 0s; }
.bl-dither i:nth-child(2)  { animation-delay: calc(var(--speed) * 0.5); }
.bl-dither i:nth-child(3)  { animation-delay: calc(var(--speed) * 0.125); }
.bl-dither i:nth-child(4)  { animation-delay: calc(var(--speed) * 0.625); }
.bl-dither i:nth-child(5)  { animation-delay: calc(var(--speed) * 0.75); }
.bl-dither i:nth-child(6)  { animation-delay: calc(var(--speed) * 0.25); }
.bl-dither i:nth-child(7)  { animation-delay: calc(var(--speed) * 0.875); }
.bl-dither i:nth-child(8)  { animation-delay: calc(var(--speed) * 0.375); }
.bl-dither i:nth-child(9)  { animation-delay: calc(var(--speed) * 0.1875); }
.bl-dither i:nth-child(10) { animation-delay: calc(var(--speed) * 0.6875); }
.bl-dither i:nth-child(11) { animation-delay: calc(var(--speed) * 0.0625); }
.bl-dither i:nth-child(12) { animation-delay: calc(var(--speed) * 0.5625); }
.bl-dither i:nth-child(13) { animation-delay: calc(var(--speed) * 0.9375); }
.bl-dither i:nth-child(14) { animation-delay: calc(var(--speed) * 0.4375); }
.bl-dither i:nth-child(15) { animation-delay: calc(var(--speed) * 0.8125); }
.bl-dither i:nth-child(16) { animation-delay: calc(var(--speed) * 0.3125); }
@keyframes bl-dith {
  0%, 100% { opacity: 0.1; }
  50% { opacity: 1; }
}
```

## Comet

Six trail dots (shrinking, fading) fixed inside a rotating orbit.

```html
<span class="bl bl-comet" role="status" aria-label="Loading">
  <span class="bl-comet-orbit" aria-hidden="true">
    <i></i><i></i><i></i><i></i><i></i><i></i>
  </span>
</span>
```

```css
.bl-comet { position: relative; width: var(--size); height: var(--size); }
.bl-comet-orbit {
  position: absolute;
  inset: 0;
  animation: bl-rotate var(--speed) linear infinite;
}
.bl-comet i {
  --i: 0;
  --d: calc(var(--size) * 0.2 * (1 - var(--i) * 0.13));
  position: absolute;
  top: 50%;
  left: 50%;
  width: var(--d);
  height: var(--d);
  margin: calc(var(--d) / -2) 0 0 calc(var(--d) / -2);
  border-radius: 50%;
  background: currentColor;
  opacity: calc(1 - var(--i) * 0.16);
  transform: rotate(calc(var(--i) * -15deg)) translateY(calc(var(--size) * -0.4));
}
.bl-comet i:nth-child(2) { --i: 1; }
.bl-comet i:nth-child(3) { --i: 2; }
.bl-comet i:nth-child(4) { --i: 3; }
.bl-comet i:nth-child(5) { --i: 4; }
.bl-comet i:nth-child(6) { --i: 5; }
```

## Newton

Newton's cradle: five balls in a row, only the end balls slide out and back —
left on the first half of the cycle, right on the second.

```html
<span class="bl bl-newton" role="status" aria-label="Loading">
  <i></i><i></i><i></i><i></i><i></i>
</span>
```

```css
.bl-newton i {
  width: calc(var(--size) * 0.2);
  height: calc(var(--size) * 0.2);
  border-radius: 50%;
  background: currentColor;
}
.bl-newton i:first-child { animation: bl-newton-l calc(var(--speed) * 1.5) var(--bl-ease) infinite; }
.bl-newton i:last-child  { animation: bl-newton-r calc(var(--speed) * 1.5) var(--bl-ease) infinite; }
@keyframes bl-newton-l {
  0% { transform: translateX(0); }
  28% { transform: translateX(calc(var(--size) * -0.22)); }
  50%, 100% { transform: translateX(0); }
}
@keyframes bl-newton-r {
  0%, 50% { transform: translateX(0); }
  78% { transform: translateX(calc(var(--size) * 0.22)); }
  100% { transform: translateX(0); }
}
```

## Helix

Seven rows, two counter-phased dots per row — DNA strand. Row *r* (0-based)
sits at `top = r/6 * (size - dot)` and delays by `r/7 * speed`.

```html
<span class="bl bl-helix" role="status" aria-label="Loading">
  <span class="bl-hr"><i></i><i></i></span>
  <span class="bl-hr"><i></i><i></i></span>
  <span class="bl-hr"><i></i><i></i></span>
  <span class="bl-hr"><i></i><i></i></span>
  <span class="bl-hr"><i></i><i></i></span>
  <span class="bl-hr"><i></i><i></i></span>
  <span class="bl-hr"><i></i><i></i></span>
</span>
```

```css
.bl-helix { position: relative; width: var(--size); height: var(--size); }
.bl-helix .bl-hr { --r: 0; }
.bl-helix .bl-hr:nth-child(2) { --r: 1; }
.bl-helix .bl-hr:nth-child(3) { --r: 2; }
.bl-helix .bl-hr:nth-child(4) { --r: 3; }
.bl-helix .bl-hr:nth-child(5) { --r: 4; }
.bl-helix .bl-hr:nth-child(6) { --r: 5; }
.bl-helix .bl-hr:nth-child(7) { --r: 6; }
.bl-helix i {
  --dot: calc(var(--size) * 0.14);
  position: absolute;
  left: calc(50% - var(--dot) / 2);
  top: calc(var(--r) / 6 * (var(--size) - var(--dot)));
  width: var(--dot);
  height: var(--dot);
  border-radius: 50%;
  background: currentColor;
  animation: bl-helix-a var(--speed) var(--bl-ease) infinite;
  animation-delay: calc(var(--r) / 7 * var(--speed));
}
.bl-helix i:last-child { animation-name: bl-helix-b; }
@keyframes bl-helix-a {
  0%, 100% { transform: translateX(calc(var(--size) * 0.32)) scale(1); opacity: 1; }
  50% { transform: translateX(calc(var(--size) * -0.32)) scale(0.5); opacity: 0.45; }
}
@keyframes bl-helix-b {
  0%, 100% { transform: translateX(calc(var(--size) * -0.32)) scale(0.5); opacity: 0.45; }
  50% { transform: translateX(calc(var(--size) * 0.32)) scale(1); opacity: 1; }
}
```

## Metaballs

Two blurred circles crossing through each other; an SVG filter thresholds the
alpha so they merge like liquid. Geometry properties (`cx`) are animated from
CSS — supported in all evergreen browsers.

The filter `id` must be unique per page. If the page can contain several
metaball loaders, suffix the id.

```html
<span class="bl bl-metaballs" role="status" aria-label="Loading">
  <svg viewBox="0 0 100 100" aria-hidden="true">
    <defs>
      <filter id="bl-goo">
        <feGaussianBlur in="SourceGraphic" stdDeviation="5" result="b"/>
        <feColorMatrix in="b" values="1 0 0 0 0  0 1 0 0 0  0 0 1 0 0  0 0 0 20 -8"/>
      </filter>
    </defs>
    <g filter="url(#bl-goo)" fill="currentColor">
      <circle class="bl-mb-a" cy="50" r="15"/>
      <circle class="bl-mb-b" cy="50" r="15"/>
    </g>
  </svg>
</span>
```

```css
.bl-metaballs svg { width: var(--size); height: var(--size); }
.bl-metaballs .bl-mb-a { cx: 30px; animation: bl-mb-a calc(var(--speed) * 1.6) var(--bl-ease) infinite; }
.bl-metaballs .bl-mb-b { cx: 70px; animation: bl-mb-b calc(var(--speed) * 1.6) var(--bl-ease) infinite; }
@keyframes bl-mb-a { 50% { cx: 70px; } }
@keyframes bl-mb-b { 50% { cx: 30px; } }
```

## Morph

A filled shape morphing circle → square → triangle → hexagon → diamond → circle,
holding each shape fully formed before the next morph, with rotation and a
slight scale dip during transitions. Full cycle takes `--speed * 5`.

The path morph uses SMIL (`<animate attributeName="d">`) because it works in
every browser including Safari; each shape is sampled at 24 points with
identical command structure so the tween is point-to-point. Rotation/scale run
as a matching CSS animation. **SMIL `dur` cannot read CSS variables** — if you
change `--speed`, also set `dur` to `speed × 5` seconds by hand (both are `5s`
below for the default 1s speed).

```html
<span class="bl bl-morph" role="status" aria-label="Loading">
  <svg viewBox="0 0 100 100" aria-hidden="true">
    <path fill="currentColor" d="M50.00 4.00 L61.91 5.57 L73.00 10.16 L82.53 17.47 L89.84 27.00 L94.43 38.09 L96.00 50.00 L94.43 61.91 L89.84 73.00 L82.53 82.53 L73.00 89.84 L61.91 94.43 L50.00 96.00 L38.09 94.43 L27.00 89.84 L17.47 82.53 L10.16 73.00 L5.57 61.91 L4.00 50.00 L5.57 38.09 L10.16 27.00 L17.47 17.47 L27.00 10.16 L38.09 5.57 Z">
      <animate attributeName="d" dur="5s" repeatCount="indefinite"
        calcMode="spline"
        keyTimes="0;0.1;0.2;0.3;0.4;0.5;0.6;0.7;0.8;0.9;1"
        keySplines="0.77 0 0.175 1;0.77 0 0.175 1;0.77 0 0.175 1;0.77 0 0.175 1;0.77 0 0.175 1;0.77 0 0.175 1;0.77 0 0.175 1;0.77 0 0.175 1;0.77 0 0.175 1;0.77 0 0.175 1"
        values="M50.00 4.00 L61.91 5.57 L73.00 10.16 L82.53 17.47 L89.84 27.00 L94.43 38.09 L96.00 50.00 L94.43 61.91 L89.84 73.00 L82.53 82.53 L73.00 89.84 L61.91 94.43 L50.00 96.00 L38.09 94.43 L27.00 89.84 L17.47 82.53 L10.16 73.00 L5.57 61.91 L4.00 50.00 L5.57 38.09 L10.16 27.00 L17.47 17.47 L27.00 10.16 L38.09 5.57 Z;
                M50.00 4.00 L61.91 5.57 L73.00 10.16 L82.53 17.47 L89.84 27.00 L94.43 38.09 L96.00 50.00 L94.43 61.91 L89.84 73.00 L82.53 82.53 L73.00 89.84 L61.91 94.43 L50.00 96.00 L38.09 94.43 L27.00 89.84 L17.47 82.53 L10.16 73.00 L5.57 61.91 L4.00 50.00 L5.57 38.09 L10.16 27.00 L17.47 17.47 L27.00 10.16 L38.09 5.57 Z;
                M50.00 17.47 L58.72 17.47 L68.78 17.47 L82.53 17.47 L82.53 31.22 L82.53 41.28 L82.53 50.00 L82.53 58.72 L82.53 68.78 L82.53 82.53 L68.78 82.53 L58.72 82.53 L50.00 82.53 L41.28 82.53 L31.22 82.53 L17.47 82.53 L17.47 68.78 L17.47 58.72 L17.47 50.00 L17.47 41.28 L17.47 31.22 L17.47 17.47 L31.22 17.47 L41.28 17.47 Z;
                M50.00 17.47 L58.72 17.47 L68.78 17.47 L82.53 17.47 L82.53 31.22 L82.53 41.28 L82.53 50.00 L82.53 58.72 L82.53 68.78 L82.53 82.53 L68.78 82.53 L58.72 82.53 L50.00 82.53 L41.28 82.53 L31.22 82.53 L17.47 82.53 L17.47 68.78 L17.47 58.72 L17.47 50.00 L17.47 41.28 L17.47 31.22 L17.47 17.47 L31.22 17.47 L41.28 17.47 Z;
                M50.00 23.44 L56.16 27.00 L61.50 30.08 L66.84 33.16 L73.00 36.72 L81.42 41.58 L96.00 50.00 L81.42 58.42 L73.00 63.28 L66.84 66.84 L61.50 69.92 L56.16 73.00 L50.00 76.56 L41.58 81.42 L27.00 89.84 L27.00 73.00 L27.00 63.28 L27.00 56.16 L27.00 50.00 L27.00 43.84 L27.00 36.72 L27.00 27.00 L27.00 10.16 L41.58 18.58 Z;
                M50.00 23.44 L56.16 27.00 L61.50 30.08 L66.84 33.16 L73.00 36.72 L81.42 41.58 L96.00 50.00 L81.42 58.42 L73.00 63.28 L66.84 66.84 L61.50 69.92 L56.16 73.00 L50.00 76.56 L41.58 81.42 L27.00 89.84 L27.00 73.00 L27.00 63.28 L27.00 56.16 L27.00 50.00 L27.00 43.84 L27.00 36.72 L27.00 27.00 L27.00 10.16 L41.58 18.58 Z;
                M50.00 10.16 L60.67 10.16 L73.00 10.16 L79.16 20.84 L84.50 30.08 L89.84 39.33 L96.00 50.00 L89.84 60.67 L84.50 69.92 L79.16 79.16 L73.00 89.84 L60.67 89.84 L50.00 89.84 L39.33 89.84 L27.00 89.84 L20.84 79.16 L15.50 69.92 L10.16 60.67 L4.00 50.00 L10.16 39.33 L15.50 30.08 L20.84 20.84 L27.00 10.16 L39.33 10.16 Z;
                M50.00 10.16 L60.67 10.16 L73.00 10.16 L79.16 20.84 L84.50 30.08 L89.84 39.33 L96.00 50.00 L89.84 60.67 L84.50 69.92 L79.16 79.16 L73.00 89.84 L60.67 89.84 L50.00 89.84 L39.33 89.84 L27.00 89.84 L20.84 79.16 L15.50 69.92 L10.16 60.67 L4.00 50.00 L10.16 39.33 L15.50 30.08 L20.84 20.84 L27.00 10.16 L39.33 10.16 Z;
                M50.00 4.00 L59.72 13.72 L66.84 20.84 L73.00 27.00 L79.16 33.16 L86.28 40.28 L96.00 50.00 L86.28 59.72 L79.16 66.84 L73.00 73.00 L66.84 79.16 L59.72 86.28 L50.00 96.00 L40.28 86.28 L33.16 79.16 L27.00 73.00 L20.84 66.84 L13.72 59.72 L4.00 50.00 L13.72 40.28 L20.84 33.16 L27.00 27.00 L33.16 20.84 L40.28 13.72 Z;
                M50.00 4.00 L59.72 13.72 L66.84 20.84 L73.00 27.00 L79.16 33.16 L86.28 40.28 L96.00 50.00 L86.28 59.72 L79.16 66.84 L73.00 73.00 L66.84 79.16 L59.72 86.28 L50.00 96.00 L40.28 86.28 L33.16 79.16 L27.00 73.00 L20.84 66.84 L13.72 59.72 L4.00 50.00 L13.72 40.28 L20.84 33.16 L27.00 27.00 L33.16 20.84 L40.28 13.72 Z;
                M50.00 4.00 L61.91 5.57 L73.00 10.16 L82.53 17.47 L89.84 27.00 L94.43 38.09 L96.00 50.00 L94.43 61.91 L89.84 73.00 L82.53 82.53 L73.00 89.84 L61.91 94.43 L50.00 96.00 L38.09 94.43 L27.00 89.84 L17.47 82.53 L10.16 73.00 L5.57 61.91 L4.00 50.00 L5.57 38.09 L10.16 27.00 L17.47 17.47 L27.00 10.16 L38.09 5.57 Z"/>
    </path>
  </svg>
</span>
```

```css
.bl-morph svg { width: var(--size); height: var(--size); }
.bl-morph path {
  transform-box: fill-box;
  transform-origin: center;
  animation: bl-morph-spin calc(var(--speed) * 5) var(--bl-ease) infinite;
}
/* Rotation/scale advance only during morph segments (odd 10% slices),
   holding still while a shape is settled — matches MORPH_ROT / MORPH_SCALE. */
@keyframes bl-morph-spin {
  0%, 10%   { transform: rotate(0deg) scale(1); }
  20%, 30%  { transform: rotate(72deg) scale(0.88); }
  40%, 50%  { transform: rotate(144deg) scale(1); }
  60%, 70%  { transform: rotate(216deg) scale(0.88); }
  80%, 90%  { transform: rotate(288deg) scale(1); }
  100%      { transform: rotate(360deg) scale(1); }
}
```

---

## JS-driven variants

These need a few lines of JS because they swap text content or count state.
Each init returns the interval id — call `clearInterval(id)` when removing the
loader. Reduced-motion handling is built in.

## Ascii

Terminal-style frame cyclers. Five frame sets, same ones AI CLI agents use.

```html
<span class="bl bl-ascii" role="status" aria-label="Loading"></span>
```

```css
.bl-ascii {
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: var(--size);
  line-height: 1;
  font-variant-numeric: tabular-nums;
}
```

```js
const BL_FRAMES = {
  ascii:           ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"],
  "ascii-line":    ["|", "/", "-", "\\"],
  "ascii-braille": ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"],
  "ascii-blocks":  ["▁", "▂", "▃", "▄", "▅", "▆", "▇", "█", "▇", "▆", "▅", "▄", "▃", "▂"],
  "ascii-bounce":  ["⠁", "⠂", "⠄", "⡀", "⢀", "⠠", "⠐", "⠈"],
};

function blAscii(el, variant = "ascii", speedSec = 1) {
  const frames = BL_FRAMES[variant];
  // Reduced motion slows the cycle rather than stopping — it's a glyph swap,
  // not on-screen movement.
  const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const step = ((reduce ? speedSec * 2.5 : speedSec) / frames.length) * 1000;
  let f = 0;
  el.textContent = frames[0];
  return setInterval(() => { el.textContent = frames[f = (f + 1) % frames.length]; }, step);
}

// blAscii(document.querySelector(".bl-ascii"), "ascii-braille");
```

## Scramble

Random glyphs resolving letter-by-letter into a target word.

```html
<span class="bl bl-scramble" role="status" aria-label="Loading"></span>
```

```css
.bl-scramble {
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: calc(var(--size) * 0.42);
  font-weight: 500;
  letter-spacing: 0.2em;
  font-variant-numeric: tabular-nums;
}
```

```js
function blScramble(el, text = "LOADING", speedSec = 1) {
  const GLYPHS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789<>/*#@";
  if (matchMedia("(prefers-reduced-motion: reduce)").matches) {
    el.textContent = text;
    return 0;
  }
  let tick = 0;
  const total = text.length + 4;
  return setInterval(() => {
    const reveal = tick % total;
    let s = "";
    for (let i = 0; i < text.length; i++) {
      s += i < reveal ? text[i] : GLYPHS[Math.floor(Math.random() * GLYPHS.length)];
    }
    el.textContent = s;
    tick++;
  }, (speedSec / text.length) * 1000 * 0.55);
}

// blScramble(document.querySelector(".bl-scramble"));
```

## Percent

Counter plus progress bar cycling 0→100%. Purely decorative timing (one cycle
per `speed` seconds) — wire `p` to real progress if you have it.

```html
<span class="bl bl-percent" role="status" aria-label="Loading">
  <span class="bl-percent-num">0%</span>
  <span class="bl-percent-track"><span class="bl-percent-fill"></span></span>
</span>
```

```css
.bl-percent {
  flex-direction: column;
  gap: calc(var(--size) * 0.14);
  width: calc(var(--size) * 1.4);
}
.bl-percent-num {
  font-family: ui-monospace, SFMono-Regular, Menlo, Consolas, monospace;
  font-size: calc(var(--size) * 0.42);
  font-weight: 500;
  line-height: 1;
  font-variant-numeric: tabular-nums;
}
.bl-percent-track {
  width: 100%;
  height: max(3px, calc(var(--size) * 0.1));
  border-radius: 999px;
  overflow: hidden;
  background: color-mix(in srgb, currentColor 15%, transparent);
}
.bl-percent-fill {
  display: block;
  height: 100%;
  width: 0%;
  border-radius: 999px;
  background: currentColor;
}
```

```js
function blPercent(el, speedSec = 1) {
  const num = el.querySelector(".bl-percent-num");
  const fill = el.querySelector(".bl-percent-fill");
  const reduce = matchMedia("(prefers-reduced-motion: reduce)").matches;
  const dur = (reduce ? speedSec * 2 : speedSec) * 1000;
  let t = 0;
  return setInterval(() => {
    t += 40;
    const p = Math.min(100, Math.round((t / dur) * 100));
    num.textContent = p + "%";
    fill.style.width = p + "%";
    if (p >= 100) t = 0;
  }, 40);
}

// blPercent(document.querySelector(".bl-percent"));
```
