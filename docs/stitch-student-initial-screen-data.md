# Stitch pull — student login and initial interface

Source project: [Smart Teacher — Student](https://stitch.withgoogle.com/projects/4086503233287179347)

Pulled through the Stitch MCP on 2026-08-29. The HTML exports and preview
images used during implementation are in `.tmp/stitch/`.

## Source screens

| Interface | Stitch screen ID | Export size |
| --- | --- | --- |
| Splash | `43fb41b59ff845ffa5cbce7a4e2af5a1` | 780 × 1768 |
| Login | `c21e3e97d2154bc5bd937a8bad0e155f` | 780 × 1768 |
| Login state sheet | `6b4f5ec6dea74a868c84ed195223369c` | 780 × 7408 |
| Student shell, all age bands | `6245add8db83485db1506c36762a39cd` | 780 × 5712 |
| Library — Band A | `00ae8a95a5254343bc1d85d5b1f2b868` | 780 × 1768 |
| Library — Bands B/C | `39dd70ec8c034ccf985534b568d6862d` | 780 × 1768 |
| Student profile | `f857dceb1a994ee5829950d12c9ee615` | 780 × 1768 |

## Pulled design contract

- Material 3 portrait mobile, authored at 390 × 844 logical pixels.
- Palette: `#FFFFFF`, `#E3F2FD`, `#90CAF9`, `#2196F3`, `#0D47A1`.
- Text neutrals: `#12263A`, `#5B6B7B`, `#93A2B0`.
- Semantic colors only: success `#2E7D32`, warning `#F9A825`, error
  `#D32F2F`.
- Fredoka headings and Nunito body/UI text.
- Card radii vary by age band: 28 / 24 / 20 logical pixels.
- Buttons and fields are 56 logical pixels tall with 16-pixel radii.
- Student subject identity uses icons plus the five-step blue tint ramp, not
  unrelated hues.
- Band B is the fallback whenever an enrollment rank is unavailable.

## Product-safe translation

The Flutter implementation intentionally keeps the PRD's `Library · Profile`
student tab set. Any extra Home/Teacher tabs, progress copy, due dates, or
continue-learning content visible in isolated Stitch presentation sheets are
demo material and are not implemented because the current API does not supply
those features.

The initial student Library uses only server-returned curricula, grades, and
counts. Age-band changes affect density and card arrangement only; entitlement
and role scoping remain server-owned.
