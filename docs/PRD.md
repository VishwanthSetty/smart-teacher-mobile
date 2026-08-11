# Product Requirements Document
## Flutter Mobile App — Teacher & Student Experience

| | |
|---|---|
| **Document owner** | Mobile team |
| **Status** | Draft v1 — ready for sprint scoping |
| **Date** | 2026-08-10 |
| **Platform** | Flutter (iOS + Android) |
| **Backend** | `apps/api` (existing, no changes required to start) |
| **Reference source** | Flutter mobile app feature list, 2026-08-10 |

---

## 1. Overview

We are building a new native mobile app (`apps/mobile`) for two existing user roles — **TEACHER** and **STUDENT** — that consumes the existing `apps/api` backend directly. The backend and the web app (`apps/web`) are already built and live; this PRD scopes the **mobile client only**. No backend changes are required to begin, though §9 lists small backend gaps worth tracking in parallel.

`SCHOOL_ADMIN` and `SUPER_ADMIN` are **not** in scope for mobile. Video playback and PDF/document reading surfaces are **explicitly out of scope** for this phase — the app should get the user to "here's the entitled item" and stop at a stub screen.

### 1.1 Why this document exists
To give engineering an unambiguous, screen-by-screen and endpoint-by-endpoint spec so the Flutter build can start without needing to re-derive behavior from the backend or the web app.

### 1.2 Key architectural difference from the web app
`apps/web` is a BFF: the browser never holds a JWT — Next.js route handlers do, via httpOnly cookies. Flutter has no browser and no BFF tier, so **the mobile app talks to `apps/api` directly** over `Authorization: Bearer <token>`, and **the app itself is the token holder**. This is the single biggest behavioral difference from the web app; everything else (roles, entitlement logic, error shapes, response bodies) is shared and should behave identically to what the web app already does.

---

## 2. Goals

- Ship a native mobile client for TEACHER and STUDENT that reaches full functional parity with what those two roles can already do on web, **excluding** the video player and document reader.
- Implement a secure, self-contained auth/token lifecycle on-device (login, silent refresh, logout, forgot/reset password).
- Correctly reflect server-side entitlement scoping (§4) in the UI without re-implementing any of that logic client-side.
- Ship a stable, reusable data/error layer (one HTTP client, one error mapper, one paginated-list widget) so later features (player, reader, notifications) can be added without refactoring the foundation.

### 2.1 Non-goals (explicitly out of scope for this release)
- Video playback UI/player (HLS, poster, playback-token consumption).
- Document/PDF reader UI (beyond a "get a signed download link" action).
- SCHOOL_ADMIN or SUPER_ADMIN screens, bulk import, admin stats.
- Attendance, gradebook, timetable, quizzes, submissions, progress tracking — **none of these exist in `apps/api` today**; they are not mobile scoping gaps, they are unbuilt backend features.
- Push notifications, offline caching — not built in this phase (flagged as future work, §9.4).
- Student self-enrollment/roster visibility — blocked on a backend gap, see §9.1.

---

## 3. Personas

| Persona | Description | Primary jobs in the app |
|---|---|---|
| **Teacher** | School-employed teacher, assigned to 0+ subject/section pairs | Check who I teach, browse my roster, browse curricula/content for my grades & subjects |
| **Student** | Enrolled student with an active enrollment (grade level) | Browse my library (curricula scoped to my grade), open content items |

---

## 4. Entitlement model (read this before designing any content screen)

This is enforced **entirely server-side** by `ActorContentScopeService.resolve()`. The app must never attempt to re-filter "is my school entitled to this" — it renders exactly what `/curricula`, `/videos`, `/documents` return, and treats an empty response as a legitimate empty state, not an error.

