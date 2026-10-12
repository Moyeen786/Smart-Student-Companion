# Push notifications

## Current implementation

The Flutter client uses Firebase Cloud Messaging through `NotificationService`.
It:

- Requests notification permission once per user profile.
- Stores refreshed FCM tokens in `users/{uid}.fcmTokens`.
- Subscribes devices to `all_users`, their role (`student`, `faculty`, `parent`, or `admin`), and an optional normalized department topic.
- Shows a foreground SnackBar with an `OPEN` action.
- Handles background and terminated notification taps using the `announcementId` payload.
- Queues a first-time published announcement at `notification_jobs/{announcementId}`.
- Does not claim delivery when the secure sender is unavailable.

The notification payload contract is:

```json
{
  "notification": {
    "title": "New Announcement",
    "body": "Tomorrow is a holiday."
  },
  "data": {
    "type": "announcement",
    "announcementId": "announcement_document_id"
  }
}
```

## Required Cloud Function

This repository does not contain a Firebase Functions project. Create one outside
`lib/` with the Firebase CLI and deploy a function that triggers on
`notification_jobs/{announcementId}` creation.

The function must:

1. Reject jobs whose `type` is not `announcement` or whose status is not `pending`.
2. Read the referenced `announcements/{announcementId}` document.
3. Resolve the audience using trusted `users` documents. For `allUsers`, target all
   active users. For `students`, `faculty`, and `parents`, filter by `role`.
4. Use `department` as an additional filter when that field is added to the
   announcement form and stored in the job.
5. Send the FCM payload above to the users' `fcmTokens` in batches.
6. Remove invalid tokens from `users/{uid}.fcmTokens`.
7. Update the job with `status: sent`, `sentAt`, and delivery counts. On failure,
   update it with `status: failed` and an error message.
8. Treat the job document ID as the idempotency key. Never send a second batch for
   a job already marked `sent`.

Use the Firebase Admin SDK only inside the Functions project. Never place a
service-account JSON file, Admin SDK credential, or FCM server key in Flutter.

## Scheduled announcements

The Flutter app stores scheduled announcements with `status: scheduled` and
`scheduleAt` in Firestore. A scheduled Cloud Function should run periodically,
claim due announcements in a transaction, update them to `published`, and create
`notification_jobs/{announcementId}`. The client must not attempt to wake itself
or send a scheduled notification.

## Firebase Console and platform setup

- Enable Cloud Messaging for project `smart-student-companion-e0152`.
- Android: verify the Firebase Android app package matches the Gradle application
  ID and upload a release SHA-1/SHA-256 if required by the Firebase console.
- Android 13+: allow the runtime notification permission when prompted. The app
  creates the high-importance `announcements` channel.
- iOS: run FlutterFire configuration again with an iOS app, add `GoogleService-Info.plist`,
  enable Push Notifications and Background Modes > Remote notifications in Xcode,
  and upload an APNs authentication key/certificate in Firebase Console.
- Web, Windows, and Linux are not configured as FCM targets by the current
  `firebase_options.dart`.

## Verification checklist

1. Log in on a physical Android device and confirm `fcmTokens` is written.
2. Publish a new announcement and confirm its `notification_jobs/{id}` document
   is `pending`.
3. Deploy the sender and confirm the job becomes `sent`.
4. Test role targeting with student, faculty, and parent accounts.
5. Test foreground SnackBar, background system notification, terminated-app tap,
   denied permission, invalid token cleanup, and duplicate publish.
6. Confirm scheduled announcements remain `scheduled` until the server function
   publishes them.
