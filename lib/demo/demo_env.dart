/// Compile-time flags for demo / tour builds (`--dart-define=...`).
///
/// Dart's [bool.fromEnvironment] only treats the literal `true` as enabled;
/// shell scripts often pass `SEED_DEMO=1`, so we accept common truthy strings.
const _seedDemoRaw = String.fromEnvironment('SEED_DEMO', defaultValue: '');

const kSeedDemoEnabled =
    _seedDemoRaw == 'true' ||
    _seedDemoRaw == '1' ||
    _seedDemoRaw == 'yes' ||
    _seedDemoRaw == 'TRUE' ||
    _seedDemoRaw == 'YES';