| Role | Scoping rule |
|---|---|
| **STUDENT** | Narrowed to their **active enrollment's grade level** ∩ school entitlements ∩ `STUDENT`-audience curricula only. **No active enrollment → empty library** (not the full school catalog). |
| **TEACHER** | If they have ≥1 grade-bearing `TeacherAssignment`: sees `TEACHER`-audience curricula + any `STUDENT`-audience curriculum matching a `(gradeLevel, subject)` they teach. If they have **zero** assignments: falls back to the school's **full** entitlement set (so a newly onboarded teacher isn't blanked out). |
| **Both** | A school with zero entitlements → empty library for everyone. Expected, not a bug. |

**Single-item reads never leak more than the list.** `GET /videos/:id`, `GET /curricula/:id/tree` return a plain `404` for "doesn't exist" **and** for "exists but you're not entitled." The app must **never** attempt to distinguish these or imply "you're not allowed" — always render a generic "not found" state. This is a deliberate backend policy (404-not-403), not a bug to work around.

---

## 5. Functional requirements

Each item below maps 1:1 to a screen or a piece of app behavior. Priority: everything in §5 is v1 unless marked otherwise.

### 5.1 Authentication & session (shared)

#### 5.1.1 Login
- **Fields:** email, password, school slug (schools are multi-tenant; email is unique *per school*, not globally), "Forgot password?" link.
- **Call:** `POST /auth/login` `{ email, password, schoolSlug }` → `{ accessToken, refreshToken }`.
- **Error states to design explicitly:**
  - `401` — invalid credentials → generic message, never reveal whether it was the email, password, or slug that was wrong.
  - `403` — account disabled / school suspended → distinct, actionable message ("this account is disabled" / "contact your school admin").
  - `429` — locked out (20 failed attempts / 50 min window) → "too many attempts, try again later" state, not a raw error toast.
- On success: persist both tokens to secure storage, fetch `GET /users/me`, route to the correct home shell by role (§5.6).

#### 5.1.2 Silent session refresh
- No dedicated screen — this is interceptor behavior, not a UI flow.
- **Call:** `POST /auth/refresh`, bearer = refresh token → new `{ accessToken, refreshToken }` (old refresh token is revoked server-side — rotation, not reuse).
- Triggered on any `401` from any authenticated call. Pause in-flight requests, refresh once, persist the rotated pair, retry the original request once.
- If refresh itself fails (revoked / reused / expired token) → force logout, clear storage, route to `/login`. Do not retry a second time or loop.

#### 5.1.3 Logout
- **Call:** `POST /auth/logout` `{ refreshToken? }` → `204`.
  - Omit `refreshToken` → kills *all* sessions for the user ("log out everywhere" — nice-to-have toggle, not required for v1).
  - Include it → kills only this device's session (default v1 behavior).
- **Important:** clear secure storage and navigate to `/login` **immediately**, regardless of whether the network call succeeds. Do not block the logout UX on network round-trip.

#### 5.1.4 Forgot / reset password
- **Screen 1 (request):** email + school slug → `POST /auth/forgot-password` `{ email, schoolSlug }` → always `200` with a generic message ("if this account exists, we've sent a reset link"). Never reveal account existence. Rate-limited independently from login lockout — design a `429` state here too.
- **Screen 2 (reset):** token (arrives via emailed deep link — see §9.2 for the mobile deep-link gap) + new password → `POST /auth/reset-password` `{ token, password }` → `204`.
- On success: **all** of that user's sessions are revoked server-side. Route to `/login`, not back into the authenticated app — there is no session left to resume.

#### 5.1.5 First-login / set password (conditional — confirm before building)
- Only relevant if the school still uses an invite-email flow instead of directly issuing a password. **Confirm current admin practice before scoping this into a sprint** — may not be needed.
- If needed: token (from emailed link) + new password → `POST /auth/set-password` `{ token, password }` → `204`.

### 5.2 Profile ("Me") — shared
- **Screen:** name, email, role badge, school name.
- **Call:** `GET /users/me` → `MeEntity` (see §8.2 for shape).
- **Suspended-school handling:** if `school.status === 'SUSPENDED'`, every subsequent call 403s for the remainder of the access-token lifetime. If the app sees this 403 pattern repeat across calls, surface a dedicated "your school's access is suspended — contact your admin" screen rather than a generic error on every screen.

