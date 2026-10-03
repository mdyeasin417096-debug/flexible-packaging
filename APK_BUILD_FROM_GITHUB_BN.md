# Flexible Packaging — ফোন থেকেই APK build করার সহজ পদ্ধতি

1. এই project-টি GitHub-এ একটি repository হিসেবে upload করুন।
2. Repository-এর নাম যেকোনো হতে পারে, যেমন `flexible-packaging`।
3. `main` branch-এ code upload করুন।
4. GitHub-এর **Actions** tab খুলুন।
5. `Build Flexible Packaging APK` workflow নির্বাচন করুন।
6. **Run workflow** চাপুন।
7. Build শেষ হলে workflow-এর **Artifacts** অংশে `flexible-packaging-release-apk` পাবেন।
8. Artifact download করে ZIP খুললে `app-release.apk` পাবেন।
9. APK ফোনে এনে install করুন।

## গুরুত্বপূর্ণ

এই source-এর বর্তমান app UI/demo data-তে Firebase SDK ব্যবহার এখনো সম্পূর্ণ wired-in নয়। `google-services.json` build workflow-তে Android project-এর `app` folder-এ বসানো হচ্ছে। বাস্তব Firebase Login/OTP/Firestore/Storage/FCM চালু করার জন্য পরের development step-এ Firebase packages ও backend logic যোগ করতে হবে।
