package cr.co.hato_control

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var tecladoDelSistema: TecladoDelSistemaNativo? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        tecladoDelSistema =
            TecladoDelSistemaNativo(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {
        tecladoDelSistema?.soltar()
        tecladoDelSistema = null
        super.onDestroy()
    }
}
