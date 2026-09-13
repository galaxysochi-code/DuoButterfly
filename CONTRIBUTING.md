# Contributing

Thanks for helping improve DUO Butterfly. Issues and pull requests in English or Russian are welcome.

## Reporting a bug

Use the **Bug report** template and include:

- Mac model, macOS version, and DUO Butterfly version (**About** tab).
- The diagnostics report: **Settings → Diagnostics → Copy Report**.
- Whether it happens in the preview, the five-second demo, or while moving the lid.
- Effect settings: style, bend, blur, darkness, cutoff angle.

Don't attach screenshots with private desktop content.

For sensor problems on an untested MacBook, run `zsh scripts/diagnose-lid.sh` and attach the
output. The script only reads the model, macOS version, and Apple HID device list.

## Development setup

Requirements: Apple silicon Mac, macOS 26+, Xcode 26.4+, and [XcodeGen](https://github.com/yonaskolb/XcodeGen).

```bash
brew install xcodegen
xcodegen generate
open DuoButterfly.xcodeproj
```

`project.yml` is the source of truth for the project; the `.xcodeproj` is generated and not committed.
See [docs/BUILDING.md](docs/BUILDING.md) for build and test commands.

## Pull requests

1. Keep changes focused. Don't commit generated projects, build output, or signing keys.
2. Run `./scripts/test.sh unit`. For rendering, capture, or lifecycle changes, also run
   `./scripts/test.sh all` on a physical MacBook (a full-screen animation appears briefly).
3. **Every new interface string** goes through `tr("…")` with English, Simplified Chinese,
   and Spanish entries in `DuoButterfly/Localization.swift`. `LocalizationTests` fails on
   missing translations.
4. Changes to screen access, cursor handling, and lifecycle must keep capture cleanup and
   pointer restoration intact.
5. Describe the user-visible change and what you verified (including hardware) in the PR.

Donation wallet addresses live outside the repository; see "Donation wallets" in
[docs/BUILDING.md](docs/BUILDING.md). Never commit `Wallets.plist`.

If you change the interface, refresh README screenshots with `./scripts/readme-screenshots.sh`
(the terminal needs screen-recording permission).

## License

By contributing, you agree that your code and documentation are licensed under the
[MIT License](LICENSE). Assets have separate terms in [ASSETS.md](ASSETS.md).
