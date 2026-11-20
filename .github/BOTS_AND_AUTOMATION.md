# Automated Bots and Maintenance Tools

This repository uses several free GitHub bots and workflows for automated maintenance:

## 🤖 Active Automation

### 1. **Dependabot** (dependabot.yml)
- 📦 Automatically checks for dependency updates
- 🔒 Security vulnerability scanning
- 📅 Weekly schedule
- **Free**: Built into GitHub

### 2. **Stale Bot** (stale.yml)
- 🧹 Marks inactive issues/PRs as stale after 60/30 days
- 🗑️ Auto-closes after 14 more days of inactivity
- 🏷️ Exempts pinned, security, and milestone items
- **Free**: GitHub Actions

### 3. **First-Time Contributor Greeting** (greetings.yml)
- 👋 Welcomes first-time contributors
- 📝 Provides helpful guidelines
- 🎉 Creates welcoming community atmosphere
- **Free**: GitHub Actions

### 4. **Auto Labeler** (labeler.yml)
- 🏷️ Automatically labels PRs based on changed files
- 📁 Categories: documentation, android, ios, core, features, etc.
- ⚡ Saves maintainer time
- **Free**: GitHub Actions

### 5. **CodeQL Security Analysis** (codeql.yml)
- 🔒 Scans Java and Swift code for security vulnerabilities
- 📊 Weekly scheduled scans
- 🚨 Alerts on security issues
- **Free**: GitHub Advanced Security (free for public repos)

### 6. **CI/CD Pipeline** (ci.yml)
- ✅ Runs tests on every push/PR
- 📱 Builds Android APK
- 🔍 Code formatting and analysis
- **Free**: GitHub Actions (2,000 minutes/month for free accounts)

## 📋 Recommended Additional Bots (Manual Setup Required)

### 7. **Codecov** 
- 📊 Test coverage reporting
- Setup: https://codecov.io
- **Free** for public repos

### 8. **All Contributors Bot**
- 🎖️ Recognizes all contributors
- Setup: https://allcontributors.org
- **Free**

### 9. **ImgBot**
- 🖼️ Optimizes images automatically
- Setup: https://imgbot.net
- **Free** for public repos

### 10. **Renovate Bot**
- 🔄 Alternative to Dependabot with more features
- Setup: https://github.com/apps/renovate
- **Free**

## 🎯 How to Add More Bots

1. Go to https://github.com/marketplace?type=apps
2. Filter by "Free" pricing
3. Install apps for: Locvel organization
4. Configure in repository settings

## 📊 Monitoring

View all automation activity:
- **Actions**: https://github.com/locvel/voite/actions
- **Security**: https://github.com/locvel/voite/security
- **Insights**: https://github.com/locvel/voite/pulse