### 5.3 Taxonomy lookups — shared, supporting data only
- `GET /subjects`, `GET /grade-levels` — flat, unpaginated catalog lists, available to every role. Used for labels and any client-side filter UI you build on top of the (already server-scoped) curricula list. Not a screen on their own.

### 5.4 Curricula & content browsing — shared shape, role-scoped by the server (§4)

#### 5.4.1 Curriculum list ("My Library")
- **Screen:** list of curricula (grade × subject), each row showing node/video/document counts.
- **Call:** `GET /curricula` (optional `?audience=STUDENT|TEACHER` filter) → `CurriculumEntity[]` (§8.3).

#### 5.4.2 Curriculum tree (chapters/topics/content)
- **Screen:** drill-down tree — chapters → sub-topics → videos/documents at each level.
- **Call:** `GET /curricula/:id/tree` → recursive `ContentTreeEntity`; each node carries its own `videos[]`/`documents[]` plus `videoCountDeep`/`documentCountDeep`, so empty branches can be greyed out/collapsed without a client-side walk.
- Tapping a video/document row is the handoff point to the (out-of-scope) player/reader. **v1 behavior: navigate to a stub screen carrying the item id** ("Playback coming soon" / "Reader coming soon").
- `404` on this endpoint → generic "not found," per §4's non-distinguishing policy.

#### 5.4.3 Flat video/document lists (search/recents use case)
- `GET /videos` → `VideoEntity[]`, `GET /videos/:id` → single.
- `GET /documents` → `DocumentEntity[]`, `GET /documents/:id` → single.
- Both carry `contentNodeId` / `contentNodeTitle` / `curriculumId` / `gradeLevelId` / `subjectId` denormalized, so a flat row can be labeled without a second call to the tree.
- **Document "open externally" action (optional, v1.1):** `GET /documents/:id/download` → `{ url, expiresInSecs, fileName }`, a short-lived signed URL. Only needed if you want a share/open-in-browser action; otherwise skip, since the reader itself is out of scope.
- **Video playback token:** `GET /videos/:id/playback-token` exists but is explicitly out of scope — do not build anything against it this phase.

### 5.5 TEACHER-only features

#### 5.5.1 My Classes (assignments)
- **Screen:** list of `(subject, section/grade)` pairs the teacher is assigned to.
- **Call:** `GET /teacher-assignments?teacherId={me.id}` → `TeacherAssignmentEntity[]` (§8.4).
- **Must-implement detail:** this endpoint is **not** auto-scoped to "my own" — a bare call with no `teacherId` returns every assignment in the school. **Always pass `teacherId=<me.id>` from `/users/me`.** Also supports `sectionId` / `subjectId` / `gradeLevelId` filters for a "browse by class" view if desired.
- **UI edge case:** `sectionId`/`sectionName`/`gradeLevelId`/`gradeLevelName`/`sectionLabel` can all be `null` together — this represents a legacy school-wide "teaches this subject" grant (predates sections, from bulk CSV import). Design the row to render two distinct forms: "Mathematics — all sections" vs. "Mathematics — Grade 5 - A".

#### 5.5.2 My Students (roster, read-only)
- **Screen:** searchable/filterable, paginated roster. Recommend defaulting the filter to a section the teacher actually teaches (client-side, using `sectionId` values pulled from §5.5.1 — the API itself does not auto-narrow by teacher).
- **Call:** `GET /students?page=&limit=&search=&sectionId=&status=` → `PaginatedStudentsEntity`. Default `limit=20`, max `100`.
- `enrollment` is `null` for an unplaced student — handle in the row UI (e.g., "Unassigned").
- **Read-only.** No create/edit/deactivate/password-reset actions exist for TEACHER (`PATCH /students/:id` and password routes are SCHOOL_ADMIN-only). Do not design any write affordance on this screen.

