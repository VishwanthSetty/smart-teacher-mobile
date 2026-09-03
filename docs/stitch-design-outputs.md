# Stitch design outputs

Generated from [`stitch-design-prompts.md`](stitch-design-prompts.md) on
2026-08-28 using Stitch MCP and `GEMINI_3_1_PRO` in portrait mobile mode.

## Projects

| Audience | Stitch project ID | Design system asset | Prompt briefs |
| --- | --- | --- | ---: |
| Student | `4086503233287179347` | `assets/6677994744381388235` | 20 |
| Teacher | `7753021071171110152` | `assets/15010860429511999864` | 21 |

Both projects contain the five shared authentication briefs, their complete
role-specific shell and content briefs, the shared player/reader briefs, and
the applicable system-state briefs from the source document. Stitch may show
standalone illustration assets alongside the requested screens; these are
generated dependencies rather than extra app routes.

## Reviewed refinements

- Student login state sheet: `6b4f5ec6dea74a868c84ed195223369c`
  (default, incorrect credentials, disabled account, and rate-limited states).
- Teacher shell: `2cbebcfa8daf48cd8f9852ec379d3f01`
  (assignment-only class fields, matching the current API contract).
- Teacher error state sheet: `9310f0f26e9240948a7ce1982c45f38e`
  (professional treatment without the younger-student mascot).
- Student document reader: `16bf499b95024cc1a9db99ffb74f446f`.

## Implementation mapping

The Flutter theme uses the generated system's blue/sky/navy palette, Nunito
body typography, Fredoka headings, rounded surfaces, and light/dark component
tokens. The splash and login screens implement the generated hierarchy with
compact responsive spacing for small phones. Navigation uses a shared 220 ms
fade-and-slide transition.

Student class and roll-number content is supplied additively by the existing
`GET /users/me` endpoint as nullable `enrollment` data. Non-student responses
return `enrollment: null`.
