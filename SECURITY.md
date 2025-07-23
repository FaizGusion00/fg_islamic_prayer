# Security Policy

## 🔒 Security Overview

FGIslamicPrayer is designed with privacy and security as core principles. This document outlines our security practices and how to report security vulnerabilities.

## 🛡️ Security Features

### Data Privacy
- **No user data collection**: The app does not collect, store, or transmit personal user data
- **Local storage only**: All preferences and cached data are stored locally on the device
- **No analytics or tracking**: No third-party analytics, tracking, or advertising SDKs
- **No user accounts**: No registration, login, or user account system

### Network Security
- **HTTPS only**: All API calls use secure HTTPS connections
- **Public API only**: Uses only the public Aladhan API (no API keys required)
- **Minimal permissions**: Requests only essential Android permissions
- **No background data**: No unnecessary background network activity

### Code Security
- **Open source**: Full source code transparency
- **No obfuscation**: Code is readable and auditable
- **Dependency management**: Regular updates of dependencies
- **Static analysis**: Code follows Flutter/Dart security best practices

## 📱 Permissions Used

The app requests only the following permissions:

| Permission | Purpose | Required |
|------------|---------|----------|
| `INTERNET` | Fetch prayer times from API | Yes |
| `ACCESS_FINE_LOCATION` | Calculate location-based prayer times | Yes |
| `ACCESS_COARSE_LOCATION` | Fallback location for prayer times | Yes |
| `VIBRATE` | Prayer notification vibration | Optional |
| `WAKE_LOCK` | Keep screen on during Qibla compass | Optional |
| `SCHEDULE_EXACT_ALARM` | Precise prayer time notifications | Yes |
| `POST_NOTIFICATIONS` | Show prayer time notifications | Yes |

## 🔐 Supported Versions

We provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| Latest  | ✅ Yes             |
| Previous| ✅ Yes (6 months)  |
| Older   | ❌ No              |

## 🚨 Reporting Security Vulnerabilities

We take security seriously. If you discover a security vulnerability, please report it responsibly:

### How to Report

1. **Email**: Send details to `fgcompany.developer@gmail.com`
2. **Subject**: Use "SECURITY: [Brief Description]"
3. **Include**:
   - Detailed description of the vulnerability
   - Steps to reproduce the issue
   - Potential impact assessment
   - Suggested fix (if available)
   - Your contact information

### What to Expect

- **Acknowledgment**: Within 48 hours
- **Initial assessment**: Within 1 week
- **Regular updates**: Every week until resolved
- **Resolution**: Security patches released as soon as possible

### Responsible Disclosure

We follow responsible disclosure practices:

- We will acknowledge your report promptly
- We will work with you to understand and resolve the issue
- We will credit you in our security advisories (if desired)
- We ask that you do not publicly disclose the vulnerability until we have released a fix

## 🛠️ Security Best Practices for Contributors

If you're contributing to the project:

### Code Security
- Never commit API keys, secrets, or credentials
- Use secure coding practices
- Validate all user inputs
- Follow OWASP mobile security guidelines
- Test security implications of changes

### Dependencies
- Keep dependencies up to date
- Review security advisories for used packages
- Avoid packages with known vulnerabilities
- Use `flutter pub audit` to check for security issues

### Build Security
- Use official Flutter SDK and tools
- Verify checksums of downloaded dependencies
- Build in clean environments
- Sign releases with secure keys

## 🔍 Security Auditing

### Regular Security Checks
- Dependency vulnerability scanning
- Static code analysis
- Permission audit
- Network traffic analysis
- Privacy compliance review

### Tools Used
- `flutter analyze` for static analysis
- `flutter pub audit` for dependency security
- Manual code review for security patterns
- Android security testing tools

## 📋 Security Checklist for Releases

Before each release, we verify:

- [ ] No hardcoded secrets or API keys
- [ ] All dependencies are up to date
- [ ] No new unnecessary permissions
- [ ] Security-sensitive code reviewed
- [ ] Privacy policy compliance
- [ ] Secure build and signing process

## 🤝 Security Community

We welcome security researchers and the community to:

- Review our code for security issues
- Suggest security improvements
- Share security best practices
- Help maintain the security of this Islamic app

## 📞 Contact

For security-related questions or concerns:

- **Email**: fgcompany.developer@gmail.com
- **Subject**: Include "SECURITY" in the subject line
- **Response time**: Within 48 hours

---

**May Allah protect this app and its users from all harm. Ameen.**

بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم