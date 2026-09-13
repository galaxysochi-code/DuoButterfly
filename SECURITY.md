# Security policy

## Supported versions

Security fixes go into the latest release only.

| Version | Supported |
|---|---|
| 1.0.x | ✅ |
| older | ❌ |

## Reporting a vulnerability

Please **don't open a public issue** for security problems.

Report privately through GitHub:
[Security → Report a vulnerability](https://github.com/galaxysochi-code/DuoButterfly/security/advisories/new).

Include:

- the affected version and macOS version;
- steps to reproduce;
- the practical impact (for example, access to screen content, cursor left hidden, capture not stopping).

Don't include screen captures with private content, passwords, or other secrets.
You should get a first response within 7 days.

## Scope

DUO Butterfly captures the built-in display with ScreenCaptureKit, hides the pointer while the
effect is visible, reads the lid angle through HID, and makes no network requests. Issues where
screen content leaves the Mac, capture keeps running when the effect is off, or the pointer
stays hidden are treated as security issues.

Ordinary bugs such as animation artifacts belong in the bug-report template.
