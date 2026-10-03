# Flexible Packaging — Clean Build

এই সংস্করণে মূল Dart কোডটি নতুন করে পরিষ্কার, readable এবং multi-line structure-এ সাজানো হয়েছে। আগের compressed `main.dart`-এর bracket/syntax সমস্যা সরানো হয়েছে।

## কী আছে
- Firebase Authentication: email/password registration, login, password reset
- Firestore user profile support
- Firebase Storage upload service প্রস্তুত
- Firebase Cloud Messaging token registration
- Job list, job details, saved jobs
- Application list
- Technical learning section
- Profile, CV/Resume section, settings
- Admin dashboard, jobs, applications, users, news, analytics UI
- GitHub Actions দিয়ে release APK build

## Firebase
`google-services.json`-এর Android package name `com.flexiblepackaging.app`-এর সাথে মিল রেখে workflow Android application ID সেট করে।

## Build
GitHub repository-তে push করার পর **Actions → Build Flexible Packaging APK → Run workflow** চালান। Workflow নিজে Android project generate করে, Firebase config বসায়, `dart format`/`flutter analyze` চালায় এবং release APK তৈরি করে।

> এই ZIP-এ Android generated folder ইচ্ছাকৃতভাবে রাখা হয়নি; GitHub Actions প্রতিবার clean Android project তৈরি করবে।
