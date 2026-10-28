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

In debug mode, the shared Dio client prints each API request and its success or
error response to the `flutter run` terminal. Logs include the endpoint path,
HTTP status, and sanitized response body. Query strings and sensitive fields
such as passwords, tokens, authorization headers, secrets, hashes, and business
codes are redacted; response logs are disabled in release mode.

## Feature architecture

The app keeps the existing feature-first `lib/modules/` layout. API response
models parse backend JSON into domain entities; repositories own Dio requests
and return typed values. Auth, Organization, Employees, and Invitation each
keep their BLoC, event, and state in separate files under
`presentation/bloc/`. Screens consume typed state and no longer parse API maps.

| Domain | Entity / API model | Backend source or route |
| --- | --- | --- |
| User profile | `UserEntity` / `UserModel` | `User` fields selected by `/api/users/me` and employee member endpoints: `id`, `name`, `email`, nullable `phone` and `photoProfile`; password/hash are excluded. |
| Organization | `OrganizationEntity` / `OrganizationModel` | Organization API selection: `id`, `name`, `timezone`, `createdAt`, `updatedAt`, and `memberCount` on detail response. Optional values remain nullable when absent. |
| Membership | `MembershipEntity` / `MembershipModel` | `OrganizationMembership`: `id`, `role`, optional nested user/organization and `createdAt`. Roles are `OWNER` and `EMPLOYEE`; the backend membership model has no status field. |
| Join request | `JoinRequestEntity` / `JoinRequestModel` | `EmployeeJoinRequest`: `id`, status, dates, and permitted nested user/organization fields. Statuses are `PENDING`, `APPROVED`, and `REJECTED`. The Owner pending-only endpoint omits `status`, so that field stays nullable instead of being inferred. |
| Invitation | `InvitationEntity` / `InvitationModel` | Create response: `id`, `email`, `expiresAt`, and `createdAt`. One-time `token` is a separate `CreatedInvitation` value, not stored on the reusable invitation entity. |

Schedule and attendance models are not added to the Flutter API layer: although
the Prisma schema contains related database concepts, the current Express API
does not expose endpoints or response DTOs for those features. Employee is
represented by an organization membership with nested user data; no duplicate
Employee profile entity is introduced.

| Feature | BLoC | Event | State |
| --- | --- | --- | --- |
| Auth | `auth_bloc.dart` | `auth_event.dart` | `auth_state.dart` |
| Organization | `organization_bloc.dart` | `organization_event.dart` | `organization_state.dart` |
| Employees | `employee_bloc.dart` | `employee_event.dart` | `employee_state.dart` |
| Invitation / join | `invitation_bloc.dart` | `invitation_event.dart` | `invitation_state.dart` |

The existing BLoC paths remain stable and re-export their event/state types to
avoid breaking screen imports.

## Backend contract in use

The backend routes below are verified in `../backend/src`.

| Method | Path | Contract |
| --- | --- | --- |
| POST | `/api/auth/register` | `name`, `organizationName`, `email`, `password`; 202 generic response. Creates owner, organization, and owner membership in a transaction. |
| POST | `/api/auth/register/employee` | `name`, `email`, `password`; 202 generic response. Creates an account without membership or automatic login. |
| POST | `/api/auth/login` | `email`, `password`; 200 Bearer token and user/membership data. |
| GET | `/api/users/me` | Authenticated profile and memberships. |
| PATCH | `/api/users/me` | Updates the authenticated user's `name`, `phone`, and/or `photoProfile`; email and password are not editable here. |
| POST | `/api/auth/logout` | Revokes the current authenticated session. |
| GET | `/api/organizations/:organizationId` | Authenticated OWNER/EMPLOYEE membership; returns organization name, timezone, and member count. |
| PATCH | `/api/organizations/:organizationId` | OWNER only; updates `name` and/or `timezone`. |
| POST | `/api/employees/join-requests` | Authenticated `{ businessCode }`; code is 8 uppercase alphanumeric characters; 202 response intentionally does not disclose whether the code exists. |
| GET | `/api/employees/join-requests/me` | Authenticated request list including actual status and permitted organization information. |
| GET | `/api/employees/organizations/:organizationId/members` | OWNER only; membership rows with user name, email, phone, role, and creation time. |
| GET | `/api/employees/organizations/:organizationId/members/:membershipId` | OWNER only; one organization-scoped membership detail. |
| GET | `/api/employees/organizations/:organizationId/join-requests` | OWNER only; pending requests. |
| POST | `/api/employees/organizations/:organizationId/join-requests/:requestId/approve` | OWNER only; approves pending request and creates EMPLOYEE membership transactionally. |
| POST | `/api/employees/organizations/:organizationId/join-requests/:requestId/reject` | OWNER only; rejects pending request. |
| POST | `/api/employees/organizations/:organizationId/invitations` | OWNER only; request `{ email }`; returns invitation id, recipient email, expiry, and one-time token. |
| POST | `/api/employees/organizations/:organizationId/invitations/:invitationId/revoke` | OWNER only; revokes an unaccepted, unexpired invitation. |
| POST | `/api/employees/invitations/accept` | Authenticated `{ token }`; acceptance is verified by the backend. |

