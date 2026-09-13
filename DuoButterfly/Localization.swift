import Foundation
import Observation

enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case system, ru, en, zh = "zh-Hans", es
    var id: String { rawValue }
    var nativeName: String {
        switch self {
        case .system: tr("Как в системе")
        case .ru: "Русский"
        case .en: "English"
        case .zh: "简体中文"
        case .es: "Español"
        }
    }
}

/// Interface language, switchable at runtime. Views re-render because `language` is observed.
@Observable final class Localizer: @unchecked Sendable {
    static let shared = Localizer()

    var language: AppLanguage {
        didSet {
            let defaults = UserDefaults.standard
            defaults.set(language.rawValue, forKey: "language")
            // System menus and panels pick this up on the next launch.
            if language == .system { defaults.removeObject(forKey: "AppleLanguages") }
            else { defaults.set([language.rawValue], forKey: "AppleLanguages") }
        }
    }

    /// Interface language used inside the test host; screenshot tests switch it.
    nonisolated(unsafe) static var testLanguage: AppLanguage = .ru

    init() {
        language = AppLanguage(rawValue: UserDefaults.standard.string(forKey: "language") ?? "") ?? .system
    }

    var effective: AppLanguage {
        // Tests assert the original Russian copy regardless of the machine's language.
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil { return Self.testLanguage }
        return language == .system ? Self.systemLanguage : language
    }

    static var systemLanguage: AppLanguage {
        let global = UserDefaults.standard.persistentDomain(forName: UserDefaults.globalDomain)
        let preferred = (global?["AppleLanguages"] as? [String]) ?? Locale.preferredLanguages
        for code in preferred {
            if code.hasPrefix("ru") { return .ru }
            if code.hasPrefix("en") { return .en }
            if code.hasPrefix("zh") { return .zh }
            if code.hasPrefix("es") { return .es }
        }
        return .en
    }

    func translate(_ key: String) -> String {
        let language = effective
        guard language != .ru && language != .system, let entry = translations[key] else { return key }
        switch language {
        case .en: return entry.en
        case .zh: return entry.zh
        case .es: return entry.es
        case .ru, .system: return key
        }
    }

    static func hasTranslation(_ key: String) -> Bool { translations[key] != nil }
}

/// Russian source text is the key.
func tr(_ key: String) -> String { Localizer.shared.translate(key) }
func tr(_ key: String, _ arguments: CVarArg...) -> String {
    String(format: Localizer.shared.translate(key), arguments: arguments)
}

private let translations: [String: (en: String, zh: String, es: String)] = [
    // Languages and sections
    "Как в системе": ("System", "跟随系统", "Como el sistema"),
    "Эффект": ("Effect", "效果", "Efecto"),
    "Настройки": ("Settings", "设置", "Ajustes"),
    "О программе": ("About", "关于", "Acerca de"),
    "Раздел": ("Section", "分区", "Sección"),

    // Styles
    "Шёлк": ("Silk", "丝绸", "Seda"),
    "Сумерки": ("Dusk", "暮色", "Crepúsculo"),
    "Туман": ("Mist", "薄雾", "Niebla"),
    "Мягкий изгиб": ("Soft bend", "柔和弯曲", "Curva suave"),
    "Глубокие тени": ("Deep shadows", "深邃阴影", "Sombras profundas"),
    "Матовое стекло": ("Frosted glass", "磨砂玻璃", "Vidrio esmerilado"),

    // Status
    "Подключаем датчик…": ("Connecting sensor…", "正在连接传感器…", "Conectando el sensor…"),
    "На паузе": ("Paused", "已暂停", "En pausa"),
    "Экран выключен": ("Display is off", "屏幕已关闭", "Pantalla apagada"),
    "Нужен доступ к экрану": ("Screen access needed", "需要屏幕访问权限", "Se necesita acceso a la pantalla"),
    "Требуется внимание": ("Needs attention", "需要处理", "Requiere atención"),
    "Демонстрация": ("Demo", "演示中", "Demostración"),
    "Датчик недоступен": ("Sensor unavailable", "传感器不可用", "Sensor no disponible"),
    "Работает": ("Active", "运行中", "Activo"),
    "Подготовка эффекта": ("Preparing effect", "正在准备效果", "Preparando el efecto"),
    "Готов к работе": ("Ready", "就绪", "Listo"),
    "Состояние: %@": ("Status: %@", "状态：%@", "Estado: %@"),
    "Остановить демонстрацию": ("Stop Demo", "停止演示", "Detener demostración"),
    "Приостановить эффект": ("Pause Effect", "暂停效果", "Pausar efecto"),
    "Включить эффект": ("Turn On Effect", "开启效果", "Activar efecto"),

    // Header
    "ВКЛ": ("ON", "开", "SÍ"),
    "ВЫКЛ": ("OFF", "关", "NO"),
    "Эффект включен": ("Effect on", "效果已开启", "Efecto activado"),
    "Приостановить эффект — ⌘⌥B": ("Pause effect — ⌘⌥B", "暂停效果 — ⌘⌥B", "Pausar efecto — ⌘⌥B"),
    "Включить эффект — ⌘⌥B": ("Turn on effect — ⌘⌥B", "开启效果 — ⌘⌥B", "Activar efecto — ⌘⌥B"),

    // Preview and demo
    "Предпросмотр": ("Preview", "预览", "Vista previa"),
    "Пример рабочего стола с эффектом DUO Butterfly": ("Sample desktop with the DUO Butterfly effect", "应用 DUO Butterfly 效果的示例桌面", "Escritorio de ejemplo con el efecto de DUO Butterfly"),
    "Угол крышки в примере": ("Sample lid angle", "示例屏幕盖角度", "Ángulo de la tapa en el ejemplo"),
    "%ld градусов": ("%ld degrees", "%ld 度", "%ld grados"),
    "При %ld° и шире эффекта нет. Сдвиньте ползунок влево.": ("There is no effect at %ld° or wider. Move the slider left.", "角度达到 %ld° 或更大时没有效果。请向左拖动滑块。", "A %ld° o más no hay efecto. Mueva el control a la izquierda."),
    "Ползунок изображает угол крышки: чем меньше угол, тем сильнее эффект.": ("The slider stands for the lid angle: the smaller the angle, the stronger the effect.", "滑块代表屏幕盖角度：角度越小，效果越强。", "El control representa el ángulo de la tapa: cuanto menor es, más intenso es el efecto."),
    "Стиль и настройка эффекта находятся в разделе «Настройки».": ("Style and effect adjustments are in Settings.", "样式和效果调整位于“设置”中。", "El estilo y los ajustes del efecto están en Ajustes."),
    "Открыть": ("Open", "打开", "Abrir"),
    "Проверить на рабочем столе": ("Try on the desktop", "在桌面上试用", "Probar en el escritorio"),
    "Эффект на вашем экране": ("The effect on your screen", "在您的屏幕上查看效果", "El efecto en su pantalla"),
    "Остановить": ("Stop", "停止", "Detener"),
    "Показать": ("Show", "展示", "Mostrar"),
    "Разрешить доступ…": ("Allow Access…", "允许访问…", "Permitir acceso…"),
    "Нужен доступ к записи экрана. Кадры не покидают этот Mac.": ("Screen recording access is required. Frames never leave this Mac.", "需要屏幕录制权限。画面不会离开这台 Mac。", "Se necesita acceso a la grabación de pantalla. Los fotogramas no salen de este Mac."),
    "Идет демонстрация. Esc или ⌘⌥B — остановить.": ("Demo in progress. Press Esc or ⌘⌥B to stop.", "正在演示。按 Esc 或 ⌘⌥B 停止。", "Demostración en curso. Pulse Esc o ⌘⌥B para detenerla."),
    "Пятисекундная демонстрация на экране MacBook.": ("A five-second demo on the MacBook display.", "在 MacBook 屏幕上演示五秒钟。", "Una demostración de cinco segundos en la pantalla del MacBook."),

    // Attention banner
    "Эффект на паузе": ("Effect is paused", "效果已暂停", "El efecto está en pausa"),
    "Рабочий стол не реагирует на крышку. Включить можно и сочетанием ⌘⌥B.": ("The desktop ignores the lid. You can also turn it on with ⌘⌥B.", "桌面不会响应屏幕盖。也可以按 ⌘⌥B 开启。", "El escritorio no reacciona a la tapa. También puede activarlo con ⌘⌥B."),
    "Включить": ("Turn On", "开启", "Activar"),
    "Нужен доступ к записи экрана": ("Screen recording access needed", "需要屏幕录制权限", "Se necesita acceso a la grabación de pantalla"),
    "Без него эффект не сможет изменить рабочий стол. Изображение обрабатывается только на этом Mac.": ("Without it the effect can't change the desktop. The image is processed only on this Mac.", "没有此权限，效果无法改变桌面。图像仅在这台 Mac 上处理。", "Sin él, el efecto no puede cambiar el escritorio. La imagen se procesa solo en este Mac."),
    "Уже разрешено?": ("Already allowed?", "已经允许？", "¿Ya lo permitió?"),
    "Эффект не запустился": ("The effect didn't start", "效果未能启动", "El efecto no se inició"),
    "Проверить снова": ("Check Again", "重新检查", "Volver a comprobar"),
    "Датчик угла крышки недоступен": ("Lid angle sensor unavailable", "屏幕盖角度传感器不可用", "Sensor del ángulo de la tapa no disponible"),
    "%@ Эффект можно проверить кнопкой «Показать».": ("%@ You can still try the effect with Show.", "%@ 仍可通过“展示”按钮查看效果。", "%@ Puede probar el efecto con Mostrar."),

    // Style and parameters
    "Стиль": ("Style", "样式", "Estilo"),
    "изменен": ("modified", "已修改", "modificado"),
    "Вернуть": ("Restore", "恢复", "Restaurar"),
    "Вернуть изгиб, размытие и затемнение стиля «%@»": ("Restore the bend, blur and darkness of “%@”", "恢复“%@”的弯曲、模糊和变暗", "Restaurar la curva, el desenfoque y el oscurecimiento de «%@»"),
    "Настройка эффекта": ("Effect adjustments", "效果调整", "Ajustes del efecto"),
    "Изгиб": ("Bend", "弯曲", "Curva"),
    "Размытие": ("Blur", "模糊", "Desenfoque"),
    "Затемнение": ("Darkness", "变暗", "Oscurecimiento"),
    "%ld процентов": ("%ld percent", "百分之 %ld", "%ld por ciento"),
    "Угол отключения": ("Cutoff angle", "关闭角度", "Ángulo de desactivación"),
    "Угол отключения эффекта": ("Effect cutoff angle", "效果关闭角度", "Ángulo de desactivación del efecto"),
    "Крышка открыта на %ld° или шире — эффекта нет.": ("No effect when the lid is open %ld° or wider.", "屏幕盖打开 %ld° 或更大时没有效果。", "Sin efecto con la tapa abierta a %ld° o más."),
    "Сбросить настройки эффекта": ("Reset Effect Settings", "重置效果设置", "Restablecer ajustes del efecto"),
    "Вернуть стандартный стиль, изгиб, размытие, затемнение и угол отключения. Звук и автозапуск сохранятся.": ("Restore the default style, bend, blur, darkness and cutoff angle. Sound and login settings are kept.", "恢复默认样式、弯曲、模糊、变暗和关闭角度。声音和登录启动设置保持不变。", "Restaura el estilo, la curva, el desenfoque, el oscurecimiento y el ángulo predeterminados. El sonido y el inicio se conservan."),

    // General settings
    "Основные": ("General", "通用", "General"),
    "Язык интерфейса": ("Language", "界面语言", "Idioma"),
    "Меню macOS и системные окна сменят язык после перезапуска приложения.": ("macOS menus and system panels switch language after the app restarts.", "macOS 菜单和系统窗口将在应用重启后切换语言。", "Los menús de macOS y los paneles del sistema cambian de idioma al reiniciar la app."),
    "Включить или приостановить": ("Turn on or pause", "开启或暂停", "Activar o pausar"),
    "Запускать при входе в систему": ("Open at login", "登录时打开", "Abrir al iniciar sesión"),
    "Звук при открытии крышки": ("Sound when opening the lid", "打开屏幕盖时播放声音", "Sonido al abrir la tapa"),
    "Короткий щелчок, когда эффект полностью исчезает.": ("A short click when the effect fully disappears.", "效果完全消失时发出轻微的咔哒声。", "Un clic breve cuando el efecto desaparece por completo."),
    "Прослушать": ("Play", "试听", "Escuchar"),
    "Прослушать звук": ("Play sound", "试听声音", "Escuchar el sonido"),
    "Доступ и конфиденциальность": ("Access and privacy", "访问与隐私", "Acceso y privacidad"),
    "Запись экрана": ("Screen recording", "屏幕录制", "Grabación de pantalla"),
    "Разрешена": ("Allowed", "已允许", "Permitida"),
    "Не разрешена": ("Not allowed", "未允许", "No permitida"),
    "Доступ включен, но не работает?": ("Access is on but not working?", "已开启权限但无法使用？", "¿El acceso está activado pero no funciona?"),
    "Кадры обрабатываются в памяти этого Mac. DUO Butterfly не сохраняет снимки, не записывает звук и не отправляет содержимое экрана в интернет. Когда эффект не нужен, захват останавливается.": ("Frames are processed in this Mac's memory. DUO Butterfly doesn't save screenshots, record audio or send screen content to the internet. Capture stops when the effect isn't needed.", "画面在这台 Mac 的内存中处理。DUO Butterfly 不会保存截图、录制声音或将屏幕内容发送到互联网。不需要效果时会停止捕获。", "Los fotogramas se procesan en la memoria de este Mac. DUO Butterfly no guarda capturas, no graba audio ni envía el contenido de la pantalla a internet. La captura se detiene cuando el efecto no es necesario."),
    "Открыть настройки конфиденциальности": ("Open Privacy Settings", "打开隐私设置", "Abrir ajustes de privacidad"),
    "Диагностика": ("Diagnostics", "诊断", "Diagnóstico"),
    "Модель Mac": ("Mac model", "Mac 型号", "Modelo de Mac"),
    "Угол крышки": ("Lid angle", "屏幕盖角度", "Ángulo de la tapa"),
    "Нет данных": ("No data", "无数据", "Sin datos"),
    "Датчик": ("Sensor", "传感器", "Sensor"),
    "Состояние": ("Status", "状态", "Estado"),
    "Скопировано": ("Copied", "已复制", "Copiado"),
    "Скопировать отчет": ("Copy Report", "复制报告", "Copiar informe"),
    "Скопировать состояние приложения без изображений экрана — для сообщения об ошибке": ("Copy the app state without screen images, for a bug report", "复制应用状态（不含屏幕图像），用于报告问题", "Copiar el estado de la app sin imágenes de pantalla, para informar de un error"),
    "Эффект работает только на встроенном экране MacBook. При закрытой крышке Mac засыпает как обычно.": ("The effect works only on the built-in MacBook display. With the lid closed, the Mac sleeps as usual.", "效果仅适用于 MacBook 内置屏幕。合上屏幕盖后，Mac 会照常睡眠。", "El efecto solo funciona en la pantalla integrada del MacBook. Con la tapa cerrada, el Mac duerme como siempre."),
    "Не используется": ("Not in use", "未使用", "Sin uso"),
    "Подключен": ("Connected", "已连接", "Conectado"),
    "Недоступен": ("Unavailable", "不可用", "No disponible"),

    // About
    "Версия %@ (%@)": ("Version %@ (%@)", "版本 %@ (%@)", "Versión %@ (%@)"),
    "Прикройте крышку MacBook — рабочий стол изгибается, размывается и темнеет.": ("Lower your MacBook's lid and the desktop bends, blurs and darkens.", "合上 MacBook 屏幕盖时，桌面会弯曲、模糊并变暗。", "Baje la tapa del MacBook y el escritorio se curva, se desenfoca y se oscurece."),

    "Распространяется по лицензии MIT. Не связано с Apple.": ("Distributed under the MIT License. Not affiliated with Apple.", "依据 MIT 许可证分发。与 Apple 无关。", "Distribuido con la licencia MIT. Sin relación con Apple."),
    "Лицензия": ("License", "许可证", "Licencia"),

    // Donations
    "Нравится DUO Butterfly?": ("Enjoying DUO Butterfly?", "喜欢 DUO Butterfly 吗？", "¿Le gusta DUO Butterfly?"),
    "Скажите спасибо разработчику, он очень старался.": ("Say thanks to the developer, who worked really hard on it.", "向开发者说声谢谢吧，这个应用倾注了很多心血。", "Dé las gracias al desarrollador, que se esforzó mucho."),
    "Сказать спасибо": ("Say Thanks", "表示感谢", "Dar las gracias"),
    "Скрыть до завтра": ("Hide until tomorrow", "隐藏至明天", "Ocultar hasta mañana"),
    "Спасибо, что пользуетесь DUO Butterfly": ("Thank you for using DUO Butterfly", "感谢使用 DUO Butterfly", "Gracias por usar DUO Butterfly"),
    "Если приложение вам нравится, поддержите разработчика любой суммой в криптовалюте.": ("If you enjoy the app, support the developer with any amount in cryptocurrency.", "如果您喜欢这个应用，可以用任意金额的加密货币支持开发者。", "Si le gusta la app, apoye al desarrollador con cualquier cantidad en criptomonedas."),
    "Скопировать": ("Copy", "复制", "Copiar"),
    "Скопировать адрес %@": ("Copy %@ address", "复制 %@ 地址", "Copiar la dirección de %@"),
    "Показать QR-код": ("Show QR Code", "显示二维码", "Mostrar código QR"),
    "QR-код адреса %@": ("QR code for the %@ address", "%@ 地址的二维码", "Código QR de la dirección de %@"),
    "Отсканируйте камерой кошелька на телефоне — перевод откроется с этим адресом.": ("Scan with your phone's wallet app to open a transfer to this address.", "用手机钱包扫描，即可打开向此地址的转账。", "Escanéelo con la app de su monedero en el móvil para abrir una transferencia a esta dirección."),
    "Отправляйте монеты только в указанной сети. Перевод в другой сети может быть потерян.": ("Send coins only on the network shown. Transfers on another network may be lost.", "请仅通过所示网络发送。通过其他网络转账可能会丢失。", "Envíe monedas solo por la red indicada. Las transferencias por otra red pueden perderse."),
    "Готово": ("Done", "完成", "Listo"),
    "Поддержать разработчика": ("Support the Developer", "支持开发者", "Apoyar al desarrollador"),
    "Сказать спасибо разработчику…": ("Say Thanks to the Developer…", "向开发者表示感谢…", "Dar las gracias al desarrollador…"),

    // Menus
    "О DUO Butterfly": ("About DUO Butterfly", "关于 DUO Butterfly", "Acerca de DUO Butterfly"),
    "Настройки…": ("Settings…", "设置…", "Ajustes…"),
    "Открыть DUO Butterfly…": ("Open DUO Butterfly…", "打开 DUO Butterfly…", "Abrir DUO Butterfly…"),
    "Показать на рабочем столе": ("Show on Desktop", "在桌面上展示", "Mostrar en el escritorio"),
    "DUO Butterfly — %@": ("DUO Butterfly — %@", "DUO Butterfly — %@", "DUO Butterfly — %@"),
    "Угол крышки: %ld°": ("Lid angle: %ld°", "屏幕盖角度：%ld°", "Ángulo de la tapa: %ld°"),
    "Выйти из DUO Butterfly": ("Quit DUO Butterfly", "退出 DUO Butterfly", "Salir de DUO Butterfly"),

    // Sensor and hardware
    "Датчик найден, но не передает корректный угол крышки. Нажмите «Проверить снова».": ("The sensor was found but doesn't report a valid lid angle. Click Check Again.", "已找到传感器，但未报告有效的屏幕盖角度。请点按“重新检查”。", "Se encontró el sensor, pero no informa un ángulo válido. Pulse Volver a comprobar."),
    "Не удалось подключить датчик крышки. Закройте другие приложения для чтения угла и нажмите «Проверить снова».": ("Couldn't connect to the lid sensor. Quit other apps that read the angle and click Check Again.", "无法连接屏幕盖传感器。请退出其他读取角度的应用，然后点按“重新检查”。", "No se pudo conectar el sensor de la tapa. Cierre otras apps que lean el ángulo y pulse Volver a comprobar."),
    "HID · фоновое чтение 30–120 Гц": ("HID · background reading 30–120 Hz", "HID · 后台读取 30–120 Hz", "HID · lectura en segundo plano 30–120 Hz"),
    "Не удалось прочитать угол крышки. Нажмите «Проверить снова».": ("Couldn't read the lid angle. Click Check Again.", "无法读取屏幕盖角度。请点按“重新检查”。", "No se pudo leer el ángulo de la tapa. Pulse Volver a comprobar."),
    "Неизвестная модель": ("Unknown model", "未知型号", "Modelo desconocido"),
    "%@ не имеет датчика угла крышки. Автоматический эффект на этой модели недоступен. Можно использовать ручной предпросмотр и кнопку «Показать».": ("%@ has no lid angle sensor, so the automatic effect isn't available. You can still use the manual preview and Show.", "%@ 没有屏幕盖角度传感器，无法使用自动效果。仍可使用手动预览和“展示”按钮。", "%@ no tiene sensor del ángulo de la tapa, así que el efecto automático no está disponible. Puede usar la vista previa manual y Mostrar."),
    "Обнаружены системные датчики Apple, но интерфейс угла крышки недоступен. Для проверки совместимости нужен отчет с этого Mac (%@).": ("Apple system sensors were found, but the lid angle interface is unavailable. A report from this Mac (%@) is needed to check compatibility.", "检测到 Apple 系统传感器，但屏幕盖角度接口不可用。需要这台 Mac（%@）的报告来检查兼容性。", "Se encontraron sensores del sistema de Apple, pero la interfaz del ángulo de la tapa no está disponible. Se necesita un informe de este Mac (%@) para comprobar la compatibilidad."),
    "Датчик угла крышки не найден (%@). Если в этой модели есть датчик, нажмите «Проверить снова» после пробуждения Mac.": ("Lid angle sensor not found (%@). If this model has one, click Check Again after the Mac wakes.", "未找到屏幕盖角度传感器（%@）。如果此型号有传感器，请在 Mac 唤醒后点按“重新检查”。", "No se encontró el sensor del ángulo de la tapa (%@). Si este modelo lo tiene, pulse Volver a comprobar cuando el Mac se reactive."),
    "Встроенный экран сейчас недоступен.": ("The built-in display is currently unavailable.", "内置屏幕当前不可用。", "La pantalla integrada no está disponible ahora."),
    "Не удалось исключить DUO Butterfly из захвата экрана.": ("Couldn't exclude DUO Butterfly from screen capture.", "无法将 DUO Butterfly 排除在屏幕捕获之外。", "No se pudo excluir DUO Butterfly de la captura de pantalla."),
    "macOS не передала изображение экрана. Проверьте разрешение и повторите.": ("macOS didn't provide a screen image. Check the permission and try again.", "macOS 未提供屏幕图像。请检查权限后重试。", "macOS no entregó la imagen de la pantalla. Revise el permiso e inténtelo de nuevo."),
    "Не удалось загрузить изображение для предпросмотра.": ("Couldn't load the preview image.", "无法载入预览图像。", "No se pudo cargar la imagen de la vista previa."),
    "Не найден шейдер DUO Butterfly.": ("The DUO Butterfly shader is missing.", "找不到 DUO Butterfly 着色器。", "Falta el sombreador de DUO Butterfly."),
    "Metal недоступен на этом Mac.": ("Metal isn't available on this Mac.", "这台 Mac 无法使用 Metal。", "Metal no está disponible en este Mac."),

    // Controller
    "Как восстановить доступ к экрану": ("How to restore screen access", "如何恢复屏幕访问权限", "Cómo restaurar el acceso a la pantalla"),
    "macOS могла сохранить разрешение для прежней сборки.\n\n1. В настройках записи экрана выберите DUO Butterfly и нажмите «−».\n2. Нажмите «+» и добавьте установленную DUO Butterfly заново.\n3. Включите доступ и перезапустите DUO Butterfly, если macOS попросит.": ("macOS may have kept the permission for a previous build.\n\n1. In Screen Recording settings, select DUO Butterfly and click “−”.\n2. Click “+” and add the installed DUO Butterfly again.\n3. Turn access on and restart DUO Butterfly if macOS asks.", "macOS 可能保留了旧版本的权限。\n\n1. 在屏幕录制设置中选择 DUO Butterfly，然后点按“−”。\n2. 点按“+”，重新添加已安装的 DUO Butterfly。\n3. 开启权限；如果 macOS 要求，请重新启动 DUO Butterfly。", "macOS pudo conservar el permiso de una versión anterior.\n\n1. En los ajustes de Grabación de pantalla, seleccione DUO Butterfly y pulse «−».\n2. Pulse «+» y vuelva a añadir DUO Butterfly instalado.\n3. Active el acceso y reinicie DUO Butterfly si macOS lo pide."),
    "Открыть настройки macOS": ("Open macOS Settings", "打开 macOS 设置", "Abrir ajustes de macOS"),
    "Закрыть": ("Close", "关闭", "Cerrar"),
    "Не удалось изменить автозапуск: %@": ("Couldn't change the login item: %@", "无法更改登录项：%@", "No se pudo cambiar el inicio de sesión: %@"),
    "Не удалось показать рабочий стол: %@": ("Couldn't show the desktop: %@", "无法显示桌面：%@", "No se pudo mostrar el escritorio: %@"),
    "Не удалось подключить сочетание клавиш.": ("Couldn't register the keyboard shortcut.", "无法注册键盘快捷键。", "No se pudo registrar el atajo de teclado."),
    "⌘⌥B занято другой программой. Используйте меню DUO Butterfly в строке меню.": ("⌘⌥B is taken by another app. Use the DUO Butterfly menu in the menu bar.", "⌘⌥B 已被其他应用占用。请使用菜单栏中的 DUO Butterfly 菜单。", "Otra app usa ⌘⌥B. Use el menú de DUO Butterfly en la barra de menús."),
]
