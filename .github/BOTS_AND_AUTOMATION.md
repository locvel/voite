# Automated Bots and Maintenance Tools

This repository uses several free GitHub bots and workflows for automated maintenance.

## 🤖 Active Automation (Already Working)

### 1. **Dependabot** (dependabot.yml) ✅
- 📦 Automatically checks for dependency updates
- 🔒 Security vulnerability scanning
- 📅 Weekly schedule for Pub (Flutter) and GitHub Actions
- **Cost:** FREE (Built into GitHub)

### 2. **Stale Bot** (stale.yml) ✅
- 🧹 Marks inactive issues/PRs as stale after 60/30 days
- 🗑️ Auto-closes after 14 more days of inactivity
- 🏷️ Exempts pinned, security, and milestone items
- **Cost:** FREE (GitHub Actions)

### 3. **First-Time Contributor Greeting** (greetings.yml) ✅
- 👋 Welcomes first-time contributors
- 📝 Provides helpful guidelines
- 🎉 Creates welcoming community atmosphere
- **Cost:** FREE (GitHub Actions)

### 4. **Auto Labeler** (labeler.yml) ✅
- 🏷️ Automatically labels PRs based on changed files
- 📁 Categories: documentation, android, ios, core, features, etc.
- ⚡ Saves maintainer time
- **Cost:** FREE (GitHub Actions)

### 5. **CodeQL Security Analysis** (codeql.yml) ✅
- 🔒 Scans Java and Swift code for security vulnerabilities
- 📊 Weekly scheduled scans
- 🚨 Alerts on security issues
- **Cost:** FREE (GitHub Advanced Security for public repos)

### 6. **CI/CD Pipeline** (ci.yml) ✅
- ✅ Runs tests on every push/PR with coverage
- 📱 Builds Android APK
- 🔍 Code formatting and analysis
- 📊 Uploads coverage to Codecov
- **Cost:** FREE (GitHub Actions - 2,000 minutes/month)

## 📋 Ready to Install (Configuration Files Added)

### 7. **Codecov** 
- 📊 Test coverage reporting and visualization
- Configuration: `codecov.yml` ✅
- **Cost:** FREE for public repos
- **Install:** https://github.com/apps/codecov

### 8. **All Contributors Bot**
- 🎖️ Recognizes all types of contributions
- Configuration: `.all-contributorsrc` ✅
- **Cost:** FREE forever
- **Install:** https://github.com/apps/allcontributors

### 9. **ImgBot**
- 🖼️ Optimizes images automatically (PNG, JPG)
- Configuration: `.imgbotconfig` ✅
- **Cost:** FREE for public repos
- **Install:** https://github.com/apps/imgbot

## ⚠️ NOT Using (Conflicts with Dependabot)

### ❌ Renovate Bot
- Would duplicate Dependabot's work
- You already have Dependabot (built-in, easier)
- Don't install Renovate to avoid duplicate PRs

## 🎯 Installation Instructions

See detailed step-by-step guide: `.github/BOT_INSTALLATION_GUIDE.md`

Or install directly:
1. Codecov: https://github.com/apps/codecov
2. All Contributors: https://github.com/apps/allcontributors
3. ImgBot: https://github.com/apps/imgbot

## 💰 Total Cost

**$0.00/month forever** - All tools are free for public open-source repositories.

## 📊 Monitoring

View all automation activity:
- **Actions**: https://github.com/locvel/voite/actions
- **Security**: https://github.com/locvel/voite/security
- **Insights**: https://github.com/locvel/voite/pulse
- **Dependencies**: https://github.com/locvel/voite/network/dependencies
