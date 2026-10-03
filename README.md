# SQA QA Dashboard (Flutter)

Documentation app for SQA Internship Day 2 & Day 3 (HisabDo testing).

## Run it
1. Make sure the folder is named `sqa_qa_dashboard`.
2. Open it in VS Code, then in the terminal run:
   flutter create .          (adds android/ios/web folders; keeps lib/ and pubspec.yaml)
   flutter pub get
   flutter run -d chrome     (or pick any device)
3. Use "Clear sample data" on the Dashboard to remove the sample entries.

## Files
- lib/main.dart            app + side menu / drawer
- lib/ui.dart              colors, theme, shared widgets (cards, pills, form fields)
- lib/models.dart          data classes + dropdown option lists
- lib/store.dart           in-memory data + statistics (ChangeNotifier)
- lib/screens/*.dart       one file per screen

Data lives in memory only (resets on restart).
