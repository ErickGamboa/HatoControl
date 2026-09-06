package cr.co.hato_control

import android.content.Context
import android.hardware.input.InputManager
import android.os.Handler
import android.os.Looper
import android.view.InputDevice
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Le avisa a Flutter si hay un teclado fisico conectado.
 *
 * El lector de aretes entra por Bluetooth como teclado (HID). Cuando Android ve
 * uno, deja de mostrar el teclado en pantalla salvo que el usuario prenda un
 * ajuste escondido, asi que la app pone el suyo (ver TecladoDelApp en Dart).
 */
class TecladoFisicoNativo(context: Context, messenger: BinaryMessenger) :
    InputManager.InputDeviceListener {

    private val canal = MethodChannel(messenger, CANAL)
    private val inputManager =
        context.getSystemService(Context.INPUT_SERVICE) as InputManager

    init {
        canal.setMethodCallHandler { llamada, resultado ->
            when (llamada.method) {
                "hayTecladoFisico" -> resultado.success(hayTecladoFisico())
                else -> resultado.notImplemented()
            }
        }
        inputManager.registerInputDeviceListener(this, Handler(Looper.getMainLooper()))
    }

    fun soltar() {
        inputManager.unregisterInputDeviceListener(this)
        canal.setMethodCallHandler(null)
    }

    override fun onInputDeviceAdded(deviceId: Int) = avisar()

    override fun onInputDeviceRemoved(deviceId: Int) = avisar()

    override fun onInputDeviceChanged(deviceId: Int) = avisar()

    private fun avisar() {
        canal.invokeMethod("cambio", hayTecladoFisico())
    }

    /**
     * Solo cuenta un teclado de verdad: Android siempre lista un dispositivo
     * "virtual" que no es ninguno fisico, y muchos accesorios se anuncian como
     * teclado sin tener teclas (KEYBOARD_TYPE_NON_ALPHABETIC).
     */
    private fun hayTecladoFisico(): Boolean =
        InputDevice.getDeviceIds().any { id ->
            val aparato = InputDevice.getDevice(id) ?: return@any false
            !aparato.isVirtual &&
                aparato.keyboardType == InputDevice.KEYBOARD_TYPE_ALPHABETIC &&
                (aparato.sources and InputDevice.SOURCE_KEYBOARD) ==
                    InputDevice.SOURCE_KEYBOARD
        }

    companion object {
        /** El mismo nombre que en teclado_fisico.dart. */
        const val CANAL = "hato_control/teclado_fisico"
    }
}
