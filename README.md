# Paul

**Paul Audits User's Life** — a minimalist personal budget tracker for Android.

## Features

- Log expenses with amount, currency (EUR / JPY), and category tag
- Visualize monthly spending with pie charts, split by currency
- Navigate across months to review history
- Swipe to delete individual expenses
- Export the SQLite database for backup

## Tech stack

- Flutter (Dart)
- SQLite via `sqflite`
- `fl_chart` for pie charts
- `share_plus` for database export
- `url_launcher`

## Getting started

```bash
flutter pub get
flutter run
```

Requires Android SDK and a connected device or emulator.

## Project structure

```
lib/
├── main.dart
├── constants/app_constants.dart
├── models/expense.dart
├── database/database_helper.dart
├── screens/
│   ├── add_expense_screen.dart
│   ├── stats_screen.dart
│   └── settings_screen.dart
└── widgets/
    ├── currency_selector.dart
    ├── tag_chip_group.dart
    ├── month_navigator.dart
    └── expense_pie_chart.dart
```

## License

MIT — see [LICENSE.md](LICENSE.md).
