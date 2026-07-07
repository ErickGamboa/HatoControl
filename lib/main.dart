import 'package:hato_control/app_bootstrap.dart' as app;

Future<void> main() async {
  await app.bootstrapHatoControl();
  app.runHatoControlApp();
}
