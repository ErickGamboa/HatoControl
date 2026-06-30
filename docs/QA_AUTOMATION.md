# QA automation and invariants plan

## Test pyramid

1. **Unit tests**: validators, date/weight calculations, sync mappers.
2. **Repository tests**: local-first behavior using an in-memory Drift DB.
3. **Sync tests**: fake remote gateway; no real Supabase in CI.
4. **Widget tests**: key screens with fake repositories/services.
5. **Integration/manual device tests**: real iPhone/Mac + Supabase staging.

## Critical invariants to automate

### Local-first sync
- Every repository write to a syncable table sets `pendiente=true`.
- Every update changes `updatedAt`.
- Soft delete sets `deletedAt`, `updatedAt`, and `pendiente=true`.
- Failed upload leaves the row pending.
- Successful upload clears only that row's pending flag.

### Fincas and licensing
- Cannot create a finca without known local account/license state.
- Cannot create more fincas than the local plan limit allows.
- Creating a finca also creates admin membership in the same transaction.
- Collaborator fincas do not count toward the owner account limit.

### Members and roles
- User cannot be duplicated in the same finca.
- Role must be `admin` or `operario`.
- Removing access is a soft delete, not a hard delete.

### Lotes, animals, pesajes
- Animal identifier is unique inside a finca.
- Creating an animal also creates the first pesaje in the same transaction.
- Peso must be positive.
- Moving an animal updates `loteId`, `updatedAt`, and `pendiente`.
- Current weight is the latest non-deleted pesaje.
- Daily gain uses calendar-day difference, not exact 24-hour blocks.

### Sync cursors
- Cursors are per table.
- A cursor must not advance past rows that were not applied locally.
- Downloads must preserve local-only fields such as `fotoLocalPath` and `fotoPendiente`.

## Suggested CI
Create `.github/workflows/ci.yml` when GitHub is used:

```yaml
name: CI
on:
  pull_request:
  push:
    branches: [ main ]
jobs:
  flutter:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter pub get
      - run: dart format --output=none --set-exit-if-changed lib test
      - run: flutter analyze
      - run: flutter test
```

## Local QA commands

```bash
flutter pub get
dart format lib test
flutter analyze
flutter test
```

After Drift schema edits:

```bash
dart run build_runner build --delete-conflicting-outputs
```

## Manual test checklist for Mac/iPhone

### Account/auth
- Sign up / log in / log out.
- App handles no connection on startup.
- Account suspended screen works if server marks account suspended.

### Offline-first
- Turn off network.
- Create finca, lote, animal, and pesaje.
- Reopen app: data still appears.
- Turn network on: sync uploads pending rows.
- Log into another device: synced data appears.

### Photos
- Add finca photo offline.
- Reconnect: photo uploads.
- Confirm `fotoUrl` displays on another device.

### Permissions
- Admin can invite/remove member.
- Operario can operate but not administer members.
- Removed member loses access after sync.

### Data correctness
- Duplicate animal identifier in same finca is rejected.
- Same identifier in another finca is allowed.
- Delete pesaje: current weight recalculates.
- Move animal to another lote: animal disappears from old lote and appears in new lote.