#### 5.5.3 Sections (supporting lookup)
- `GET /sections` → `SectionEntity[]`. Used to populate the "filter by section" picker on the roster screen, since `/students` takes `sectionId` as an opaque filter rather than returning a joined section list.

#### 5.5.4 Explicitly not building for TEACHER
No `/admin/*` routes, no `/admin/stats`, no bulk-import UI (SCHOOL_ADMIN-only, web-only for now). **Do not build attendance, gradebook, or timetable screens — none of these exist in the backend.** If any land on the roadmap later, they require new backend work first; this PRD only covers what `apps/api` exposes today.

### 5.6 STUDENT-only features
Students have **no student-specific endpoints** — the entire student experience is the shared browsing surface (§5.4), narrowed server-side (§4).

- Flow: Login → Profile (`/users/me`) → Library (`/curricula`, narrowed to enrolled grade) → Curriculum tree (`/curricula/:id/tree`) → video/document rows (stubbed).
- **No self-service roster/grade/section view exists yet** — a student cannot see their own section/grade/roll-number via any current API, even though their *content* is already correctly scoped to it. See §9.1 for the small backend addition this needs.
- **No write actions** anywhere for STUDENT in the current API surface (no submissions, no progress tracking, no quizzes — none of it exists in `apps/api` today).

### 5.7 Role-based navigation shell
Two home shells, selected off `MeEntity.role` immediately after login — never hardcode a role assumption anywhere else in the app:

| Role | Tabs |
|---|---|
| **Teacher** | My Classes · Roster · Library |
| **Student** | Library · Profile |

---

## 6. Non-functional requirements

### 6.1 Security
- Store `accessToken` and `refreshToken` in **encrypted, OS-backed secure storage** (`flutter_secure_storage` → Keychain on iOS, Keystore on Android). **Never** `SharedPreferences` in plaintext, never logged (including crash reports/analytics breadcrumbs).
- All API calls over HTTPS in any non-local environment.
- CORS is irrelevant to mobile (browser-only mechanism) — nothing to configure server-side specifically for the app.

### 6.2 HTTP client & interceptor
- Single Dio (or equivalent) instance, single interceptor responsible for:
  1. Attaching `Authorization: Bearer <accessToken>` to every request.
  2. On `401`: pause in-flight requests → call `POST /auth/refresh` once → persist rotated pair → retry the failed request(s) once. On refresh failure → force logout.
- This interceptor is the **one and only** place refresh logic lives — no per-screen retry logic.

### 6.3 Error handling
- The API's `ApiErrorResponse` shape (from `HttpExceptionFilter`) is consistent across every endpoint — build **one** error-parsing helper, not per-screen try/catch duplication.
- Standard mapping:

