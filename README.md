# Gawen Flutter frontend

Android app for Gawen authentication and employee organization onboarding.
Flutter screens use the React/CSS prototype in
`../Gawen Workforce Management App/src` as a visual reference; it is not part
of the Android runtime. No Figma screenshots or custom font assets are
available, so the team/shop artwork is recreated with Flutter widgets.

## Run locally

`.env.json` configures `API_BASE_URL` for the physical Android phone connected
over USB:

```powershell
adb reverse tcp:3000 tcp:3000
flutter run --dart-define-from-file=.env.json
```

The backend must be running on the development computer at port 3000.
`adb reverse` forwards the phone's `localhost:3000` to the computer's
`localhost:3000`; rerun the command after reconnecting USB. For an Android
emulator, set the URL in `.env.json` to `http://10.0.2.2:3000`. Without a
define file, the app defaults to `http://10.0.2.2:3000`.

The Android network security configuration permits cleartext HTTP only to
`localhost` and `10.0.2.2` for local development. Use HTTPS outside local
development. Authentication tokens are stored with `flutter_secure_storage`;
credentials and request bodies are not logged.

## Backend contract in use

The backend routes below are verified in `../backend/src`.

| Method | Path | Contract |
| --- | --- | --- |
| POST | `/api/auth/register` | `name`, `organizationName`, `email`, `password`; 202 generic response. Creates owner, organization, and owner membership in a transaction. |
| POST | `/api/auth/register/employee` | `name`, `email`, `password`; 202 generic response. Creates an account without membership or automatic login. |
| POST | `/api/auth/login` | `email`, `password`; 200 Bearer token and user/membership data. |
| GET | `/api/auth/me` | Authenticated profile and memberships. |
| POST | `/api/auth/logout` | Revokes the current authenticated session. |
| POST | `/api/employees/join-requests` | Authenticated `{ businessCode }`; code is 8 uppercase alphanumeric characters; 202 response intentionally does not disclose whether the code exists. |
| GET | `/api/employees/join-requests/me` | Authenticated request list including actual status and permitted organization information. |
| POST | `/api/employees/invitations/accept` | Authenticated `{ token }`; acceptance is verified by the backend. |

There is no endpoint to preview a business code or read invitation details,
expiry, or revocation status. The app does not simulate those states or show a
fake organization preview. Invitation tokens can be entered/passed in-memory
to Login or employee registration; after authentication, the backend remains
the authority on whether the token can be accepted.

## Routing and session behavior

| Route name / path | Page and access / entry | Parameters / extra | Success, error, and Back behavior | App reopened |
| --- | --- | --- | --- | --- |
| `splash` / `/splash` | Public; app launch and session restoration | None | Valid session → `/home`, `/pending`, or `/join` based on backend membership; no session → onboarding or welcome. Retry on recoverable server/network errors; expired session is cleared. System Back exits the app. | Always starts here; it revalidates the session before protected navigation. |
| `onboarding` / `/onboarding` | Public; first launch until locally completed | Completion flag in secure storage | Finish/skip → `/welcome`; secure-storage errors show a retry message. Android Back exits if there is no prior page. | Skipped after completion; otherwise shown after an unauthenticated restore. |
| `welcome` / `/welcome` | Public; unauthenticated entry | None | Login, owner registration, or employee registration. No protected data is loaded. System Back exits. | Session restoration selects a verified landing route instead. |
| `login` / `/login` | Public; unauthenticated; offers Owner and Employee modes | Optional internal `from` path; in-memory `InvitationLoginIntent` | Server-confirmed login → invitation continuation, Pending, Home, or Join. Employee accounts without a company go directly to Join to enter a business code; actual role/access always comes from backend membership, not the selected mode. Credential/network errors remain on Login. Back → Welcome, or invitation entry when carrying invitation context. | Starts at Splash; the app does not restore the prior navigation stack or invitation token. |
| `owner-registration` / `/register/owner` | Public; initiated from Welcome/Login | Optional in-memory invitation intent is not offered for Owner registration | Backend's generic 202 → Login; backend does not establish a session. Validation/API errors remain on the form; Back → Welcome. | Starts at Splash; unsent form state is not restored. |
| `employee-registration` / `/register/employee` | Public; initiated from Welcome or invitation flow | Optional in-memory `InvitationLoginIntent` | Backend's generic 202 → Login; no membership is created. Invitation flow carries its token to Login; errors remain on the form. Back returns to prior page. | Starts at Splash; registration form and invitation context are not persisted. |
| `home` / `/home` | Protected; verified active membership | None | Shows memberships returned by the backend. Pending → `/pending`; no membership → `/join`; logout revokes/clears session and replaces route with Welcome. Back cannot restore a logged-out protected page. | Startup revalidates membership and only returns here for active access. |
| `join` / `/join` | Protected; valid session, including accounts without membership | Business code entered in the form; not stored in route state | Submit → backend join request, then server status is revalidated. Generic response is not proof that a code is valid. Back returns to prior authenticated page. | Startup revalidates access; no form code is persisted. |
| `requests` / `/requests` | Protected; valid session | None | Displays actual `/join-requests/me` results; pending routes to `/pending`; refresh/network errors can be retried. Back returns to prior authenticated page. | Startup revalidates session and routes from current backend membership/request status. |
| `pending` / `/pending` | Protected; backend reports a pending request | None; permitted organization data comes from the server | Explicit refresh → `/home` only after backend confirms active membership. On errors, last verified pending state remains visible. Back → Join. | Startup rechecks status; it does not trust a cached pending decision. |
| `invitation` / `/invitation` | Token entry is public; accepting requires a valid session | Optional in-memory token passed as `String` extra; not accepted from a query parameter | Login/employee registration preserves the token during the current flow; backend-confirmed acceptance → membership revalidation → `/home`. Backend errors are shown; the app does not invent expired/revoked/used status. Back → Home if authenticated, otherwise Welcome. | Starts at Splash; token is intentionally not persisted, so an interrupted flow must reopen/re-enter the invitation. |

The single `/home` page derives its displayed role from backend membership
data. Separate owner/employee dashboards and work modules are not present in
this project. A missing membership never grants organization access. Startup
and protected-route decisions are centralized in the GoRouter auth redirect;
route names and paths are centralized in `lib/core/router/route_names.dart`.

## Password policy

Registration requires at least 8 characters and has no uppercase, lowercase,
digit, or symbol requirement. The existing 128-character maximum remains in
both registration schemas and the login schema. Login does not enforce the
new-registration minimum, preserving access for accounts with shorter legacy
passwords. Passwords are neither trimmed nor normalized. Dart `String.length`
counts UTF-16 code units, while the Zod 4 schema counts Unicode code points.
The Flutter validator uses `String.runes.length` to match the backend, so
supplementary Unicode characters each count as one character on both sides.

## Verification

Run checks from this directory:

```powershell
dart format .
flutter analyze
flutter test
```

Run backend checks from `../backend`:

```powershell
npm test
npm run typecheck
```

Flutter tests cover the entry pages, password boundaries, and auth redirect
decisions. Backend tests cover password schema boundaries, registration at
eight characters, legacy short-password login, and the existing auth/invitation
API flows. Device/profile performance and live backend behavior require a
configured Android device and running local backend.
