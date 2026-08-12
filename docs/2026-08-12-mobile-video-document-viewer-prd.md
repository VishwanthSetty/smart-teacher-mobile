# Plan — PRD for the Flutter video player & document reader

## Context

`docs/2026-08-10-mobile-app-feature-list.md` deliberately scoped the video player and PDF reader **out** of the mobile feature list, stopping at "here's the entitled item". That gap now needs closing: the Flutter app must actually play videos and read documents, under two hard product constraints — **video must not be recordable** and **documents must not be downloadable**.

Exploration of `apps/api` surfaced one fact that changes the shape of the work:

- **Video is buildable today.** Plain HLS behind a short-lived ES256 `?t=` token. No DRM, but a working, entitlement-gated delivery chain exists in both `api` and `edge` modes.
- **Documents are not.** The only endpoint, `GET /documents/:id/download`, returns a **300s presigned S3 URL to the whole PDF**. That *is* a download link — unauthenticated, interceptable, whole-file. No Range proxy, no page images, no watermark, no read audit exists anywhere in the API (`StorageService`'s header comment explicitly states it never streams media bytes).

So the deliverable is a PRD covering the Flutter client **plus** the backend delta the no-download requirement makes unavoidable.

**Deliverable:** `docs/2026-08-12-mobile-video-document-viewer-prd.md`

Per the user's decisions: backend proxy + in-memory client render for PDFs; platform best-effort anti-capture on both OSes; PRD covers mobile *and* the required backend additions as a tracked workstream.

---

## Verified ground truth the PRD must be built on

Written up front so the PRD never restates a guess as a fact.

### Video (works today)

| Fact | Source |
| --- | --- |
| `GET /videos/:id/playback-token` → `{ videoId, manifestUrl, posterUrl\|null, durationSecs\|null, expiresInSecs }` | `apps/api/src/playback/entities/playback-token.entity.ts` |
| **The JWT is never its own field** — it is the `?t=` query param inside `manifestUrl`. Client must parse it out. | `apps/web/src/components/video/hls-player.tsx:171` |
| ES256, claims `{ vid, pfx: "videos/<id>/", sub, iss: smart-teacher-api, aud: smart-teacher-playback }` | `apps/api/src/playback/playback-token.service.ts:44-59` |
| TTL `PLAYBACK_TOKEN_TTL_SECS`, default **600s**, validated `@Min(60) @Max(900)` | `apps/api/src/config/env.validation.ts:142-145` |
| Token travels **only as a query param**, never a header/cookie, on every manifest+segment request | `apps/api/src/playback/playback-token.guard.ts:26-31` |
| HLS, **MPEG-TS** segments, `-hls_time 6`, default ladder **360p + 720p only** | `apps/worker/src/transcode/ffmpeg-args.ts:105-124`, `RENDITION_LADDER` |
| `api` mode: segments/poster are **302 redirects** to presigned URLs, **no Range support** | `apps/api/src/playback/playback-delivery.controller.ts:34-52` |
| `edge` mode: bytes served directly from R2, **full Range/206** | `edge/playback-worker/src/index.ts:46-66` |
| Expired token → **401 in `api` mode, 403 in `edge` mode** | `hls-player.tsx:216-222` |
| **No DRM anywhere** (no Widevine/FairPlay/AES-128). Repo-wide grep: zero hits. | — |
| `VideoEntity` has **no poster, no status, no renditions** — thumbnails require a token mint per video | `apps/api/src/videos/entities/video.entity.ts` |

### Documents (gap)

| Fact | Source |
| --- | --- |
| `GET /documents/:id/download` → `{ url, expiresInSecs: 300, fileName }`, JSON not a redirect | `apps/api/src/documents/entities/document-download.entity.ts` |
| `url` is a **genuine SigV4 presigned URL straight to MinIO/S3**, no app auth, no content-disposition/IP/referrer binding | `apps/api/src/storage/s3-storage.service.ts:132-139` |
| Key layout `documents/{documentId}/source.pdf`; PDF only, max 50MB | `apps/api/src/documents/documents.service.ts:304-306`, `document-ingest.constants.ts` |
| `DocumentEntity` exposes **no mime, size, pageCount, or fileName** — `sizeBytes`/`contentType` are SUPER_ADMIN-only; **`pageCount` does not exist in the schema at all** | `document.entity.ts`, `schema.prisma:424-440` |
| No Range/streaming/page-by-page anywhere; `getObjectText` is capped at 1 MiB and unusable for PDFs | `apps/api/src/storage/storage.service.ts:17-24` |
| Unentitled/non-READY/missing-sourceKey all → **404, never 403** | `documents-access.policy.ts`, `common/authorization/resource-access.ts:29-39` |
| No watermarking, no read audit, no revocation | — |

---

## Backend workstream (Workstream A) — spec the PRD must contain

Goal: the presigned S3 URL never reaches the device. Mirror the playback pattern exactly rather than inventing one — CLAUDE.md's prime directive.

### A1. Generalize the media token service

`PlaybackTokenService` already does exactly the right thing but is video-named and hard-codes `videos/<id>/`. Generalize in place rather than cloning:

- `mint(prefix: string, userId: string)` → token carrying `{ pfx, sub }` plus a new **`typ: 'video' | 'document'`** claim.
- `verify(token, expectedPrefix)` — prefix equality, same ES256/iss/aud checks.
- Keep `vid` on video tokens for backward compatibility with `edge/playback-worker`, which verifies `pfx` against the R2 key. The worker's path regex only matches `videos/...` keys, so a document token is already inert there; the `typ` claim is belt-and-braces and needs **no worker change**.
- Decide during implementation whether the service moves out of `playback/`. Recommendation: **leave it in `playback/` and export it from `PlaybackModule`** — moving it invents a new top-level folder for no gain.

### A2. Storage: add a ranged read

`StorageService` (`apps/api/src/storage/storage.service.ts`) is an abstract port with **no streaming method by design** — its header comment says so. The no-download requirement is a deliberate, documented deviation and the PRD must say why.

Add to the port + `S3StorageService`:
```
createReadStream(key: string, range?: { start: number; end: number })
  -> { body: Readable; contentLength: number; contentRange?: string; contentType: string }
```
Implemented with `GetObjectCommand` + `Range` header against the internal `client` (not `signingClient`).

### A3. New route: `GET /documents/:id/file`

- `@PlaybackTokenRoute()`-style: a `@DocumentTokenRoute()` decorator + guard verifying `?t=` against `documents/<id>/`, bypassing `JwtAuthGuard`/`RolesGuard` the same way `PlaybackTokenGuard` does.
- Pipes bytes via `StreamableFile`. Honours `Range` → `206` + `Content-Range` + `Accept-Ranges: bytes`.
- Headers: `Content-Type: application/pdf`, `Cache-Control: no-store`, `Content-Disposition: inline`.
- `@ApiExcludeEndpoint()` — matches the playback delivery controller.

### A4. New route: `GET /documents/:id/view-token`

- Roles `SCHOOL_ADMIN, TEACHER, STUDENT` (same class-level roles as `DocumentsController`).
- Calls the existing `requireReadable` + `DocumentsAccessPolicy` chain **before** minting — identical to `PlaybackService.get()` calling `findPlayableVisibleTo` first.
- Returns `{ documentId, fileUrl, sizeBytes, expiresInSecs }`. **Include `sizeBytes`** — the Flutter range-reader needs the total length up front, and it is already on the `Document` row, just not on the client entity.

### A5. Fate of `GET /documents/:id/download`

Web's PDF viewer (`apps/web/.../documents/[documentId]/page.tsx`) uses it and renders an explicit "Download PDF" anchor. **Do not remove it in this change** — mobile simply never calls it. The PRD should flag the web/mobile policy inconsistency ("web can download, mobile cannot") as a product decision to resolve separately.

### A6. Non-negotiable API chores

- `MATRIX` rows in `apps/api/test/rbac-matrix.e2e-spec.ts` for both new routes, **same commit**.
- e2e in `apps/api/test/documents.e2e-spec.ts`: token mints for entitled actor; **404 for `teacher-b@`** (unentitled school); `/file` with a foreign document's token → 401; expired token → 401; Range request → 206.
- No `schema.prisma` change needed. No new tenant-scoped model, so `TENANT_SCOPED_MODELS` is untouched.

---

## Mobile workstream (Workstream B) — what the PRD specifies

### B1. Video player

**Stack:** `video_player` (ExoPlayer / AVPlayer) — both have native HLS. Explicitly reject `better_player`-style wrappers whose default **disk cache** would persist segments to storage, defeating the requirement.

**The central problem: token TTL (600s) < lesson length (45min).** ExoPlayer and AVPlayer both bake segment URLs at playlist-parse time and expose no per-request URL rewrite hook through Flutter — so hls.js's `TokenLoader` trick (`hls-player.tsx:201-213`) is unavailable. The mobile path is the **native/Safari path**: `reattachNative` (`hls-player.tsx:113-128`).

Refresh algorithm to port verbatim:
- Re-mint at `0.8 × expiresInSecs`, floor 15s (`REFRESH_AT_FRACTION`, `MIN_REFRESH_DELAY_MS`).
- Budget **3 refreshes / 60s window**; exceeding it is a token fault, not a length fault → surface an error.
- On refresh: capture `position` + `isPlaying`, build a new controller/data source from the fresh `manifestUrl`, `seekTo(position)`, resume. Accept one brief hiccup per ~8 minutes — this is what Safari already pays in production.
- On a playback error with HTTP **401 (api mode) or 403 (edge mode)** → refresh once immediately, then retry.
- Recommend raising `PLAYBACK_TOKEN_TTL_SECS` to its validated max **900s** for mobile, cutting hiccups by a third at no security cost.

**Platform gotchas the PRD must call out:**
- `api` mode 302-redirects segments to presigned URLs — Android needs `allowCrossProtocolRedirects: true` if the API and S3 public endpoint differ in scheme. iOS ATS must permit the S3 host.
- `api` mode has **no Range support** on segments; seeking works because HLS seeks by segment, but do not assume byte-range behaviour.
- Only **360p/720p** exist by default — a quality selector should read `#EXT-X-STREAM-INF` from the master, not any API field (renditions are SUPER_ADMIN-only).
- `posterUrl` is nullable and only obtainable from a token mint. **Do not mint a token per row** to build a thumbnail grid — use a placeholder in lists and mint only on the detail screen. Flag "add poster URL to `VideoEntity`" as a future backend nice-to-have.
- Disable AirPlay / Chromecast / PiP and background playback — all are capture-adjacent surfaces.

### B2. Document reader

**Stack:** `pdfrx`, opened via its **custom data-source callback** (`PdfDocument.openCustom`) so pages are fetched as ranges from `GET /documents/:id/file` straight into memory.

Hard rules:
- **Zero `File` I/O.** Never `getTemporaryDirectory()`, never `dart:io` writes. Bytes live in RAM for the life of the screen and are dropped on dispose.
- No share sheet, no print, no "open in…", no text-selection copy (`enableTextSelection: false`), no long-press context menu.
- Reader UI: page scroll, pinch zoom, page N-of-M indicator, jump-to-page. Page count comes from the parsed PDF client-side — **there is no `pageCount` field in the API** and none is being added.
- Token refresh: the view token has the same short TTL. Re-mint on `401` from any range request and retry that range once — much simpler than video, since a PDF range fetch is idempotent and stateless.

### B3. Anti-capture (both surfaces)

Per the chosen posture — **platform best-effort, documented as a deterrent, not a guarantee**.

- **Android:** `FLAG_SECURE` on the player and reader routes **only**, not app-wide (a teacher screenshotting a roster is legitimate). Set on route push, cleared on pop.
- **iOS:** no equivalent exists. Observe `UIScreen.isCaptured` and `userDidTakeScreenshotNotification`; on capture, blank/blur the surface and pause playback with an explanatory overlay ("Screen recording is not permitted for this content").
- Package: `screen_protector` (handles both) or a small `MethodChannel` if it proves unmaintained. Evaluate at implementation time.
- **The PRD must state plainly:** none of this stops an external camera, a rooted/jailbroken device, or a desktop capture of the same content on `apps/web`. It raises cost; it does not prevent. Real prevention needs DRM (Widevine/FairPlay), which does not exist in this pipeline and is a separate, large project.

### B4. Error mapping (reuse the existing convention)

Extend the `ApiErrorResponse` helper the feature-list doc already specifies (§7). Player/reader-specific:
- `401`/`403` on a media request → silent token refresh, not a user-visible error.
- `404` on token mint → "This content is no longer available." Never imply a permission failure (backend policy is 404-not-403).
- Refresh budget exhausted → "Playback failed. Check your connection and try again." with Retry.

---

## PRD document structure

`docs/2026-08-12-mobile-video-document-viewer-prd.md`:

1. **Context & goals** — closes the gap deliberately left open by the 2026-08-10 feature list; the two hard constraints.
2. **Non-goals** — DRM, offline download, progress tracking, annotations, web-side download removal.
3. **Ground truth: what the API does today** — the two verified-fact tables above, with file paths.
4. **The document gap** — why the current endpoint cannot satisfy "no download", stated as an engineering fact.
5. **Workstream A — backend deltas** (A1–A6), each with acceptance criteria.
6. **Workstream B — Flutter client** (B1–B4), each with acceptance criteria.
7. **Security posture & honest limits** — what is enforced, what is deterred, what is impossible without DRM. Includes: leaked video manifest URL is playable by anyone for ≤ TTL.
8. **Sequencing** — A1–A4 unblock B2; B1 can start immediately against the existing API.
9. **Open questions** — web/mobile download-policy inconsistency (A5); whether read-audit/watermark is wanted later; poster URLs on `VideoEntity`.

---

## Critical files

**Read as reference (not modified):**
- `apps/web/src/components/video/hls-player.tsx` — the refresh algorithm to port; its comments explain *why* each constant exists.
- `apps/api/src/playback/` — `playback-token.service.ts`, `playback-token.guard.ts`, `playback-delivery.controller.ts`, `playback-urls.ts`. The pattern to mirror for documents.
- `apps/api/src/documents/documents.service.ts`, `documents-access.policy.ts` — the entitlement chain the new routes must reuse unchanged.
- `apps/api/src/entitlements/actor-content-scope.service.ts` — the one answer to "what can this actor reach".

**Created by this task:**
- `docs/2026-08-12-mobile-video-document-viewer-prd.md`

**Named in the PRD as to-be-modified (Workstream A, not built now):**
- `apps/api/src/playback/playback-token.service.ts`, `apps/api/src/storage/{storage,s3-storage}.service.ts`, `apps/api/src/documents/documents.{controller,service,module}.ts`, `apps/api/test/rbac-matrix.e2e-spec.ts`, `apps/api/test/documents.e2e-spec.ts`

---

## Verification

This task's output is a document, so verification is review-shaped:

1. **Fact-check pass** — every API claim in the PRD traces to a file path already cited above; no invented fields (`pageCount`, `posterUrl` on `VideoEntity`, a `status` on `VideoEntity`) appear as if they exist.
2. **Conformance to CLAUDE.md** — Workstream A introduces no new pattern: it mirrors `PlaybackTokenService`/`PlaybackTokenGuard`, reuses `requireReadable` + `ResourceAccessPolicy`, returns 404-not-403, and carries its `MATRIX` rows and e2e tests.
3. **Constraint coverage** — trace both hard requirements end to end: "no download" (A2–A4 + B2's zero-file-I/O rule) and "no recording" (B3, with limits stated).
4. **Buildability** — a Flutter dev can start B1 today with no backend change; B2 is explicitly blocked on A1–A4 and says so.

When Workstream A is later implemented, its own verification is the standard gate: `npm run lint` → `npm run build` → `npm run test:e2e`, with the new `documents.e2e-spec.ts` cases passing and `rbac-matrix.e2e-spec.ts` green (it fails the build if the MATRIX drifts).
