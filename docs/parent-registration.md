# Parent registration and Firebase setup

## Authorization contract

Parent linking requires two independent proofs in one registration flow:

1. The approving Student is signed in to the primary Firebase Auth session. The callable verifies the caller UID against that Student's existing `users/{uid}` profile, and resolves the submitted roll number against the existing `users` collection. The normalized full name must match, the roll number must resolve to exactly one Student, and that UID must equal the caller UID. The screen also requires an explicit student approval checkbox.
2. The Parent phone owner completes Firebase Phone Authentication in a secondary Firebase Auth app. The primary Student session is never signed out or replaced. The callable independently verifies the secondary phone identity's Firebase ID token with the Admin SDK and checks its verified `phone_number` claim and Auth user record.

Student profile fields come from this repository's schema: document ID is the Firebase UID; `role`, `name`, `email`, `rollNumber`, `department`, `semester`, and `createdAt` are existing profile fields in `users`. Linking rejects incomplete profiles missing those fields. Roll number normalization applies Unicode compatibility normalization, removes whitespace, and uppercases; name normalization applies Unicode compatibility normalization, trims/collapses whitespace, and compares case-insensitively.

The function currently loads Student-role documents to detect duplicate roll numbers regardless of name. This is intentionally correct for the existing schema, which has no normalized roll-number field or uniqueness index. For a large student population, add a trusted normalized-key migration and uniqueness strategy before scaling this query.

## Parent profile and claims

No Student profile is changed. The Admin SDK uses a private `parent_registration_reservations/{parentUid}` document to serialize retries and concurrent attempts. That collection remains client-inaccessible under the existing catch-all deny rule. After both proofs pass, the function merges the Parent claims, then atomically creates the active `users/{parentUid}` profile and removes the reservation. The profile uses the existing `users` collection and fields `uid`, `name`, `email`, `role`, `department`, `semester`, `createdAt`, `parentPhone`, `childStudentId`, `linkStatus`, `linkedAt`, and `verifiedAt`. The link permanently points to the actual Student Firebase UID. The generic Parent display name is `Parent`; no fabricated student or academic values are written. If a claim update succeeds but the profile write fails, the reservation remains, and the Parent still cannot pass the existing profile/rules checks; retrying repairs the same registration.

The function merges `role: parent` and `childStudentId` into existing custom claims. Existing unrelated claims are preserved. Admin, Student, Faculty, or Teacher role claims are never overwritten. A different child or phone on an existing Parent identity is rejected. Retries for the same phone/child repair an interrupted provisioning attempt and return the same relationship.

Cloud Functions Admin SDK writes bypass Firestore rules. No rules were changed. Existing rules permit Parent reads only when the Parent profile and claims agree on `childStudentId`. Do not loosen user create/update rules. The existing Parent auth repository forces a token refresh and rejects profiles without the trusted claims.

## Functions project and local checks

The TypeScript Functions project is under `functions/`, targets Node.js 22, and uses the Admin SDK and callable HTTPS Functions in `us-central1`. Firebase currently requires the Blaze plan for Cloud Functions; configure budget alerts before deployment. The Functions runtime uses its Google-managed service identity; there are no service-account keys or secrets in the repo. Set the target before Functions commands with `firebase use smart-student-companion-e0152` (or pass `--project smart-student-companion-e0152`).

```powershell
cd functions
npm.cmd install
npm.cmd test
```

To deploy only after review and Firebase project access are ready:

```powershell
firebase use smart-student-companion-e0152
firebase deploy --only functions
```

This change does not deploy Functions. The root `firebase.json` build hook builds TypeScript before a future Functions deploy. Do not deploy Firestore rules as part of this workflow.

## Firebase Console and Android requirements

Before testing on a device:

1. In Firebase Console → Authentication → Sign-in method, enable **Phone** and configure SMS region policy and any quotas/billing needed for the target region.
2. Add the Android app's actual application ID to the Firebase project. Register the app's SHA-1 and SHA-256 signing fingerprints (debug and release as applicable) so Play Integrity/reCAPTCHA app verification can work. Confirm the `google-services.json` app ID and package match the Gradle `applicationId`; the checked-in JSON currently reports `com.example.smart_student_companion`, so verify the app's effective ID before testing.
3. Configure authorized domains for any web build. Add iOS Firebase app configuration before attempting iOS; current `firebase_options.dart` intentionally does not support iOS.
4. Confirm Functions are enabled, the project is on a plan/runtime that supports Node 22 Functions, and the deployer has Functions and IAM permissions. No service-account credentials are needed locally when using `firebase login`/Application Default Credentials.
5. Callable requests currently rely on Firebase Auth and do not enforce App Check. Enable and enforce App Check only after a production App Check provider is initialized in Flutter and verified on each supported platform.

Official setup references: [Cloud Functions runtime and deployment](https://firebase.google.com/docs/functions/manage-functions) and [Android Phone Authentication and app verification](https://firebase.google.com/docs/auth/android/phone-auth).

## Device test

1. Deploy the Functions to a non-production Firebase project first, with matching Android app configuration.
2. Create/sign in to a Student account whose existing `users/{uid}` profile has a unique roll number and full name.
3. Open the Student/Parent choice screen and select **Approve and register a Parent phone**.
4. Enter the Student's exact name and roll number, enter a real Parent mobile number in E.164 format (for example `+919876543210`), and confirm approval.
5. Verify the profile check passes, receive the real Firebase SMS, enter the code, and confirm success. Verify the primary Student remains signed in.
6. In Firebase Console, verify `users/{parentUid}` is role `parent`, `linkStatus` is `active`, and `childStudentId` equals the actual Student UID. In Authentication custom claims, verify `role=parent` and that same `childStudentId` exist while unrelated claims are intact.
7. Sign in on a separate Parent session/device with the verified phone and OTP. Verify the existing Parent login checks the claims and the Parent dashboard loads only the linked student's record.
8. Retry registration for the same Parent and Student and confirm it remains idempotent. Try a different Student session, wrong name/roll, ambiguous duplicate roll, altered phone token, existing other-role Parent account, and a Parent identity already linked to another child; each must fail without changing the Student profile or granting a new link.

## Limits

This schema supports one `childStudentId` per Parent Firebase UID. A Parent with multiple children requires an explicit many-to-many relationship model and corresponding rules/claims design; this implementation rejects relinking a Parent to another child. The UI requires the Student to be the person operating the registration flow while the Parent phone owner supplies the OTP; it does not provide a remote approval handoff.