There is no endpoint to preview a business code, list existing invitations,
or query invitation status/details. The app does not simulate those states or
show a fake organization preview. The token is shown only in-memory after
creation and is not logged or persisted. Invitation tokens can be entered and
passed in-memory to Login or employee registration; after authentication, the
backend remains the authority on whether the token can be accepted.

## Routing and session behavior

| Route name / path | Page and access / entry | Parameters / extra | Success, error, and Back behavior | App reopened |
| --- | --- | --- | --- | --- |
| `splash` / `/splash` | Public; app launch and session restoration | None | Valid session → `/home`, `/pending`, or `/join` based on backend membership; no session → onboarding or welcome. Retry on recoverable server/network errors; expired session is cleared. System Back exits the app. | Always starts here; it revalidates the session before protected navigation. |
| `onboarding` / `/onboarding` | Public; first launch until locally completed | Completion flag in secure storage | Finish/skip → `/welcome`; secure-storage errors show a retry message. Android Back exits if there is no prior page. | Skipped after completion; otherwise shown after an unauthenticated restore. |
| `welcome` / `/welcome` | Public; unauthenticated entry | None | Login, owner registration, or employee registration. No protected data is loaded. System Back exits. | Session restoration selects a verified landing route instead. |
| `login` / `/login` | Public; unauthenticated; offers Owner and Employee modes | Optional internal `from` path; in-memory `InvitationLoginIntent` | Server-confirmed login → invitation continuation, Pending, Home, or Join. Employee accounts without a company go directly to Join to enter a business code; actual role/access always comes from backend membership, not the selected mode. Credential/network errors remain on Login. Back → Welcome, or invitation entry when carrying invitation context. | Starts at Splash; the app does not restore the prior navigation stack or invitation token. |
| `owner-registration` / `/register/owner` | Public; initiated from Welcome/Login | Optional in-memory invitation intent is not offered for Owner registration | Backend's generic 202 → Login; backend does not establish a session. Validation/API errors remain on the form; Back → Welcome. | Starts at Splash; unsent form state is not restored. |
| `employee-registration` / `/register/employee` | Public; initiated from Welcome or invitation flow | Optional in-memory `InvitationLoginIntent` | Backend's generic 202 → Login; no membership is created. Invitation flow carries its token to Login; errors remain on the form. Back returns to prior page. | Starts at Splash; registration form and invitation context are not persisted. |
| `home` / `/home` | Protected; verified active membership | None | Role-aware Home uses profile membership and organization data. Pending → `/pending`; no membership → `/join`; logout revokes/clears session and replaces route with Welcome. Back cannot restore a logged-out protected page. | Startup revalidates membership and only returns here for active access. |
| `join` / `/join` | Protected; valid session, including accounts without membership | Business code entered in the form; not stored in route state | Submit → backend join request, then server status is revalidated. Generic response is not proof that a code is valid. Back returns to prior authenticated page. | Startup revalidates access; no form code is persisted. |
| `requests` / `/requests` | Protected; valid session | None | Displays actual `/join-requests/me` results; pending routes to `/pending`; refresh/network errors can be retried. Back returns to prior authenticated page. | Startup revalidates session and routes from current backend membership/request status. |
| `pending` / `/pending` | Protected; backend reports a pending request | None; permitted organization data comes from the server | Explicit refresh → `/home` only after backend confirms active membership. On errors, last verified pending state remains visible. Back → Join. | Startup rechecks status; it does not trust a cached pending decision. |
| `invitation` / `/invitation` | Token entry is public; accepting requires a valid session | Optional in-memory token passed as `String` extra; not accepted from a query parameter | Login/employee registration preserves the token during the current flow; backend-confirmed acceptance → membership revalidation → `/home`. Backend errors are shown; the app does not invent expired/revoked/used status. Back → Home if authenticated, otherwise Welcome. | Starts at Splash; token is intentionally not persisted, so an interrupted flow must reopen/re-enter the invitation. |
| `employees` / `/employees` | OWNER only; active owner membership verified by backend | None | Loads organization members and pending join requests; local search filters fetched members. Owner can inspect details, approve/reject requests with confirmation, or create an invitation. Error supports retry; Employee is redirected to permission explanation. | Startup revalidates owner membership before route access. |
| `employee-detail` / `/employees/detail` | OWNER only | Membership id as in-memory route extra | Loads detail from organization-scoped membership endpoint; missing/unauthorized data is reported. Back returns to member list. | Detail is not restored after app restart. |
| `invite-employee` / `/employees/invite` | OWNER only | Recipient email in form | Creates invitation through the existing endpoint. Shows the one-time token and expiry only after server success; supports copy and confirmed revocation. Failed requests retain the email. | Token is not persisted; create a new invitation if the flow is interrupted. |
| `organization` / `/organization` | Active OWNER or EMPLOYEE membership | Organization id from verified profile | Loads actual name, timezone, and member count. Only OWNER sees the edit action. Server/network errors can be retried. | Startup revalidates membership; organization data is fetched again. |
| `edit-organization` / `/organization/edit` | OWNER only | Name and timezone fields | PATCHes only backend-supported fields. Server validation errors keep form values; success returns to organization details. | Unsaved values are not restored. |
| `schedule` / `/schedule` | Active membership | None | Shows that schedule is not available because no schedule API routes exist in this backend. | Reopened from the role-aware bottom navigation. |
| `more` / `/more` | Active membership | None | Links to permitted organization information and employee request status; logout clears local organization/member state. | Reopened from the role-aware bottom navigation. |
| `team` / `/team` | Employee navigation target; no read-only member-list API exists | None | Shows the permission/API availability explanation; does not request the owner-only members endpoint. | Reopened from bottom navigation. |
| `permission` / `/permission` | Active membership; shown for forbidden role-specific routes | None | Explains why the requested feature is unavailable. Back/Home returns to the role-aware Home. | Not a persistent destination. |