| Status | App behavior |
|---|---|
| `401` | Attempt one silent refresh (§6.2); if that fails, force logout |
| `403` | Role/entitlement/suspension message — check for the "school suspended" pattern (§5.2) first |
| `404` | Generic "not found" — **never** imply "you're not allowed" (server's 404-not-403 policy, §4) |
| `429` | Rate-limit message with a retry hint (varies by endpoint — login lockout ≠ forgot-password rate limit) |

### 6.4 Empty states
An unentitled school and an unplaced/unenrolled student are both **legitimate, expected** zero-content states (§4) — design first-class empty-state UI for each, not a generic error screen.

### 6.5 Pagination
Only `GET /students` is paginated today (`page`/`limit`, max `100`). Build **one** reusable paginated-list widget for that screen; every other list endpoint (`/curricula`, `/videos`, `/documents`, `/teacher-assignments`, `/sections`) returns a flat, unpaginated array — don't build pagination affordances for those.

### 6.6 Auth state / routing
A single session notifier (Riverpod/Bloc — match whatever the team already standardizes on) gates a router redirect to `/login` whenever there's no valid session — equivalent in shape to `middleware.ts`'s gate on `/dashboard/*` in the web app.

---

## 7. Screen inventory (build checklist)

| # | Screen | Role | API(s) | Notes |
|---|---|---|---|---|
| 1 | Login | Both | `POST /auth/login` | Includes school slug field |
| 2 | Forgot password (request) | Both | `POST /auth/forgot-password` | Generic success always |
| 3 | Reset password | Both | `POST /auth/reset-password` | Deep-link entry, §9.2 |
| 4 | Set password (conditional) | Both | `POST /auth/set-password` | Confirm need first |
| 5 | Profile / Me | Both | `GET /users/me` | Suspended-school detection |
| 6 | Library (curriculum list) | Both | `GET /curricula` | Server-scoped per role |
| 7 | Curriculum tree | Both | `GET /curricula/:id/tree` | Stub player/reader on tap |
| 8 | Video/Document stub detail | Both | `GET /videos/:id`, `GET /documents/:id` | Out-of-scope player behind this |
| 9 | My Classes | Teacher | `GET /teacher-assignments?teacherId=` | Must pass own id |
| 10 | My Students (roster) | Teacher | `GET /students`, `GET /sections` | Paginated, read-only |

---

## 8. API & data reference

### 8.1 Base URL
`http://<api-host>:4000` in dev; `API_URL` env value in prod/staging. No BFF layer — calls go straight to `apps/api`.

### 8.2 `MeEntity`
```json
{
  "id": "...", "email": "...", "name": "...",
  "role": "TEACHER | STUDENT",
  "schoolId": "...",
  "school": { "id": "...", "name": "...", "slug": "...", "status": "ACTIVE | SUSPENDED" }
}
```

### 8.3 `CurriculumEntity`
```json
{
  "audience": "STUDENT",
  "id": "...", "gradeLevelId": "...", "gradeLevelName": "Grade 5",
  "subjectId": "...", "subjectName": "Mathematics",
  "schemaId": "...", "schemaName": "...",
  "status": "PUBLISHED",
  "publishedAt": "2026-01-01T00:00:00Z",
  "nodeCount": 12, "videoCount": 8, "documentCount": 3
}
```

### 8.4 `TeacherAssignmentEntity`
```json
{
  "id": "...", "teacherId": "...", "teacherName": "...", "teacherEmail": "...",
  "subjectId": "...", "subjectName": "Mathematics", "subjectCode": "MATH",
  "sectionId": "...", "sectionName": "A",
  "gradeLevelId": "...", "gradeLevelName": "Grade 5",
  "sectionLabel": "Grade 5 - A",
  "createdAt": "..."
}
```

### 8.5 `StudentEntity` (inside `PaginatedStudentsEntity`)
```json
{
  "id": "...", "email": "...", "firstName": "...", "lastName": "...", "name": "...",
  "status": "ACTIVE | PENDING | DISABLED",
  "activatedAt": "...", "createdAt": "...",
  "enrollment": {
    "id": "...", "sectionId": "...", "sectionName": "A",
    "gradeLevelId": "...", "gradeLevelName": "Grade 5", "rollNumber": "..."
  }
}
```

### 8.6 Full endpoint reference (TEACHER / STUDENT reachable only)

| Method & path | Roles | Purpose |
|---|---|---|
| `POST /auth/login` | public | Login, requires `schoolSlug` |
| `POST /auth/refresh` | public (refresh token) | Rotate tokens |
| `POST /auth/logout` | any | Revoke session(s) |
| `POST /auth/forgot-password` | public | Request reset email |
| `POST /auth/reset-password` | public | Consume reset token |
| `POST /auth/set-password` | public | Consume invite/activation token |
| `GET /users/me` | any | Profile + school |
| `GET /users/:id` | any (self, or admin for others) | Single user lookup |
| `GET /subjects` | any | Subject catalog |
| `GET /grade-levels` | any | Grade level catalog |
| `GET /curricula` | SCHOOL_ADMIN, TEACHER, STUDENT | Entitled curricula list |
| `GET /curricula/:id/tree` | SCHOOL_ADMIN, TEACHER, STUDENT | Chapters/topics + content |
| `GET /videos` | SCHOOL_ADMIN, TEACHER, STUDENT | Flat entitled video list |
| `GET /videos/:id` | SCHOOL_ADMIN, TEACHER, STUDENT | Single video |
| `GET /documents` | SCHOOL_ADMIN, TEACHER, STUDENT | Flat entitled document list |
| `GET /documents/:id` | SCHOOL_ADMIN, TEACHER, STUDENT | Single document |
| `GET /documents/:id/download` | SCHOOL_ADMIN, TEACHER, STUDENT | Signed download URL (optional, v1.1) |
| `GET /teacher-assignments?teacherId=` | SCHOOL_ADMIN, TEACHER | Teacher's own taught classes |
| `GET /sections` | SCHOOL_ADMIN, TEACHER | Section lookup for filters |
| `GET /students?...` | SCHOOL_ADMIN, TEACHER | Paginated roster, read-only for TEACHER |

*Deliberately excluded from mobile scope: everything under `/admin/*`, `/teachers/*` write routes, `/students` writes, video playback-token/HLS/poster routes, and anything SUPER_ADMIN/SCHOOL_ADMIN-only — none of it is reachable by a TEACHER or STUDENT token.*

---

## 9. Known backend gaps (tracked, not blockers for starting mobile)

These don't block the Flutter build from starting, but should be filed as backend tickets in parallel so they land before the screens that need them ship.

1. **No student self-enrollment endpoint.** `GET /students` is SCHOOL_ADMIN/TEACHER-only; `GET /users/me` has no grade/section/roll-number. A STUDENT app currently cannot display "which grade/section am I in," even though their *content* is already correctly scoped to it server-side. **Suggested fix:** add an `enrollment` field to `MeEntity` for STUDENT actors, mirroring `StudentEntity.enrollment`. Small, additive change.
2. **Password-reset and invite links are email deep-links.** Needs a decision on the mobile deep-link scheme (e.g. `smartteacher://reset-password?token=...`) and coordination with whatever mail templates currently point at the web app — or accept reset/activation happening in a mobile browser tab that hands back to the app. Coordination item with `apps/api/src/mail`, not an API change.
3. **`GET /teacher-assignments` has no "mine" shortcut.** Every call must pass `teacherId` explicitly (§5.5.1). Not broken, just a footgun — a convenience `GET /teacher-assignments/mine` would be a nice-to-have.
4. **Not built anywhere in `apps/api`:** push notifications, offline caching, attendance, gradebook, quizzes, timetables. If any of these land on the mobile roadmap, they are new backend features first, not mobile scoping work.

---

## 10. Suggested delivery phasing

| Phase | Scope |
|---|---|
| **Phase 0 — Foundation** | Dio client + refresh interceptor, secure storage, error mapper, auth state/router gate, design system tokens |
| **Phase 1 — Auth** | Login, logout, forgot/reset password, (set-password if confirmed needed) |
| **Phase 2 — Shared core** | Profile screen, role-based nav shell, curricula list + tree, video/document stub screens, empty states |
| **Phase 3 — Teacher** | My Classes, Roster (paginated), Sections filter |
| **Phase 4 — Polish** | Suspended-school detection, rate-limit UX, "log out everywhere," document "open externally" action |
| **Backend-dependent (parallel track)** | Student enrollment-in-`/me` (§9.1), mobile deep-link scheme (§9.2) |

---

## 11. Open questions for the team

1. Is the invite-email / set-password flow (§5.1.5) still used by school admins, or has it been fully replaced by admin-issued passwords? Determines whether Phase 1 includes that screen.
2. Confirm state management choice (Riverpod vs. Bloc vs. other) so §6.6's session notifier and §6.5's paginated-list widget are built consistently with the rest of the team's stack.
3. Confirm mobile deep-link scheme/handle (`smartteacher://...` or app links/universal links) before Phase 1 reset-password work starts, since it affects the mail template coordination in §9.2.
4. Priority call: is the document "open externally" action (§5.4.3, v1.1) worth pulling into v1, or genuinely deferred?