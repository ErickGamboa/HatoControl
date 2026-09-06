package cr.co.hato_control

import android.content.Context
import android.database.ContentObserver
import android.hardware.input.InputManager
import android.os.Handler
import android.os.Looper
import android.provider.Settings
import android.view.InputDevice
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel

/**
 * Le avisa a Flutter si Android tiene escondido su teclado en pantalla.
 *
 * El lector de aretes entra por Bluetooth como teclado (HID). Con uno
 * conectado Android esconde el suyo, salvo que el usuario prenda «mostrar
 * teclado en pantalla» (Ajustes > Sistema > Teclado fisico). Se miran las dos
 * cosas: si solo se mirara el lector, con ese ajuste prendido saldrian los dos
 * teclados a la vez, el de Android y el de la app.
 */
class TecladoDelSistemaNativo(context: Context, messenger: BinaryMessenger) :
    InputManager.InputDeviceListener {

    private val canal = MethodChannel(messenger, CANAL)
    private val inputManager =
        context.getSystemService(Context.INPUT_SERVICE) as InputManager
    private val resolver = context.contentResolver
    private val enElHiloPrincipal = Handler(Looper.getMainLooper())

    /** El ajuste se puede cambiar con la app abierta. */
    private val observadorDelAjuste = object : ContentObserver(enElHiloPrincipal) {
        override fun onChange(selfChange: Boolean) = avisar()
    }

    init {
        canal.setMethodCallHandler { llamada, resultado ->
            when (llamada.method) {
                "estaEscondido" -> resultado.success(estaEscondido())
                else -> resultado.notImplemented()
            }
        }
        inputManager.registerInputDeviceListener(this, enElHiloPrincipal)
        resolver.registerContentObserver(
            Settings.Secure.getUriFor(AJUSTE_TECLADO_EN_PANTALLA),
            false,
            observadorDelAjuste,
        )
    }

    fun soltar() {
        inputManager.unregisterInputDeviceListener(this)
        resolver.unregisterContentObserver(observadorDelAjuste)
        canal.setMethodCallHandler(null)
    }

    override fun onInputDeviceAdded(deviceId: Int) = avisar()

    override fun onInputDeviceRemoved(deviceId: Int) = avisar()

    override fun onInputDeviceChanged(deviceId: Int) = avisar()

    private fun avisar() {
        canal.invokeMethod("cambio", estaEscondido())
    }

    private fun estaEscondido(): Boolean =
        hayTecladoFisico() && !mostrarTecladoEnPantalla()

    private fun mostrarTecladoEnPantalla(): Boolean =
        try {
            Settings.Secure.getInt(resolver, AJUSTE_TECLADO_EN_PANTALLA, 0) == 1
        } catch (e: Settings.SettingNotFoundException) {
            false
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
        /** El mismo nombre que en teclado_del_sistema.dart. */
        const val CANAL = "hato_control/teclado_del_sistema"

        /**
         * `Settings.Secure.SHOW_IME_WITH_HARD_KEYBOARD`, que es @hide: se usa
         * la clave por nombre, que es publica y estable.
         */
        const val AJUSTE_TECLADO_EN_PANTALLA = "show_ime_with_hard_keyboard"
    }
}
