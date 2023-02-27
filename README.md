# Breadcrumb bug

Reproducible example for `from_arguments`/`to_arguments` key/value pairs not being removed from breadcrumbs before being sent to Sentry.

## Getting Started

`flutter run --dart-define="dsn=<your_dsn>"`