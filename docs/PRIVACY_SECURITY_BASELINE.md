# Privacy and security baseline

**Updated:** 10 November 2026  
**Applies to:** Android and iOS launch planning  
**Publisher:** Locvel · hello.locvel@gmail.com

## Product commitments

- Free to install and use; no ads or ad SDKs.
- No app-owned backend, account, cloud sync, cloud transcription, analytics, or crash-reporting service.
- Audio, transcript text, titles, and library actions stay in app storage. Transcription runs locally after model download.
- The only app-controlled network purpose is a user-started model download from Hugging Face. The host may receive the device IP address, request time, model/revision/file request information, and ordinary connection metadata. No audio, transcript, email, name, or app account ID is sent with that request.
- Exports and sharing are user initiated. The destination app or donation provider then handles the data under its own terms.
- A local System/Light/Dark choice is implemented in Settings and saved to the encrypted local database. It creates no network traffic or account state.
- There is no donation URL yet. No donation button or payment SDK is included until the owner chooses a destination and it passes the checks below.

These describe the current product design and code audit. Final store disclosures must be based on the exact release artifact, dependency versions, model endpoint behavior, and applicable store definitions.

## Current protection layers

| Data or boundary | Current control | Remaining limit |
|---|---|---|
| Android app data | Recordings are under app-specific internal storage; Android app backup is disabled; cleartext HTTP is denied; unnecessary permissions are removed. Android internal storage is isolated from other apps and encrypted on Android 10+. [Android app-specific storage](https://developer.android.com/training/data-storage/app-specific) | Rooted/compromised devices, OS exploits, or code executing inside this app can access app data. The recording is ordinary WAV inside the sandbox, not encrypted with an app-owned per-file key. |
| iOS app data | Database, recordings, and model files are excluded from backup; the app requests `completeUnlessOpen` file protection, which encrypts files on disk while allowing an already-open recording file to keep working after lock. [Apple file protection](https://developer.apple.com/documentation/uikit/encrypting-your-app-s-files) | Physical-device behavior still needs testing, especially background recording, SQLite sidecars, lock/unlock, reboot, and playback. A compromised OS or app process can access data it can legitimately open. |
| Library database | SQLCipher encryption with a random key stored in Android Keystore/iOS Keychain. | Protects database files at rest, not plaintext currently in memory or the WAV audio itself. Test reinstall, migration, and key loss behavior. |
| Audio sharing | Android native share bridge checks canonical paths; Android FileProvider is now limited to the app recordings directory and grants temporary read access only. iOS share bridge accepts saved recordings from its recordings folder. | Once a user chooses another app, that recipient can copy, upload, retain, or share the exported file. |
| Network | Android disallows cleartext traffic; model downloader uses HTTPS to Hugging Face; no ad, analytics, crash, or sync SDK was found in current runtime dependencies. | Confirm every URL/redirect, transitive SDK, and endpoint in the release artifact. Hugging Face and app stores operate their own infrastructure and privacy practices. |
| Microphone | Runtime permission, first-use disclosure, explicit Record action, visible recording state, Android foreground-service notification/Stop action, and participant-consent reminder. | Recording law varies by jurisdiction and by context. The app cannot determine whether the recorder has legal permission from everyone present. |

### Threat statement

No application can honestly guarantee that it is “unhackable” or that data can never be exposed. These controls reduce exposure to other ordinary apps, cloud-service breaches, backup copies, accidental network uploads, and casual access. They do not defeat a compromised/rooted/jailbroken device, operating-system vulnerability, malicious accessibility/service granted by the user, a device unlocked while an attacker can operate it, an exploit in an app dependency, or a destination the user intentionally shares to.

The user-facing promise should therefore be precise: **“Audio and transcripts are processed and stored on this device. Internet is used to download the transcription model. We do not operate an upload or sync service. If you choose to share a file, the selected destination receives it.”** Do not say “nothing ever leaves the device,” “military grade,” or “unhackable.”

## Global privacy and recording-law release gate

There is no single global privacy rule that makes a release lawful in every country. Local-only processing materially reduces the publisher’s data exposure, but it does not automatically exempt the publisher from app-store disclosures, local privacy requirements, consumer/donation rules, children’s rules, or laws governing recording other people.

Before enabling each market, maintain a dated launch matrix that records: legal publisher and contact; privacy-policy language/localization; intended age group; app-store data disclosures; where the app itself or its partners transmit/retain data; user deletion/export behavior; and microphone/participant consent wording. Get qualified local review for the launch territories. As a starting point, monitor:

- **EEA and UK:** GDPR/UK GDPR transparency, privacy by design/default, security, rights handling, and any representative/contact obligations that apply. Audio can be personal data when it identifies a person; user speech may also include other sensitive information. [EU GDPR text](https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng)
- **Brazil:** LGPD applies broadly to personal-data processing related to people in Brazil; confirm the publisher’s role and duties for an offline utility and any external support/payment flow. [Brazil LGPD](https://www.gov.br/anpd/pt-br/centrais-de-conteudo/brazilian-data-protection-law.pdf)
- **India:** The DPDP Rules 2025 have staged commencement, with several rules scheduled 18 months after 13 November 2025 (May 2027). The planned March 2027 launch falls near this transition; recheck the Gazette, Act commencement notifications, and applicability before launch and again in May 2027. [Official Rules 2025 Gazette](https://www.meity.gov.in/static/uploads/2025/11/53450e6e5dc0bfa85ebd78686cadad39.pdf)
- **United States:** State privacy-law coverage and thresholds differ. California law includes audio and education information in personal-information categories, while applicability depends on the actual business and processing facts. Consent-to-record rules can also differ among states. [California privacy agency FAQ](https://www.cppa.ca.gov/faq.html), [California statute text](https://cppa.ca.gov/regulations/pdf/cppa_act.pdf)
- **All markets:** Confirm age-targeting and children’s rules; the product is general-purpose, but a student audience can include minors. Require users to follow local law, tell participants, and obtain consent where required. Never add hidden recording, call capture, or automatic recording.

This list is a planning baseline, not a country-by-country legal opinion or an exhaustive list of jurisdictions. Do not turn on worldwide availability until the actual launch markets are checked; update the matrix as new markets and laws are added.

## Store disclosure and privacy-policy rules

- Google Play requires an accurate Data safety declaration, including relevant third-party code/SDK behavior, and an in-app plus public privacy-policy link. Verify model-download request handling before declaring no data collected. [Google Play Data safety](https://support.google.com/googleplay/android-developer/answer/10787469?hl=en), [Google Play User Data](https://support.google.com/googleplay/android-developer/answer/10144311?hl=en)
- Apple requires App Privacy details covering the app and third-party partners. Apple defines collection around data transmitted off-device and accessible beyond servicing the request; it says data processed only on device is not collected for the label. The model host’s actual request/logging practices still need review for the final declaration. [App Privacy Details](https://developer.apple.com/app-store/app-privacy-details/)
- Every store release must use the same truthful privacy claims. Provide a stable public policy page that is readable worldwide, not a PDF. It can be a simple static page on free static hosting; there is no need for an app API, database, or paid backend. A custom domain is optional and may cost money.
- Explain microphone use before requesting it, present an unmistakable active state, and keep the consent reminder. Apple’s review rule explicitly requires user consent and a clear visual and/or audible recording indicator. [Apple App Review Guidelines 2.5.14](https://developer.apple.com/app-store/review/guidelines/)

## Optional donation rules (not enabled yet)

Wait for a real provider URL. If added later, the donation must remain fully optional, must not unlock any digital feature/service, must not affect recording/transcription, and should open the provider externally without embedding a payment SDK or account. Explain that payment details are entered with the external provider and are governed by its privacy terms. Check provider fees carefully: Google Play’s creator-tip exception says 100% of the contribution must go to the creator and no digital content/service may be granted; Apple’s person-to-person gift exception likewise requires an entirely optional gift and 100% of funds reaching the recipient. If those conditions cannot be met, use the applicable store billing policy or omit the link. [Google Play payments policy](https://support.google.com/googleplay/android-developer/answer/10281818?hl=en), [Apple App Review Guidelines 3.1.1](https://developer.apple.com/app-store/review/guidelines/)

No tax deductibility claim, donation receipt, or charitable-fundraising claim should be made unless the publisher and destination qualify under the relevant local rules.

## Zero recurring app-service cost

The current design uses no publisher-operated backend, database, analytics service, or payment server. Hugging Face hosts model downloads; its terms, availability, and connection logs remain external dependencies. A static privacy page can use free hosting. The user-facing app can stay free without ads.

Publishing still has platform account costs: Google currently lists a US$25 one-time Play Console registration fee; Apple lists US$99 per year for App Store distribution, with fee waivers only for eligible nonprofit, educational, or government organizations. [Google Play Console registration](https://support.google.com/googleplay/android-developer/answer/6112435?hl=en), [Apple Developer Program fee](https://developer.apple.com/programs/whats-included/)

## Before release

- [ ] Check merged release package for ad, analytics, crash, tracking, sync, and upload SDKs; no ad SDK/placement exists in the current dependency/source audit.
- [ ] Capture test-device network traces during first install, idle, recording, transcription, and model download. Expected app-owned destination: Hugging Face for a user-requested model download only.
- [ ] Confirm model endpoint/CDN redirects and document the IP/request-metadata disclosure.
- [ ] Inspect Android backup and FileProvider rules in the final APK/AAB.
- [ ] Test iOS Data Protection and background recording on physical hardware; confirm database, WAL/SHM, audio, and models remain excluded from backup.
- [ ] Test removal, reinstall, migration, restore-from-backup attempt, share, and permanent-delete paths.
- [ ] Review every Play Data safety and Apple App Privacy answer against final binary behavior and partner practices.
- [ ] Finish a launch-market legal/privacy/recording-consent matrix before enabling global country availability.
- [ ] Keep donation UI disabled until a provider URL, fee analysis, data-flow disclosure, tax review, and store-policy check are complete.
- [ ] Do not claim absolute security; describe the actual storage, encryption, network, and sharing behavior.
