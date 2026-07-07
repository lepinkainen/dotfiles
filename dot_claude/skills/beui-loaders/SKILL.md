---
name: beui-loaders
description: Add beui-style loading animations (spinner, bouncing dots, bars, dot-matrix, dither, terminal/ascii spinners, shape morph, comet, scramble text, metaballs, newton's cradle, helix, percent counter) to any project as vanilla HTML/CSS/JS — no React, no build step, no dependency. Use this skill whenever the user wants a loader, spinner, loading indicator, progress animation, or "loading..." state in a non-React project — server-rendered templates (Go, Rails, Django, Flask/Jinja, PHP), HTMX, Web Components, static HTML, or plain JS apps — even if they don't mention beui by name. Also use it when the user asks to port or copy a beui motion component.
---

# beui loaders — vanilla ports

Pre-ported, verified vanilla implementations of all 17 loader variants from
[beui](https://beui.dev/components/motion/loader). The React original depends on
`motion/react` and Tailwind; these ports need nothing. Don't re-derive the
animations from scratch — the math (easing, delays, Bayer matrix, morph paths)
is already worked out in the reference file, faithful to the original.

## Workflow

1. **Pick a variant.** If the user named one, use it. Otherwise pick by context
   (see table below) — terminal/CLI aesthetics suit `ascii-*` and `scramble`;
   understated UIs suit `spinner`, `dots`, `bars`; playful UIs suit `morph`,
   `metaballs`, `comet`, `newton`, `helix`. Mention the alternatives briefly so
   the user knows they exist.
2. **Copy the snippet** from `references/vanilla-ports.md` (has a table of
   contents). Take the shared base CSS block once, plus the variant's
   HTML/CSS/JS. Do not retype from memory — the delay tables and path data are
   precise.
3. **Adapt to the host project:**
   - Put CSS where the project keeps styles (stylesheet, `<style>` block,
     template partial). Rename the `bl-` class prefix if it collides.
   - Set `--size` (px) and `--speed` (seconds/cycle) on the root element;
     color comes from `currentColor`, so set `color` or let it inherit.
   - JS variants (`ascii`, `scramble`, `percent`): call the init function once
     the element is in the DOM; keep the returned interval id and
     `clearInterval` it when hiding the loader.
   - Show/hide belongs to the host app (CSS class toggle, `htmx-indicator`,
     `hidden` attribute…) — the snippets only animate.
4. **Keep what's already correct:** the root's `role="status"`/`aria-label`
   (screen-reader announcement) and the `prefers-reduced-motion` block
   (accessibility requirement, mirrors the original's reduced-motion
   fallback). Strip them only if the user explicitly asks.

## Variant cheat sheet

| Variant | Tech | Notes |
|---|---|---|
| spinner, dots, bars, dot-matrix, dither, comet, newton, helix | pure CSS | copy-paste, done |
| metaballs | pure CSS + SVG filter | filter `id` must be unique per page |
| morph | CSS + SMIL | SMIL `dur` can't read CSS vars — changing `--speed` means also editing `dur` (= speed × 5) |
| ascii / ascii-line / ascii-braille / ascii-blocks / ascii-bounce | tiny JS | frame cycler, one `setInterval` |
| scramble | tiny JS | glyphs resolving into a word (default "LOADING") |
| percent | tiny JS | decorative 0→100% cycle; wire to real progress if available |

## Resources

- `references/vanilla-ports.md` — the ports. Read the shared-base section plus
  the chosen variant's section; no need to read the whole file.
- `references/loader-source.tsx` — original React source. Consult only when
  fidelity questions come up (exact timing multiplier, reduced-motion nuance)
  or when the user asks how the original works.
- `assets/demo.html` — every variant on one page. Open it (or point the user
  to it) to compare variants visually, or to sanity-check a port after
  modifying one.
