# OpenWorld VPN — Mobile Client

Flutter client application for OpenWorld VPN (Phase 4 scaffold).

## Status

This is an early-stage scaffold. **No real VPN tunnel and no real OAuth
credentials are implemented.** The goal of this phase is to establish the
app architecture, navigation flow, localization, and networking foundation
that later phases will build on.

## Architecture

The app follows a Clean Architecture layering per feature:

```
lib/
├── core/
│   ├── theme/          # Material 3 theme
│   ├── localization/    # English/Chinese localization (no codegen)
│   ├── network/         # ApiClient foundation for backend communication
│   └── utils/           # Shared helpers (Result type, formatters)
│
├── features/
│   ├── auth/
│   │   ├── presentation/  # Splash, Welcome, Login screens
│   │   ├── domain/         # AuthUser, AuthRepository, use cases
│   │   └── data/            # Placeholder auth data source/repository
│   │
│   ├── home/
│   │   └── presentation/   # Home screen + widgets
│   │
│   └── vpn/
│       ├── domain/          # VpnConnectionState, VpnService interface
│       ├── data/             # PlaceholderVpnService, server repository
│       └── presentation/     # VpnController, VPN screen
│
└── main.dart
```

## Localization

English (`en`) and Chinese (`zh`) are supported via a small dependency-free
`AppLocalizations` class (see `lib/core/localization/app_localizations.dart`).
No ARB/codegen build step is required.

## Networking

`lib/core/network/api_client.dart` provides a minimal REST client
(`ApiClient`) built on a transport abstraction (`HttpTransport`), with a
`dart:io`-backed implementation (`IoHttpTransport`) used at runtime and a
fake implementation used in tests. No real backend calls are required to
run the app; the VPN server list falls back to a default "Automatic" entry
if the backend is unreachable.

## VPN

`VpnService` (domain) is implemented today only by `PlaceholderVpnService`,
which simulates connect/disconnect transitions with short delays. **No
real tunnel is established.** A future phase will add a WireGuard-backed
implementation behind the same interface.

## Running

```sh
cd apps/mobile
flutter pub get
flutter analyze
flutter test
flutter run
```
