# Security Policy

## Supported versions

Security fixes are provided for the latest released 1.x version of Voite.
Development snapshots and forks are not supported.

| Version | Supported |
| --- | --- |
| 1.x | Yes |
| < 1.0 | No |

## Reporting a vulnerability

Please **do not** open a public GitHub issue for a security problem.

Report privately using either channel:

1. GitHub's **Report a vulnerability** button in the repository's Security tab
   (private vulnerability reporting).
2. Email **hello.locvel@gmail.com** with `Voite security` in the subject line.

Include as much of the following as you can:

- Affected app version, commit, and platform (Android/iOS version and device).
- A clear description of the issue and its impact.
- Reproduction steps or a minimal proof of concept.
- Whether the issue requires a rooted/jailbroken device, physical access, a
  malicious file, a compromised model download, or no special conditions.
- Any suggested fix or mitigation.

Do not attach real recordings, transcripts, diary entries, encryption keys, or
other personal data. Use synthetic examples. If a proof of concept needs a
recording, generate a tone or use the public benchmark fixture.

## Scope

Examples of in-scope reports:

- Exposure of recordings, transcripts, diary entries, encryption keys, or model
  files beyond the app sandbox.
- SQLCipher key handling, database sidecar files, or backup/export leaks.
- Model-download verification bypasses, path traversal, or unsafe archive/file
  handling.
- Method-channel or intent handling that lets another app read, overwrite, or
  trigger a recording without user action.
- Share-sheet, PDF, or text-export paths that disclose more data than the user
  selected.
- Authentication or authorization flaws in any future sync/account feature.
- Dependency vulnerabilities with a demonstrated impact on Voite.

Examples that are usually out of scope:

- Issues that require a jailbroken or rooted device, or code execution with the
  app's own privileges.
- Physical access to an unlocked phone.
- Social engineering, phishing, or denial of service against a user's device.
- Missing security headers on a marketing page that does not handle app data.
- Reports based only on a dependency version number without a demonstrated path
  to impact.

## What to expect

Locvel will acknowledge a good-faith report when possible, investigate it, and
keep the reporter informed of material progress. Response times are best effort;
this is a small independent project. Please allow reasonable time for a fix
before public disclosure.

There is no bug bounty program at this time. Credit can be included in the
release notes if you want it.

## Safe harbor

Locvel will not pursue legal action for good-faith security research that
respects user privacy, avoids destroying data, and does not access accounts or
recordings that do not belong to the researcher. Stop testing and report
immediately if you encounter personal data.

## Related documents

- [Privacy policy](https://locvel.github.io/voite/privacy.html)
- [Privacy and security baseline](docs/PRIVACY_SECURITY_BASELINE.md)
- [Model provenance](docs/MODEL_PROVENANCE.md)
