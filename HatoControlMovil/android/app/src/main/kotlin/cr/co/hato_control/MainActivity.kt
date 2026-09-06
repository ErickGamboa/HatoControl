package cr.co.hato_control

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    private var tecladoFisico: TecladoFisicoNativo? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        tecladoFisico =
            TecladoFisicoNativo(this, flutterEngine.dartExecutor.binaryMessenger)
    }

    override fun onDestroy() {
        tecladoFisico?.soltar()
        tecladoFisico = null
        super.onDestroy()
    }
}
