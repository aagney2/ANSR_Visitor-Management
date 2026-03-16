# ANSR Visitor Management

A production-ready, multi-tenant Flutter visitor management app built on Kelsa APIs. Designed for enterprise check-in kiosks and reception tablets.

## Architecture

```
lib/
├── app/                    # App entry, router
├── config/                 # ClientConfig model & loader
├── core/
│   ├── constants/          # App-wide constants
│   ├── errors/             # Exception types
│   ├── theme/              # Dynamic theming from ClientConfig
│   └── utils/              # Validators, helpers
├── data/
│   ├── api/                # Dio-based ApiClient
│   ├── models/             # KelsaLead, KelsaField, Visitor, etc.
│   ├── repositories/       # VisitorRepository, EmployeeRepository
│   └── services/           # KelsaService, MediaService
├── features/
│   ├── branding/           # Welcome/branding screen
│   ├── onboarding/         # Phone input + consent
│   ├── visitor_checkin/    # Returning visitor, purpose selection
│   ├── employee_select/    # Whom-to-meet search
│   ├── visitor_details/    # Form, photo, signature
│   ├── review/             # Summary + submit
│   └── success/            # Confirmation screen
└── shared/
    ├── providers/          # Riverpod DI providers
    └── widgets/            # Reusable design system components
```

## Setup

### Prerequisites
- Flutter 3.41+ (latest stable)
- Dart 3.11+
- Android Studio or VS Code with Flutter extension
- Physical device or emulator (camera required for full functionality)

### Steps

1. **Clone the repository**
   ```bash
   git clone <repo-url>
   cd ANSR_Visitor-Management
   ```

2. **Set up environment**
   ```bash
   cp .env.example .env
   # Edit .env with your Kelsa API credentials:
   # KELSA_USER_EMAIL=your_email@example.com
   # KELSA_USER_TOKEN=your_token_here
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Multi-Tenant Configuration

### How it works
All branding, pipeline IDs, API credentials, and feature flags come from a `ClientConfig` JSON file loaded at startup. The ANSR config lives at `assets/config/ansr_config.json`.

### Adding a new client

1. Create `assets/config/<client_id>_config.json`:
   ```json
   {
     "clientId": "acme",
     "clientName": "ACME Corp",
     "logoAsset": "assets/images/acme_logo.png",
     "primaryColor": "#2196F3",
     "secondaryColor": "#FF9800",
     "accentColor": "#4CAF50",
     "backgroundColor": "#F5F7FA",
     "surfaceColor": "#FFFFFF",
     "visitorDatabasePipelineId": "99999",
     "visitorManagementPipelineId": "99998",
     "apiBaseUrl": "https://kelsa.io",
     "employeeSource": "mock",
     "termsUrl": "https://acme.com/terms",
     "privacyUrl": "https://acme.com/privacy"
   }
   ```

2. Add the client's logo to `assets/images/`

3. Update the config path in `main.dart`:
   ```dart
   final config = await ClientConfigRepository.load(
     configAsset: 'assets/config/acme_config.json',
   );
   ```

4. Add `.env` credentials for the new client

### Files that control tenant config
- `assets/config/ansr_config.json` — tenant branding, pipeline IDs, URLs
- `.env` — API credentials (never committed)
- `lib/config/client_config.dart` — config model & loader
- `lib/core/theme/app_theme.dart` — theme built from config colors
- `lib/shared/providers/app_providers.dart` — DI wiring

## Credential Management
- **NEVER** commit `.env` to version control
- `.env` is listed in `.gitignore`
- API credentials (`X-User-Email`, `X-User-Token`) are read from environment at runtime
- For production, consider a secure vault or build-time injection

## Kelsa Integration

### Two Pipelines
1. **Visitor Database** (pipeline 13274) — master visitor records
2. **Visitor Management** (pipeline 13273) — individual visit entries

### Custom Field Resolution
Field identifiers (`cf_name`, `cf_email`, etc.) are resolved dynamically:
1. App fetches `/custom_fields?all=true` from each pipeline
2. `CustomFieldMapping` indexes fields by identifier
3. All payloads and queries use actual identifiers from the API
4. No hardcoded field names — adapts if a client uses different identifiers

### Draft Polling
When Kelsa returns a draft instead of a lead, the app polls `GET /drafts/{id}` every 5 seconds until `lead_id` is populated, with a 120-second timeout.

## Known Integration Points

### Employee API
- `EmployeeRepository` is abstracted with `MockEmployeeRepository` (sample data) and `KelsaEmployeeRepository` (placeholder)
- Switch via `employeeSource` in client config (`"mock"` or `"kelsa"`)
- When the real employee API is available, implement `KelsaEmployeeRepository`

### Media Upload
- `MediaService` is abstracted with `LocalMediaService` (saves to device storage)
- Photo and signature are captured and stored locally
- Payloads use the Kelsa-compatible `{"url": "...", "size": ...}` format
- When Kelsa's media upload endpoint is available, implement a `RemoteMediaService`

## Tech Stack
| Component | Package |
|---|---|
| State Management | flutter_riverpod |
| Networking | dio |
| Routing | go_router |
| Camera | image_picker |
| Signature | signature |
| Local Storage | shared_preferences |
| Theming | google_fonts, flutter_animate |
| Environment | flutter_dotenv |
