# Stitch design prompts — Smart Teacher mobile

Copy-paste prompt library for [Google Stitch](https://stitch.withgoogle.com) covering every screen in
the Flutter app.

**Two sources of truth, and they are different documents.** [PRD.md](PRD.md) says what the mobile app
must do. The backend at `../../smart-teacher` (`apps/api`) says what data actually exists —
controllers under `apps/api/src/<feature>/`, response shapes under `entities/`, enums in
`apps/api/prisma/schema.prisma`. Every prompt below has been reconciled against the second one.
**Nothing here asks Stitch to draw a field the API cannot return.**

Palette: [colorhunt.co/palette/e3f2fd90caf92196f30d47a1](https://colorhunt.co/palette/e3f2fd90caf92196f30d47a1)
— `#E3F2FD` · `#90CAF9` · `#2196F3` · `#0D47A1`.

## Revision note — what changed and why

This revision does two things.

**1. It widens the student audience from "ages 8–14" to the real one: KG through Grade 10.**
`GradeLevel` in the backend is a free-form `name` with a unique integer `rank`, so a school's ladder
is whatever the platform super admin created — `KG` (rank 0) through `Grade 10` (rank 10) is the
range we are designing for. One visual register cannot serve a five-year-old and a sixteen-year-old,
so §2 introduces **three age bands** that share one design system and swap a small, explicit set of
tokens. Every screen prompt from §5 onward names which band(s) it is for.

**2. It removes the invented data.** The previous revision asked Stitch for several things the API
has no column for. Those are corrected in place and listed here so nobody re-adds them:

| Was asked for | Reality | Now |
|---|---|---|
| "Continue where you left off", 40% progress bar | **There is no progress, watch-history or bookmark model anywhere in `schema.prisma`.** | Hero card replaced with a non-stateful "Today" card (§7.1) |
| "PDF · 2.4 MB" on document rows in the tree | `ContentTreeDocumentEntity` is `{id, title, description, status}` — no `sizeBytes` | Size shown **only** during download, where it is genuinely known |
| Hardcoded "Chapter" / "Topic" nesting labels | `ContentNodeEntity.levelName` is resolved per curriculum from its schema — could be "Unit", "Module", "Lesson" | Level name is a **variable** in every tree prompt |
| Profile rows "Grade" and "Member since" | `MeEntity` is only `{id, email, name, role, schoolId, school}` | Grade is *derived* (§2.3); "Member since" comes from `GET /users/:id` `createdAt` |
| Teacher profile "Employee ID" | No such column on `User` | Replaced with subjects taught, from `/teacher-assignments` |
| Reset link "expires in 30 minutes" | `password-reset.service.ts` mints a **1-hour** single-use token | Copy corrected |
| Video and document rows always ready | `VideoStatus` is `UPLOADING/QUEUED/PROCESSING/READY/FAILED`; `DocumentStatus` is `UPLOADING/READY/FAILED` | Status chips added as first-class row states |
| Roster rows with no status | `StudentEntity.status` is `PENDING/ACTIVE/DISABLED`, and `enrollment.rollNumber` exists | Both added |
| §5.8 "coming soon" content stub | The player and reader are now being built; `ComingSoonView`'s last use is going away | Retired — see §9.7 |

---

## 0. How to use these

1. Start **one Stitch project per role surface** — "Smart Teacher — Student" and "Smart Teacher —
   Teacher". Shared screens (auth, profile, library, tree) get designed twice.
2. Paste **§3 (master style prompt)** as the first message in each project. Stitch carries theme
   context forward inside a chat.
3. In the **student** project, paste **§2.4 (the band prompt)** as the second message, once per band
   you are designing. Generate a band's screens together before switching bands — Stitch holds a
   band's tokens better than it holds a per-screen override.
4. For each screen, paste its prompt from §5–§9. Every prompt ends with the **§4 style token** so it
   still renders correctly if Stitch loses context.
5. Use **Experimental / high-fidelity mode** for hero screens (login, student library, curriculum
   tree, video player) and Standard mode for list/form screens.
6. Iterate with the follow-ups in §10 rather than re-prompting from scratch.
7. Export → "Copy to Figma" or copy the code, then map tokens back to Flutter using §11.

**Three rules to keep repeating to Stitch**, because it drifts on all of them: *no purple, no teal, no
orange — blues and neutrals only*; *no stock photography — flat vector illustration only*; and *no
progress bars, streaks, XP, badges or "continue watching" — the backend tracks none of it, and a
mockup that shows it will get built by mistake.*

**Practical Stitch notes:** keep prompts under roughly 250 words or later details get dropped;
generate one screen per prompt; and reuse component names verbatim ("count chip", "level row",
"section tag") so it reuses components rather than reinventing them.

---

## 1. What the API can actually supply

Design against this table, not against imagination. Field names are the real ones.

| Screen needs | Endpoint | Fields you may draw |
|---|---|---|
| Signed-in user | `GET /users/me` | `id`, `email`, `name`, `role`, `schoolId`, `school{id, name, slug, status}` |
| Own account age | `GET /users/:id` (own id) | `status`, `activatedAt`, `createdAt` |
| Grade ladder | `GET /grade-levels` | `id`, `name`, `rank` — **this is where KG…Grade 10 comes from** |
| Subject icons | `GET /subjects` | `id`, `name`, `code` (`maths`, `science`…), `status` |
| Library list | `GET /curricula?audience=` | `subjectName`, `gradeLevelName`, `schemaName`, `status`, `publishedAt`, `audience`, `nodeCount`, `videoCount`, `documentCount` |
| Curriculum tree | `GET /curricula/:id/tree` | header: `subjectName`, `gradeLevelName`, `audience`, `status`; per node: `levelName`, `code`, `title`, `description`, `depth`, `canHoldContent`, `videoCountDeep`, `documentCountDeep`; per video: `title`, `description`, `durationSecs`, `status`; per document: `title`, `description`, `status` |
| Video playback | `GET /videos/:id/playback-token` | `manifestUrl` (HLS), `posterUrl`, `durationSecs`, `expiresInSecs` (**≤ 600**) |
| Document open | `GET /documents/:id/download` | `url`, `fileName`, `expiresInSecs` |
| My Classes | `GET /teacher-assignments?teacherId=` | `subjectName`, `subjectCode`, `sectionLabel`, `gradeLevelName`, `sectionName` — **the last four are null together** for a school-wide grant |
| Roster | `GET /students?page=&limit=&search=&sectionId=&status=` | `name`, `firstName`, `lastName`, `email`, `status`, `createdAt`, `enrollment{sectionName, gradeLevelName, rollNumber}` (nullable) |
| Section picker | `GET /sections` | `id`, `name`, `gradeLevelName`, `label` (`"Grade 5 - A"`), `studentCount` |

**Enums that must be drawable, because the server really sends them:**
`Role` SUPER_ADMIN·SCHOOL_ADMIN·TEACHER·STUDENT · `SchoolStatus` ACTIVE·SUSPENDED ·
`UserStatus` PENDING·ACTIVE·DISABLED · `CurriculumStatus` DRAFT·PUBLISHED·ARCHIVED ·
`ContentAudience` STUDENT·TEACHER · `VideoStatus` UPLOADING·QUEUED·PROCESSING·READY·FAILED ·
`DocumentStatus` UPLOADING·READY·FAILED.

**Two API behaviours the design must respect.** A single-item read answers `404` for both "no such
record" and "exists, but not yours" — so no not-found screen may ever be worded as a refusal (§9.2).
And a `403` carrying a suspended school is the only entitlement state that gets its own screen
(§6.5); everything else falls to the generic error body.

---

## 2. Age bands — KG through Grade 10

### 2.1 Why bands

The student role spans roughly ages 4 to 16 on one codebase. A KG screen needs pre-reader
affordances — pictures carrying the meaning, six-word sentences, enormous targets. A Grade 10 screen
needs density, search and no cartoon owl. One middle-ground screen serves neither.

So: **one design system, three bands, and the band changes only the tokens in §2.2.** Layout
skeletons, component names, colours and information architecture are identical across bands, which is
what keeps this buildable as one Flutter widget tree reading one `AgeBand` enum rather than three
forked screens.

### 2.2 The band token table

| Token | **A — Explorers**<br>KG · Gr 1 · Gr 2 (rank 0–2) | **B — Learners**<br>Gr 3 · Gr 4 · Gr 5 (rank 3–5) | **C — Scholars**<br>Gr 6 – Gr 10 (rank 6–10) |
|---|---|---|---|
| Screen title | Fredoka 28/700 | Fredoka 24/700 | Fredoka 22/700 |
| Body | Nunito 17/400 | Nunito 15/400 | Nunito 15/400 |
| Min touch target | 64×64 | 56×56 | 48×48 |
| Card radius | 28px | 24px | 20px |
| Screen padding | 24px, 20px between cards | 24px, 16px between cards | 20px, 12px between cards |
| Library layout | 2-col grid, 190px tall, 80px icon tile | 2-col grid, 150px tall, 56px icon tile | 1-col rows, 88px tall, 48px icon tile |
| Counts shown as | one big numeral + icon, no unit word | count chips ("12 videos") | dense inline text ("12 · 8") |
| Mascot | on every screen, expressive poses | greeting plus empty/error states only | **absent** |
| Illustration size | 220px | 180px | 140px, or none on list screens |
| Copy | ≤ 6 words, present tense, no jargon | one friendly sentence | concise, informational, no exclamation marks |
| Search | none | optional, collapsed behind an icon | pinned under the app bar |
| Nesting depth shown | one level, auto-expanded | two levels, collapsible | full depth, collapsible, with search |
| Icon style | filled, 32px | filled, 26px | outline inactive / filled active, 24px |
| Motion | bouncy, 300ms | 220ms standard easing | 180ms, restrained |

Everything not in this table is the same in all three bands.

### 2.3 How the app knows which band — an engineering note that affects the design

**`GET /users/me` does not return the student's grade.** There is no grade field on `MeEntity`, and
the roster endpoint that would carry an enrollment is SCHOOL_ADMIN/TEACHER-only. The band is
therefore *derived*, and the design must survive the derivation being unavailable:

1. `GET /curricula` for a STUDENT is server-narrowed to the entitled STUDENT curricula matching their
   **active enrollment grade** (`ActorContentScopeService`). Every row therefore carries the same
   `gradeLevelName` — that string is the student's grade.
2. `GET /grade-levels` maps that name to its `rank`.
3. `rank` → band, by the table above.

Two consequences for the mockups:

- **Band B is the fallback.** A student with no enrollment gets an empty library (§7.4) and no
  derivable grade. Design that empty state so it reads correctly at Band B, because that is what it
  will render as.
- **The band is known one round-trip after the library loads**, so the *skeleton* state (§9.3) must
  be band-neutral — plain geometry that does not shift when the band resolves. Do not design a Band A
  skeleton with an 80px icon tile that pops to 48px.

Teachers have no band. The teacher surface is one register, always.

### 2.4 Band prompt — paste after the master prompt, once per band

> Everything I ask for next is for **age band {A — Explorers, KG to Grade 2, ages 4–7 / B — Learners,
> Grade 3 to 5, ages 8–10 / C — Scholars, Grade 6 to 10, ages 11–16}** of the Smart Teacher student
> app. Keep the design system I gave you, and override exactly these tokens:
>
> *(paste that band's column from §2.2 as a bullet list)*
>
> The information architecture, component names and palette do not change between bands — only size,
> density, copy length and whether the mascot appears. A Band C screen must never look like a
> different product from a Band A screen; it must look like the same product grown up. Confirm, then
> wait for the first screen.

---

## 3. Master style prompt (paste once, first message in the project)

> I'm designing a mobile app called **Smart Teacher** — a school learning app used by **students from
> kindergarten through Grade 10 (ages 4 to 16)** and by their **teachers**. Everything I ask you to
> design from now on uses this one design system.
>
> **Platform:** Android + iOS, Material 3, portrait mobile, 390×844.
>
> **Colour palette (use only these plus neutrals):**
> - `#FFFFFF` — page background
> - `#E3F2FD` — tinted surfaces, cards, section backgrounds, illustration sky
> - `#90CAF9` — secondary fills, chips, illustration mid-tone
> - `#2196F3` — primary buttons, active states, links, selected tabs
> - `#0D47A1` — headings, app bar text, deep accents, illustration outlines
> - Text: `#12263A` primary, `#5B6B7B` secondary, `#93A2B0` disabled
> - Semantics only where required: success `#2E7D32`, warning `#F9A825`, error `#D32F2F`
>
> **Do not introduce purple, teal, pink, orange or green anywhere except the semantic colours above.**
>
> **Differentiating many subjects without new hues.** This app shows up to eleven grades' worth of
> subjects. Subjects are told apart by **icon and by a five-step blue tint ramp** — `#E3F2FD`,
> `#D0E7FB`, `#B8DBF9`, `#A1CFF7`, `#90CAF9` — used as the icon tile fill with a `#0D47A1` glyph on
> top. Never by inventing a new hue. Cards must still read as one family.
>
> **Shape & depth:** cards 20–28px radius depending on age band, sheets 28px top radius, buttons 16px,
> chips and tags fully rounded, avatars circular. Soft blue shadow only: `rgba(13,71,161,0.08)`,
> y-offset 8, blur 24. No hard borders except 1px `#E3F2FD` dividers. No glassmorphism.
>
> **Spacing:** 4pt scale.
>
> **Typography:** headings in **Fredoka** (rounded, friendly), body and UI in **Nunito**.
>
> **Illustration:** flat rounded-vector only, in the palette blues with white highlights. Chunky
> shapes, thick soft outlines, no gradients beyond a two-stop `#90CAF9 → #2196F3`. **Never use
> photographs.** A recurring mascot — **a small round blue owl in a graduation cap** — appears on
> younger students' screens only.
>
> **Never draw progress bars, percentages, streaks, points, badges, leaderboards or "continue
> watching" rows.** This product tracks none of that, and a mockup showing it is a bug.
>
> **Tone:** for **student** screens — warm and encouraging, scaled by age band. For **teacher**
> screens — same palette and components, calmer, denser, no mascot, professional micro-copy.
>
> **Accessibility:** touch targets never below 48×48, body text never below 15px, all text on
> `#2196F3` is white, never `#90CAF9` text on `#E3F2FD`.
>
> Confirm you've got this, then wait for me to describe the first screen.

---

## 4. Style token (append to every individual screen prompt)

> **Style:** Smart Teacher design system — Material 3, mobile 390×844. Palette: `#FFFFFF` page,
> `#E3F2FD` tinted surfaces, `#90CAF9` secondary fills, `#2196F3` primary actions, `#0D47A1`
> headings. Text `#12263A` / `#5B6B7B`. Cards 20–28px radius, buttons 16px, chips fully rounded, soft
> shadow `rgba(13,71,161,0.08)`. 4pt spacing. Fredoka headings, Nunito body. Flat rounded-vector
> illustration in palette blues only — no photos, no purple/teal/orange. Touch targets ≥48px. No
> progress bars, streaks or points anywhere.

---

## 5. Authentication & session (shared, PRD §5.1)

Auth screens are **band-neutral** — the school hands out the account, and a five-year-old rarely
types credentials. Design these once at Band B sizing, except §5.6.

### 5.1 Splash

> Design a **splash screen** for Smart Teacher. Full-bleed background in a soft two-stop vertical
> gradient from `#E3F2FD` at the top to `#FFFFFF` at the bottom. Centred: the app logo — a rounded
> square in `#2196F3` containing a white open-book glyph — with the wordmark "Smart Teacher" in
> Fredoka 28/700 `#0D47A1` beneath it, and a one-line tagline "Learning, made simple" in Nunito 15
> `#5B6B7B`. Below that, a small three-dot loading indicator in `#90CAF9`. Floating faintly in the
> background corners: soft `#90CAF9` circles at 20% opacity and a few tiny rounded stars. No buttons,
> no text fields, no version number and no progress bar — this screen is passive. [style token §4]

### 5.2 Login

> Design a **login screen** for Smart Teacher, used by students of every age and by teachers, so it
> must feel welcoming without being childish.
>
> Top third: a flat vector illustration of a friendly blue owl in a graduation cap waving beside a
> stack of books, on an `#E3F2FD` rounded panel with a 32px bottom radius bleeding to the screen
> edges. Below it, heading "Welcome back!" in Fredoka 24/700 `#0D47A1` and subtitle "Sign in to
> continue learning" in Nunito 15 `#5B6B7B`.
>
> Form, on white, in a card with 24px radius and soft shadow:
> - "School code" text field with a school-building icon prefix and helper text "Ask your teacher if
>   you don't know it" — this identifies the school, and the same email can exist at two schools
> - "Email" text field with a mail icon prefix
> - "Password" field with a lock icon prefix and a trailing eye toggle
> - Filled style, `#E3F2FD` background, no border at rest, 2px `#2196F3` border on focus, 16px
>   radius, 56px tall
> - A right-aligned "Forgot password?" text link in `#2196F3`
> - A full-width primary button "Sign in", `#2196F3`, white Nunito 16/700, 56px tall, 16px radius
>
> Show three **inline banner** variants docked above the form, all rounded 16px panels, never toasts:
> (a) error `#FDECEA` with a `#D32F2F` alert icon — "Email or password is incorrect."; (b) error —
> "This account has been disabled. Ask your school admin."; (c) a **waiting** banner in `#FFF8E1` with
> a `#F9A825` stopwatch icon — "Too many attempts. Try again in 4:32." — with the Sign in button
> disabled in `#90CAF9`.
>
> No social sign-in, no "create account" link — accounts are created by the school. [style token §4]

### 5.3 Forgot password — request

> Design a **forgot password screen**. A back arrow in a plain app bar. Centred flat illustration of
> an envelope with a small blue key floating beside it, on an `#E3F2FD` rounded panel. Heading "Forgot
> your password?" Fredoka 24/700 `#0D47A1`. Body "Enter your school code and email and we'll send you
> a reset link." Nunito 15 `#5B6B7B`. Two filled fields, "School code" and "Email". Full-width
> `#2196F3` "Send reset link" button. Below it a subtle text button "Back to sign in". Calm and
> reassuring — lots of whitespace, single column, nothing competing. [style token §4]

### 5.4 Forgot password — confirmation

> Design the **confirmation state** of the forgot-password screen. Replace the form entirely with a
> centred success state: a flat vector of an open envelope with a paper plane flying out, in palette
> blues on an `#E3F2FD` circle. Heading "Check your inbox" Fredoka 22/700 `#0D47A1`. Body "If an
> account exists for that email, we've sent a reset link. It expires in 1 hour." in Nunito 15
> `#5B6B7B`, centred, max 2 lines wide. A full-width outlined button "Back to sign in" with a
> `#2196F3` border and label, plus a small disabled-looking text row "Resend in 0:45" in `#93A2B0`.
> Deliberately **no** green checkmark — the server returns an identical response whether or not the
> account exists, so this is a neutral acknowledgement, not a guarantee. [style token §4]

### 5.5 Reset password

> Design a **set a new password screen**. App bar with a back arrow and the title "New password".
> Small flat illustration of a shield with a keyhole, in blues, about 120px. Heading "Create a new
> password" Fredoka 22/700 `#0D47A1`. Two filled password fields, "New password" and "Confirm new
> password", each with a lock prefix icon and an eye toggle.
>
> Under the first field, a **password strength meter**: a 6px fully-rounded track in `#E3F2FD` with a
> fill that is `#D32F2F` weak, `#F9A825` fair, `#2196F3` good and `#2E7D32` strong, with the word
> label to its right in 13/700. Under that, a checklist of three rules — "At least 8 characters", "One
> number", "Passwords match" — each with a small circle that becomes a filled blue check when
> satisfied. Eight characters is the server's real minimum; do not show a longer requirement.
>
> Add a caption under the button in 13 `#5B6B7B`: "Resetting your password signs you out everywhere."
> — this is literally true; the server revokes every session.
>
> Full-width `#2196F3` "Reset password" button, disabled state in `#90CAF9` with white text. Also show
> an **expired-link variant**: the form replaced by a centred flat illustration of a broken link,
> heading "This link has expired", body "Reset links last 1 hour and can only be used once.", and a
> `#2196F3` "Request a new link" button. [style token §4]

### 5.6 Set password (first login) — three band variants

> Design a **first-time set password screen** for a student who has just been given an account by
> their school, and produce it **three times, one per age band**, as three frames side by side.
>
> Shared skeleton: the owl peeking from the right edge of an `#E3F2FD` illustration panel, a heading,
> a one-line body, two password fields with the strength meter and rule checklist from the previous
> screen, and a full-width `#2196F3` submit button with a small forward arrow.
>
> **Band A (KG–Grade 2):** heading "Make your secret word" Fredoka 28/700, body "Type it twice so we
> know it's you.", fields 64px tall with 17px text, the eye toggle drawn as a large friendly eye icon,
> button label "Let's go!". The mascot is large and central, waving.
> **Band B (Grade 3–5):** heading "Let's set up your password", body "You're almost ready to start
> learning.", button "Start learning".
> **Band C (Grade 6–10):** heading "Set your password", body "Choose a password you don't use anywhere
> else.", no mascot, 22/700 heading, button "Continue", noticeably denser.
> [style token §4]

---

## 6. Shells, profile & global states (PRD §5.2, §5.7, §6.4)

### 6.1 Student shell — bottom navigation, all three bands

> Design the **bottom navigation bar for the student app** as **three variants stacked vertically**,
> each docked on a sample Library screen. Two tabs in every variant — **Library** (open-book icon) and
> **Profile** (smiling avatar icon); the student shell has exactly these two and no more.
>
> **Band A:** bar 84px tall, 28px top radius, icons 32px filled, active icon `#2196F3` on a
> fully-rounded `#E3F2FD` pill with the label in Nunito 13/700 `#0D47A1`, inactive `#93A2B0`. The app
> bar above shows a 40px mascot avatar and "Hi, Aarav!" in Fredoka 24/700.
> **Band B:** bar 72px, icons 26px, same pill treatment, label 12/700. App bar "Hi, Aarav 👋" Fredoka
> 20/700 with a "Let's learn something today" caption and a circular avatar on the right.
> **Band C:** bar 64px, icons 24px — outline when inactive, filled when active — and **no pill**;
> instead a 3px `#2196F3` rounded indicator directly above the active icon. App bar shows just
> "Library" in Fredoka 22/700 with an avatar button; no greeting, no emoji.
>
> All three sit above the safe area, are white, and cast a soft upward shadow `rgba(13,71,161,0.08)`.
> [style token §4]

### 6.2 Teacher shell — bottom navigation

> Design the **bottom navigation bar for the teacher app**, docked on a sample My Classes screen.
> Three tabs: **My Classes** (users icon), **Roster** (list-check icon), **Library** (open-book icon).
> Quieter than any student bar: 64px tall, no pill behind the active icon — a 3px `#2196F3` rounded
> indicator above it instead, active icon and label `#0D47A1`, inactive `#93A2B0`. The app bar above
> shows the screen title in Fredoka 22/700 `#0D47A1` on the left and a circular profile avatar button
> on the right — the teacher's tab set has no Profile tab, so this avatar is the only route to
> sign-out. [style token §4]

### 6.3 Profile — student, younger and older

> Design a **student profile screen** in two variants side by side.
>
> **Younger (Bands A and B):** top is an `#E3F2FD` panel with a 32px bottom radius holding a centred
> 88px circular avatar with a 4px white ring, the student's name "Aarav Sharma" in Fredoka 22/700
> `#0D47A1`, their email in Nunito 14 `#5B6B7B`, and under the name a fully-rounded **role badge**
> reading "STUDENT" in 12/700 white on `#2196F3`. The owl peeks from the panel's bottom-right corner.
>
> **Older (Band C):** no illustrated panel and no mascot — a compact white header card, 64px avatar on
> the left, name in Fredoka 20/700, email beneath, badge on the right.
>
> Both then show one white card, 24px radius, with exactly these rows and no others: **School** (school
> icon, "Green Valley Public School"), **Class** ("Grade 6 - A"), **Roll number** ("21"), **Member
> since** (a date). Each row is icon + label on the left in `#5B6B7B` and value on the right in
> `#12263A` 15/600, separated by 1px `#E3F2FD` dividers. Draw one variant of the card with the Class
> and Roll number rows **absent entirely** — not blank, absent — for a student with no enrollment.
>
> Bottom: a full-width outlined "Sign out" button with a `#D32F2F` border, `#D32F2F` label and a logout
> icon. Content is scrollable and supports pull-to-refresh. [style token §4]

### 6.4 Profile — teacher

> Design a **teacher profile screen**: a compact white header card with a 64px avatar on the left,
> name "Priya Menon" Fredoka 20/700 `#0D47A1`, email beneath, and a "TEACHER" badge in white on
> `#0D47A1`. No mascot, no illustrated panel.
>
> Below it, an information card with rows for **School**, **Member since**, and **Subjects taught** —
> the last rendered as a wrapping row of small fully-rounded `#E3F2FD` chips with `#0D47A1` text
> ("Mathematics", "Science"). Then a settings card with rows "Theme" (a light/dark segmented control)
> and "Help & support", each with a chevron. Bottom: an outlined red "Sign out" button.
>
> Do not include an employee ID, a staff number, a phone number or a notifications toggle — none of
> those exist in this product. [style token §4]

### 6.5 School suspended takeover

> Design a **full-screen blocking state** for when a school's access has been suspended. It replaces
> the whole screen including the bottom navigation. Centred flat vector of a school building with a
> soft closed padlock in front of it, in `#90CAF9` and `#0D47A1` on an `#E3F2FD` circle. Heading
> "Your school's access is paused" Fredoka 22/700 `#0D47A1`. Body "Your school's subscription is
> currently suspended, so lessons aren't available right now. Please ask your school admin to get in
> touch with us." in Nunito 15 `#5B6B7B`, centred, comfortable line height. One single action: an
> outlined `#2196F3` "Sign out" button. **No retry button** — nothing the user does in the app can
> change this. Explanatory and non-alarming: no red, no error icon, no exclamation mark.
> [style token §4]

---

## 7. Library & content (PRD §5.4)

### 7.1 My Library — student, Band A

> Design the **home screen "My Library" for a kindergarten to Grade 2 student (ages 4–7)** — assume
> the child is a beginning reader, so **icons must carry the meaning and text only confirms it**.
>
> App bar: a 44px mascot avatar on the left and "Hi, Aarav!" in Fredoka 28/700 `#0D47A1`.
>
> Under it a single wide **"Today" card** — `#E3F2FD` fill, 28px radius, no gradient, containing the
> owl on the left, the day in Fredoka 20/700 ("Tuesday"), and one line "You have 4 subjects today" in
> Nunito 17. **This card shows no progress bar, no percentage and no resume button** — nothing is
> tracked; it is a friendly header, not a state.
>
> Then a **2-column grid of subject cards**, each 190px tall, white, 28px radius, generous 20px gaps.
> Each card: a centred 80px rounded-square icon tile whose fill is one step of the blue tint ramp
> (`#E3F2FD` → `#90CAF9`) with a big simple `#0D47A1` glyph — a calculator for Maths, a beaker for
> Science, an open book for English, a globe for Social Studies; the subject name centred beneath in
> Fredoka 18/700 `#12263A`; and at the bottom two large count numerals with icons — a play triangle
> with "12" and a document glyph with "8" — **no unit words**. Cards are at least 64px of tappable
> height and visibly pressable.
>
> No search field, no filter chips and no grade line — a five-year-old has exactly one grade. Bottom
> nav docked. [style token §4]

### 7.2 My Library — student, Band B and Band C

> Design the **student "My Library" screen** in **two variants side by side**, sharing one data shape.
>
> **Band B (Grade 3–5):** app bar "Hi, Aarav 👋" Fredoka 20/700 `#0D47A1` with a "Let's learn
> something today" caption and a circular avatar. Section header "My subjects" Fredoka 18/700. A
> **2-column grid of curriculum cards**: white, 24px radius, soft shadow, 150px tall; a 56px
> rounded-square icon tile top-left filled from the blue tint ramp with a flat `#0D47A1` subject
> glyph; the subject name in Fredoka 16/700 `#12263A`; a grade line "Grade 4" in Nunito 13 `#5B6B7B`;
> and at the bottom two small fully-rounded count chips — play-circle "12 videos" and document "8
> docs" — in `#0D47A1` on `#E3F2FD`.
>
> **Band C (Grade 6–10):** app bar title "Library" Fredoka 22/700 with a search icon; a pinned filled
> `#E3F2FD` search field, 16px radius, placeholder "Search subjects". Cards become a **single-column
> list**: white, 20px radius, 88px tall, 48px icon tile on the left, subject name 16/700, a second
> line "Grade 9 · Chapter / Topic" in 13 `#5B6B7B` (that second value is the curriculum's schema name,
> which varies), counts on the right as dense inline text "12 · 8" with tiny icons, and a chevron. No
> mascot, no greeting, no emoji.
>
> Vary only the icon tile tint between cards, staying inside the blue ramp — the cards must read as
> one family. Scrollable, bottom nav docked. [style token §4]

### 7.3 My Library — teacher

> Design the **teacher's "Library" tab**: the same curriculum data as the student library, denser and
> more businesslike. App bar title "Library" with a search icon.
>
> Pinned under the app bar, an **audience segmented control** with two segments, "Student content" and
> "Teacher resources" — the API really does tag every curriculum with one of those two audiences, and
> a teacher can reach both. The selected segment is filled `#2196F3` with white text.
>
> Under it, a **horizontally scrolling grade filter chip row** — "All", "KG", "Grade 1" … "Grade 10".
> There are eleven possible grades, so this row must scroll, must not wrap to two lines, and the
> selected chip is filled `#2196F3` with white text while the rest are `#E3F2FD` with `#0D47A1` text.
>
> Body: single-column rows, white cards, 20px radius, 88px tall, containing a 48px rounded-square
> subject icon tile in `#E3F2FD` with a `#0D47A1` glyph, then two lines — subject name 16/700
> `#12263A` and "Grade 9 · Chapter / Topic" 13 `#5B6B7B` — then a right-hand column of three tiny
> count rows (chapters, videos, documents) as icon plus number in `#5B6B7B`, and a chevron. No mascot,
> no gradients. [style token §4]

### 7.4 Library empty state

> Design the **empty state for the Library screen** — a legitimate, expected state (the school holds
> no content grant yet, or a student has no active enrollment), so it must look designed, not like an
> error.
>
> Produce **three frames**. (a) **Young student:** centred flat vector of the owl sitting on an empty
> bookshelf looking hopeful, in palette blues on a 220px `#E3F2FD` circle; heading "Nothing here yet"
> Fredoka 22/700 `#0D47A1`; body "Your lessons will show up here soon." Nunito 17; an outlined
> `#2196F3` "Refresh" button, 64px tall. (b) **Older student:** the same layout at 180px, heading
> "Nothing here yet", body "Your lessons will appear here as soon as your school adds them.", no
> mascot. (c) **Teacher:** a plain bookshelf illustration at 140px, same heading, body "Content will
> appear here once your school is granted access."
>
> No red, no warning icon, no "error" wording, and **no mention of enrollment or entitlement** — the
> screen cannot tell which of the two causes applies, so the copy must name neither. [style token §4]

### 7.5 Curriculum tree — student, Band A/B

> Design a **curriculum drill-down screen** for a younger student: named levels that expand into
> content rows.
>
> Important: **the level name is not always "Chapter".** Each curriculum defines its own vocabulary —
> "Chapter / Topic", "Unit / Lesson", "Module". Draw the level label as a variable and show "Chapter"
> in one frame and "Unit" in another, so the layout is proven to survive a longer word.
>
> App bar: back arrow, title "Mathematics" Fredoka 20/700, subtitle "Grade 4" in 13 `#5B6B7B`. Under
> it a slim `#E3F2FD` summary strip with two chips — "24 videos" and "16 documents".
>
> Body: a vertical list of **level cards**, white, 24px radius, 16px apart. A collapsed row shows a
> 44px rounded-square number tile ("1", "2", "3") in white on `#2196F3`, the title in 16/700
> `#12263A`, a caption "6 videos · 4 docs" in 13 `#5B6B7B`, and a chevron that rotates when expanded.
>
> Show one card **expanded**: indented sub-level rows with a 2px `#E3F2FD` vertical guide down the
> left, and content rows beneath. A **video row** is a 40px `#E3F2FD` rounded square with a `#2196F3`
> play triangle, the title in 15/600, and the duration "08:24" right-aligned in 13 `#5B6B7B`. A
> **document row** uses a `#90CAF9`-tinted square with a `#0D47A1` file glyph and shows only the title
> — no file size, because the size is not known until the file is opened.
>
> Show three special rows: (a) a **greyed-out, non-expandable level** with zero content — everything
> at 40% opacity, tile in `#E3F2FD` with `#93A2B0` text, no chevron; (b) a **video still processing** —
> the row at 60% opacity, not tappable, with a small fully-rounded `#FFF8E1` chip reading "Getting
> ready" in `#F9A825`; (c) a **failed item** — the same treatment with a `#FDECEA` chip reading
> "Unavailable" in `#D32F2F`. For Band A, auto-expand the first level and use 64px rows.
> [style token §4]

### 7.6 Curriculum tree — Band C student and teacher

> Design the **same curriculum drill-down flatter and denser**, for older students and teachers —
> identical information architecture, different weight. No card per level: full-width list rows
> separated by 1px `#E3F2FD` dividers, 64px tall, with a small level index in `#0D47A1` instead of a
> filled tile, and expanded children indented 16px under a hairline guide. Nesting can be three or
> more levels deep, so show depth 1, 2 and 3 in one frame with progressively deeper indents and a
> smaller type step at each level.
>
> Keep the app bar summary strip. Add a search field pinned under the app bar: filled `#E3F2FD`, 16px
> radius, magnifier prefix, placeholder "Search this curriculum". Add a small right-aligned "Collapse
> all" text button in `#2196F3`.
>
> For the **teacher** frame only, add a fully-rounded `#0D47A1` "Teacher resource" tag on rows whose
> curriculum audience is TEACHER, so a teacher can see at a glance which material is not
> student-facing. No mascot, no colour tiles. [style token §4]

### 7.7 Video player

> Design a **video lesson player screen** in portrait, and produce it for **a Band A/B student and a
> Band C student or teacher** as two frames.
>
> Top: a 16:9 video surface, black, rounded 20px bottom corners, showing a paused frame with a large
> centred circular white play button over a soft `#0D47A1` scrim. Overlay controls along the bottom of
> the video: a fully-rounded scrub bar with an `#E3F2FD` track, a `#2196F3` played portion and a white
> circular thumb; "02:15 / 08:24" timestamps; and white icon buttons for 10s-back, 10s-forward,
> playback speed ("1.0×"), captions and fullscreen. A back arrow and title sit over the top-left on a
> subtle scrim.
>
> **Band A/B:** only four controls — play, 10s-back, 10s-forward, fullscreen — each at least 56px, no
> speed control and no captions toggle, and a chunkier 8px scrub bar with a 20px thumb.
> **Band C:** the full control set at 44px, plus a small "Auto" quality label (the stream is adaptive
> HLS, so quality is automatic — this is a label, not a picker).
>
> Below the player on white: the lesson title in Fredoka 20/700 `#0D47A1`, a breadcrumb caption
> "Mathematics · Chapter 3 · Fractions" in 13 `#5B6B7B`, and the video's description in 15 `#5B6B7B`
> where one exists. Then a section header "More in this chapter" and two compact video rows, each a
> 96×56 rounded thumbnail with a play badge, a two-line title and a duration. **Do not label this "Up
> next" and do not show a watched/unwatched marker** — nothing is tracked; these are simply the
> sibling videos in the same node.
>
> Also produce three states: **buffering** (a circular `#2196F3` spinner over the video, caption
> "Loading your lesson…"), **playback error** (a flat vector of a sad owl with a broken play button,
> heading "This video won't play right now", a `#2196F3` "Try again" button), and **link expired** (an
> `#E3F2FD` panel over the video with a clock glyph, "Your viewing link timed out", body "Tap to keep
> watching — this happens for security every few minutes.", and a `#2196F3` "Resume" button). The
> playback link really does expire in under ten minutes, so the third state is a normal, frequent
> occurrence and must not look like a failure. [style token §4]

### 7.8 Document reader

> Design a **PDF document reader screen**.
>
> App bar: back arrow, the document title truncated to one line in 17/700 `#0D47A1`, and on the right
> an overflow menu plus a download icon. Under it, a slim `#E3F2FD` bar showing "Page 3 of 24" on the
> left and a thin `#2196F3` page-position indicator on the right — this reflects the current page in
> the open document; it is not saved progress.
>
> Body: the rendered page as a white sheet with a 12px radius and soft shadow, floating on an
> `#E3F2FD` background with 16px margins so the page edges read clearly.
>
> A floating bottom control bar: a white fully-rounded pill with soft shadow containing a
> previous-page chevron, a centred tappable "3 / 24" page indicator, a next-page chevron and a
> zoom-fit icon — 56px tall, floating 24px above the safe area. For a Band A/B student, drop the
> zoom-fit icon and enlarge the chevrons to 64px.
>
> Also produce four more states: a **download state** (centred circular determinate progress ring in
> `#2196F3` at 60%, caption "Downloading… 1.4 MB of 2.4 MB", a text "Cancel" button — the file name
> and size are known only once the download starts, which is why they appear here and nowhere
> earlier); an **offline/cached badge** (a small fully-rounded `#E3F2FD` chip with a check and "Saved
> offline"); a **failed download state** (flat vector of a torn document, heading "We couldn't open
> this file", a `#2196F3` "Try again" button); and a **not-ready state** for a document the platform
> is still uploading (a `#FFF8E1` panel, `#F9A825` clock glyph, "This file isn't ready yet", no retry
> button). [style token §4]

### 7.9 Flat video and document lists — not built, design last

> *(PRD §5.4.3. `GET /videos` and `GET /documents` return flat, entitlement-scoped lists carrying
> `contentNodeTitle`, `curriculumId`, `gradeLevelId` and `subjectId` on every row. No screen consumes
> them yet. Design these only after §7.1–§7.8 are settled.)*
>
> Design a **flat "All videos" list screen** for a Band C student. App bar "Videos" with a pinned
> filled `#E3F2FD` search field, placeholder "Search all lessons". Under it a horizontally scrolling
> subject filter chip row. Body: rows 72px tall, each a 64×40 rounded thumbnail with a play badge, a
> one-line title in 15/600, a second line "Mathematics · Fractions" in 13 `#5B6B7B` naming the subject
> and the containing chapter, and a right-aligned duration. Include the "no results" state: a
> magnifier illustration, "No lessons match", and a "Clear search" text button. Produce a
> **documents** variant of the same screen with a file glyph instead of a thumbnail and no duration.
> [style token §4]

---

## 8. Teacher-only screens (PRD §5.5)

### 8.1 My Classes

> Design a **"My Classes" screen for a teacher** — a list of the subject-and-section pairs they teach.
>
> App bar: "My Classes" Fredoka 22/700 `#0D47A1`, avatar button on the right. Under it a caption row:
> "6 assignments" in 13 `#5B6B7B`.
>
> Body: a single-column list of **assignment cards**, white, 20px radius, soft shadow, 16px apart.
> Each card: a 48px rounded-square subject icon tile on the left in `#E3F2FD` with a `#0D47A1` glyph;
> the primary line "Mathematics — Grade 5 - A" in 16/700 `#12263A`; a secondary line with two small
> fully-rounded chips, "Grade 5" and "Section A", in `#0D47A1` on `#E3F2FD`.
>
> Show **two distinct row forms**, because both really occur: the normal one above, and a
> **school-wide** one reading "Science — all sections" whose chip row is replaced by a single caption
> with a small info icon and the text "You teach this subject across the whole school" in 13
> `#5B6B7B`, with the icon tile tinted `#90CAF9` to differentiate it. The second form comes from a
> legacy bulk import where the grade and section are genuinely absent — a valid assignment, not an
> error, so it must not carry a warning colour.
>
> Also show a card for a **kindergarten** assignment reading "English — KG - A", to prove the layout
> holds when the grade name is two characters rather than eight.
>
> The cards are **not tappable** — no chevron, no ripple. Include an empty state: flat vector of an
> empty classroom, "No classes assigned yet", "Your school admin will assign your classes soon."
> [style token §4]

### 8.2 My Students — roster

> Design a **searchable, paginated student roster screen for a teacher**. Read-only — there must be
> **no add, edit, delete or reset-password affordance anywhere**, and no floating action button.
>
> App bar: "My Students" Fredoka 22/700 `#0D47A1`.
>
> Pinned under it: a **search field** — filled `#E3F2FD`, 16px radius, 48px tall, magnifier prefix,
> placeholder "Search by name, email or roll number", clear "×" when filled — and beside it a
> **section filter button**: a fully-rounded outlined pill with a filter icon and the label "All
> sections", which becomes filled `#2196F3` with white text and a small count badge when a filter is
> active. Under those, a result count line "148 students" in 13 `#5B6B7B`.
>
> Body: **student rows**, white cards, 16px radius, 76px tall, 12px apart. Each row: a 44px circular
> avatar showing initials in `#0D47A1` on `#E3F2FD`; the name in 15/700 `#12263A`; a second line with
> the email in 13 `#5B6B7B` and, where one exists, a roll number as a small suffix "· Roll 21"; and on
> the right a small fully-rounded section tag reading "Grade 6 - A" in `#0D47A1` on `#E3F2FD`. No
> chevron — rows are not tappable.
>
> Show four special rows: an **unplaced student** whose tag reads "Unassigned" in `#5B6B7B` on a
> neutral `#F1F4F7` chip; one whose name is missing so it falls back to the email; a **pending**
> student with a small `#FFF8E1` "Invited" chip in `#F9A825` beside the name, for an account never
> activated; and a **disabled** student rendered at 55% opacity with a `#F1F4F7` "Disabled" chip. Also
> show one row tagged "KG - A" — grade names are short at one end of the ladder and the tag must not
> collapse.
>
> At the bottom, the **pagination footer** in three stacked variants: (a) a centred small `#2196F3`
> spinner with "Loading more…"; (b) a failed state — a centred `#FDECEA` rounded panel with "Couldn't
> load more students" and a `#D32F2F` "Tap to retry" label; (c) an end state — a centred 13 `#93A2B0`
> caption "That's everyone". [style token §4]

### 8.3 Section filter bottom sheet

> Design a **bottom sheet for picking a section filter**, opened from the roster. The sheet is white
> with a 28px top radius, a 40×4 `#E3F2FD` rounded drag handle centred at the top, and a title row
> "Filter by section" in Fredoka 18/700 `#0D47A1` with a "Clear" text button on the right in
> `#2196F3`.
>
> A school runs KG through Grade 10, so this list can be forty rows long. Design for that: a filled
> `#E3F2FD` search field pinned under the title with placeholder "Find a section", and the rows
> **grouped under sticky grade headers** — "KG", "Grade 1", … "Grade 10" — each header 32px tall in
> Nunito 12/700 uppercase letter-spaced `#5B6B7B` on white with a hairline above.
>
> Rows are 56px: the section label "Grade 6 - A" in 15/600 on the left, a small `#5B6B7B` caption "32
> students" beneath it, and on the right a radio indicator — an empty 22px `#90CAF9` ring when
> unselected, a filled `#2196F3` circle with a white check when selected. The selected row's
> background is `#E3F2FD` at 16px radius. A pinned first row above the groups reads "All sections".
>
> Bottom: a full-width `#2196F3` "Apply" button above the safe area, with the dimmed scrim visible
> behind the sheet. The sheet opens at roughly 60% height and is draggable to full.
>
> Also produce two alternate states: a **loading** one with four shimmer placeholder rows, and an
> **error** one with a centred "Couldn't load sections" and a `#2196F3` "Try again" text button.
> [style token §4]

### 8.4 Roster empty states

> Design **two empty states for the student roster**, side by side as separate screens.
>
> (a) **No matches** — shown when a search or section filter is narrowing the list: centred flat
> vector of a magnifier over an empty list, in palette blues; heading "No students match" Fredoka
> 20/700 `#0D47A1`; body "Try a different name, or clear your filters."; an outlined `#2196F3` "Clear
> filters" button.
>
> (b) **No students at all** — shown when nothing is narrowing the list: centred flat vector of an
> empty classroom with tidy desks; heading "No students yet"; body "Students will appear here once
> your school adds them."; and **no button at all**, because there is nothing for the teacher to
> clear. [style token §4]

---

## 9. Shared states, components & variants

### 9.1 Generic error + retry

> Design a **generic error state body** used inside any screen when a request fails. Centred within
> the content area, not full-bleed: a 160px flat vector of a friendly owl holding a disconnected plug,
> in palette blues on an `#E3F2FD` circle; heading "Something went wrong" Fredoka 20/700 `#0D47A1`;
> body "We couldn't load this right now. Check your connection and try again." in Nunito 15 `#5B6B7B`,
> centred; a filled `#2196F3` "Try again" button, 200px wide, with a refresh icon.
>
> Produce four variants of the same layout differing only in glyph and copy: **no internet** (a cloud
> with a slash), **server error** (a server rack with a wrench), **rate limited** (a stopwatch, copy
> "Too many attempts — try again in 30 seconds", button disabled in `#90CAF9`), and **permission
> denied** (a padlock, copy "You don't have access to this").
>
> Then produce a **Band C / teacher variant** of the first one with no owl — a plain geometric glyph
> at 120px, tighter spacing, and no exclamation in the copy. [style token §4]

### 9.2 Not found (404)

> Design a **"not found" state**. Centred flat vector of an open book with blank pages and a small
> question mark, in palette blues. Heading "We couldn't find that" Fredoka 20/700 `#0D47A1`. Body
> "This lesson may have been moved or removed." in Nunito 15 `#5B6B7B`. A single outlined `#2196F3`
> "Go back" button. **No retry button**, and no wording suggesting permission, blocking or refusal —
> the server answers 404 both for "no such thing" and "not yours", so this screen must never read as
> "you're not allowed". [style token §4]

### 9.3 Loading skeletons

> Design **loading skeleton screens** for four layouts, as one output: (a) the student library
> 2-column card grid, (b) the teacher library single-column list, (c) the teacher roster list, (d) the
> curriculum tree level list. Skeleton blocks are `#E3F2FD` with 12px radius and a subtle
> left-to-right white shimmer sweep; keep the exact geometry of the real content so nothing shifts
> when it loads. No spinners — the shimmer is the loading affordance. Three to six placeholder items
> per layout.
>
> Keep the skeletons **age-band-neutral**: the app does not yet know the student's grade while the
> first request is in flight, so use the mid-band geometry for all of them and do not draw an
> oversized Band A tile that would pop when the real data arrives. [style token §4]

### 9.4 Snackbars, dialogs & toasts

> Design the **feedback components** for Smart Teacher on one sheet: (a) a success snackbar — a
> fully-rounded `#0D47A1` pill floating 16px above the bottom nav, white text, a white check icon and
> a `#90CAF9` action label; (b) an error snackbar — same shape in `#D32F2F`; (c) a confirmation
> dialog — white, 28px radius, a 56px `#E3F2FD` circular icon at the top, title in Fredoka 18/700
> `#0D47A1`, body in Nunito 15 `#5B6B7B`, and two buttons side by side: a text "Cancel" in `#5B6B7B`
> and a filled `#2196F3` confirm (show the destructive `#D32F2F` variant too, labelled "Sign out");
> (d) a pull-to-refresh indicator — a `#2196F3` circular spinner on an `#E3F2FD` circle.
> [style token §4]

### 9.5 Dark mode

> Produce a **dark mode variant** of the design system and apply it to four screens: the Band A
> student library, the Band C student library, the curriculum tree and the teacher roster. Dark
> palette derived from the same hues: `#0A1929` page background, `#12263A` elevated surfaces and
> cards, `#1B3A5C` tinted surfaces (the dark counterpart of `#E3F2FD`), `#2196F3` still the primary
> action colour, `#90CAF9` for headings and links (never `#0D47A1` on dark — it fails contrast), text
> `#E8F1FA` primary and `#9FB3C8` secondary. Shadows become a 1px `#1B3A5C` hairline. The subject tint
> ramp inverts to five steps — `#1B3A5C`, `#22496F`, `#2A5882`, `#316795`, `#3876A8` — with `#90CAF9`
> glyphs. Illustrations keep their blues but drop white highlights to `#E8F1FA` and sit on `#1B3A5C`
> circles. [style token §4]

### 9.6 Component / style sheet

> Produce a **design system sheet** for Smart Teacher showing every reusable component in one screen,
> in labelled sections: colour swatches with hex values (`#E3F2FD`, `#90CAF9`, `#2196F3`, `#0D47A1`,
> the five-step subject tint ramp, and the text and semantic neutrals); the type scale (Fredoka
> H1/H2/H3, Nunito body/caption/button) with sizes and weights labelled **for all three age bands side
> by side**; buttons in filled, outlined, text, icon and disabled states, default and pressed; text
> fields in rest, focused, filled, error and disabled; chips in default and selected; the count chip,
> the role badge, the section tag and the status chip (Invited / Disabled / Getting ready /
> Unavailable); the card, the list row, the bottom sheet handle, the tab bar (student Band A, student
> Band C and teacher variants), the password strength meter and the avatar. Label every component with
> its name. [style token §4]

### 9.7 Retired: the "coming soon" content stub

The previous revision included a stub screen for the unbuilt player and reader. The video player
(§7.7) and document reader (§7.8) are now being built, and `ComingSoonView`'s last use disappears with
them — per [CLAUDE.md](../CLAUDE.md), that deletion is the signal that PRD §5.4 is done. **Do not
design a new "coming soon" screen.** An unentitled school and an unenrolled student are legitimate
zero-content states with real UI of their own (§7.4).

---

## 10. Follow-up prompts for iterating in Stitch

Fire these at whichever screen needs correcting rather than regenerating it:

- `Keep the layout but make the corner radii larger and the shadows softer — everything rounder and lighter.`
- `Remove all colours outside my palette. Only #E3F2FD, #90CAF9, #2196F3, #0D47A1 and neutral greys.`
- `Redo this for age band A: bigger type, 64px targets, six-word copy, icons carrying the meaning, mascot present.`
- `Redo this for age band C: no mascot, tighter rows, pinned search, informational copy, 48px targets.`
- `You added a progress bar. Remove it — this product tracks no progress. Replace it with nothing.`
- `The nesting label is a variable, not the word "Chapter". Show it once as "Unit" and once as "Module".`
- `This grade chip row wraps to two lines. Make it a single horizontally scrolling row holding eleven chips from KG to Grade 10.`
- `Replace the photograph with a flat vector illustration in the palette blues.`
- `Increase the contrast of the secondary text — it needs to pass WCAG AA on white.`
- `Show me this screen's empty, loading and error states as three separate frames.`
- `Give me the dark mode version of this exact screen.`
- `Show the same screen at 320px width so I can check it doesn't overflow on small phones.`
- `Show this screen with the longest realistic strings: a 40-character subject name and a "Grade 10 - D" section tag.`

---

## 11. Mapping the output back to Flutter

The generated design has to land on the existing token layer, not on hard-coded widget colours — see
[CLAUDE.md](../CLAUDE.md) "Theming".

| Stitch output | Where it goes |
|---|---|
| `#2196F3` | `AppColors.seed` in [app_colors.dart](../lib/src/core/theme/app_colors.dart) — the whole `ColorScheme.fromSeed` derives from it |
| `#0D47A1` / `#90CAF9` / `#E3F2FD` and the subject tint ramp | Named constants alongside the seed |
| Radii, spacing, durations | `AppConstants` in [app_constants.dart](../lib/src/core/constants/app_constants.dart) — never raw numbers in widgets |
| Fredoka / Nunito | `google_fonts` inside [AppTheme](../lib/src/core/theme/app_theme.dart) `textTheme`, not per-widget |
| **The three age bands (§2.2)** | **A new `AgeBand` enum plus a band-scoped token set resolved once and read like `AppConstants` — see the note below** |
| Dark palette (§9.5) | The dark `ColorScheme` branch of `AppTheme`, driven by the existing `ThemeController` |
| Buttons, fields, cards | Component themes on `ThemeData` so screens stay style-free |
| Empty / error / not-found art | Reuse `ErrorRetryView`, `NotFoundView`, `SchoolSuspendedView` — swap the illustration, don't fork per screen |

**On implementing the bands.** They are a theme concern, not a screen concern: the derivation in §2.3
belongs in one provider that reads `GET /curricula` and `GET /grade-levels` and answers with an
`AgeBand`, defaulting to `AgeBand.learners`. Screens then read band tokens the way they already read
`AppConstants`. Three forked copies of `LibraryScreen` would be the wrong shape, exactly as
`shellTabsFor` is the single place allowed to branch on role.

**Two things worth deciding before you start generating:** whether illustrations export as SVG (needs
`flutter_svg`, not currently a dependency) or PNG, and whether the owl is commissioned once as a
sprite set — Stitch's illustration output is a good direction-setter but rarely production-ready art.
