# DUO Butterfly website

Product site: https://galaxysochi-code.github.io/DuoButterfly/

The site is plain HTML, CSS and JavaScript in `website/`. No framework, package manager,
external font, analytics, server or build step is required. English is the source language;
Russian, Spanish and Simplified Chinese follow the browser language. A manual choice is
stored locally, with a safe fallback when browser storage is unavailable.

## Preview and validation

From the repository root:

```sh
python3 -m http.server 8766 --bind 127.0.0.1 --directory website
python3 scripts/check-website.py
node --check website/app.js
```

Open http://127.0.0.1:8766/. The validator checks translations, local assets, fragment
links, image accessibility attributes, public-bundle hygiene and the 300 KB code budget.

## Publication

`.github/workflows/pages.yml` publishes only `website/` to GitHub Pages when the site or
workflow changes on `main`, or when manually dispatched. GitHub Pages must use the
GitHub Actions source. The workflow uses repository-scoped Pages and OIDC permissions,
immutable action revisions and the standard GitHub Pages artifact. No paid services.

All download links intentionally lead to the latest release page, so a new app version
requires no website edits. The installation link points to maintained repository documentation.

## Product statements

The copy was checked against `DesktopCapture.swift`, `EffectModel.swift`, `PRIVACY.md`,
`docs/INSTALLING.md` and `docs/COMPATIBILITY.md` on 2026-09-14. It discloses macOS 26+,
Apple silicon, the lid-angle sensor requirement, and the unnotarized build. The entire compatibility section was removed at the owner’s request; only concise
system requirements remain below the hero download button.
Windows is announced as coming soon, with no download or invented release date.
The app's no-network/no-audio statements are distinct from the website's GitHub hosting.

## Media provenance

- `logo.png`, favicons and `og-image.png`: the owner's final DUO Butterfly artwork.
- `hero-preview.webp`, `silk.webp`, `dusk.webp`, `mist.webp`: lossless-source crops from
  `docs/images/effect.sheet.png`, produced by the real app Metal renderer.
- Localized `app-window-*.webp`: actual app screenshots from `docs/images/main-*.png`.
- Demo MP4/WebM/GIF: the first Silk cycle from `docs/images/effect.gif`, cropped to the
  desktop and retimed to five seconds. Video files use a 30 fps container; the source
  animation has 20 fps. This is the production renderer with a bundled sample desktop,
  not a screen recording of the user's desktop or a physical lid recording.

The new native test-render attempt was blocked by the macOS test-manager sandbox, so
existing verified app media was used. No application code was changed for the website.

Video sources are loaded only on playback. Desktop autoplay requires viewport visibility,
no reduced-motion preference, and no reported slow connection/data-saving mode. Small
screens use manual playback. Autoplay failures leave a working Play button. Explicit
pause is respected; offscreen/hidden playback stops. GIF is an optional footer download,
never part of initial page loading. Images have dimensions and use lazy loading below
the fold. App screenshots change with the selected language.

## Design and QA

Original product layout inspired by restrained Apple product presentation: large system
typography, generous whitespace, light/dark sections, limited purple-pink accent, real
product imagery and quiet motion. No Apple artwork or Apple logo is used.

Before release, inspect desktop and narrow mobile layouts, all four languages, style
selection, video play/pause, installation disclosures and download destinations. Respect
`prefers-reduced-motion`; check keyboard focus and 200% enlargement. A responsive browser
viewport check does not replace a physical iPhone/Safari check.

Verified before publication: Chromium desktop and mobile layouts; 320 px width in all
four languages without horizontal overflow; real Safari desktop playback and pause;
style switching, locale switching and the final free-download and Windows announcements.
Physical iOS Safari was not tested.