The Home and bottom navigation derive role from backend membership data.
Employee team listing, schedule/attendance summaries, and an invitation-list
endpoint are not available, so the app does not show fake data or permit
Employee access to owner-only employee-management routes. Startup and
protected-route decisions are centralized in the GoRouter auth redirect;
route names and paths are centralized in `lib/core/router/route_names.dart`.

## Organization and employee API readiness

| Feature | Actual endpoint | Readiness | Data used | Backend access |
| --- | --- | --- | --- | --- |
| Organization details | `GET /api/organizations/:organizationId` | READY; membership authorization and tests present | Name, timezone, member count | OWNER and EMPLOYEE in that organization |
| Organization update | `PATCH /api/organizations/:organizationId` | READY; schema, owner membership check, and tests present | Name and timezone only | OWNER |
| Employee list/detail | `GET /api/employees/organizations/:organizationId/members[/:membershipId]` | READY; owner-only middleware, organization scoping, and tests present | Membership id/role/date and user name/email/phone | OWNER |
| Join approval | `GET .../join-requests`, `POST .../:requestId/approve`, `POST .../:requestId/reject` | READY; transactional membership creation and API tests present | Pending request and applicant identity | OWNER |
| Invitation create/revoke/accept | `POST .../invitations`, `POST .../:invitationId/revoke`, `POST /api/employees/invitations/accept` | READY; ownership/email/expiry/single-use rules and API tests present | Recipient email, expiry, one-time token; acceptance creates membership | Create/revoke OWNER; accept authenticated intended recipient |
| Employee team read-only list | No endpoint | BLOCKED | No data contract available | Not available to EMPLOYEE |
| Schedule/attendance summary | No route in current API app | NOT IMPLEMENTED | No data contract available | Not available |
| Invitation history/status | No list or status endpoint | PARTIAL | Created invitation result only; no later status query | OWNER can revoke if invitation id is known |

These are source and test-code readiness findings. The backend integration
test suite was not run during this frontend task because it requires a
dedicated `TEST_DATABASE_URL` and database; this report does not claim live
integration validation.

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

Flutter tests cover model and repository response parsing, BLoC loading/empty/
failure states, entry pages, password boundaries, and auth redirect decisions.
Backend tests cover password schema boundaries, registration at
eight characters, legacy short-password login, and the existing auth/invitation
API flows. Device/profile performance and live backend behavior require a
configured Android device and running local backend.
