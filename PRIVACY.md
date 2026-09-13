# Privacy

**English** · [简体中文](#简体中文) · [Español](#español) · [Русский](#русский)

DUO Butterfly works entirely on your Mac. It has no accounts, analytics, crash reporting,
or network requests.

## Screen access

The full-screen effect receives frames of the built-in display through ScreenCaptureKit.
Frames are processed in memory with Metal and are never written to files. The effect window is
excluded from capture; visible app windows stay in it. Audio and the microphone are not captured,
and the pointer is not included in frames. Capture stops when the effect is off, when the Mac
sleeps or locks, or shortly after the lid opens past the cutoff angle.

The preview in the app uses a bundled image and doesn't need screen access.

## Settings and diagnostics

Settings are stored in UserDefaults. Launch at login is managed by macOS through SMAppService.
The lid angle is read locally through HID.

The developer option `--diagnostics /absolute/path/status.json` writes a local file with the
version, lid angle, state flags, frame counters, and error messages. **Copy Report** in Settings
puts the same data on the clipboard. It contains no screen images or audio. Review error text
before sharing it.

## Donations

The **Say Thanks** sheet shows wallet addresses and QR codes generated on the Mac. Nothing is
sent anywhere, and the app never knows whether a payment was made.

---

## 简体中文

DUO Butterfly 完全在你的 Mac 上运行，没有账户、数据分析、崩溃报告，也不发送任何网络请求。

**屏幕访问：** 全屏效果通过 ScreenCaptureKit 获取内置屏幕的画面。画面仅在内存中通过 Metal
处理，不会写入文件。效果窗口不在捕获范围内，可见的应用窗口会保留在画面中。不捕获声音和麦克风，
画面中不包含鼠标指针。效果关闭、Mac 睡眠或锁定，或屏幕盖打开超过关闭角度后不久，捕获即会停止。
应用内预览使用内置图片，不需要屏幕访问权限。

**设置与诊断：** 设置保存在 UserDefaults 中。登录时打开由 macOS 通过 SMAppService 管理。
屏幕盖角度通过 HID 在本地读取。开发者参数 `--diagnostics /绝对路径/status.json` 会写入本地文件，
包含版本、屏幕盖角度、状态标记、帧计数和错误信息。设置中的 **“复制报告”** 会将相同数据复制到剪贴板，
其中不含屏幕图像或声音。分享前请检查错误信息。

**捐赠：** “表示感谢”窗口显示钱包地址和在 Mac 上生成的二维码。不会发送任何数据，应用也无从得知是否付款。

---

## Español

DUO Butterfly funciona por completo en su Mac. No tiene cuentas, analíticas, informes de fallos
ni solicitudes de red.

**Acceso a la pantalla:** el efecto a pantalla completa recibe fotogramas de la pantalla integrada
mediante ScreenCaptureKit. Se procesan en memoria con Metal y nunca se escriben en archivos.
La ventana del efecto queda excluida de la captura; las ventanas visibles de la app permanecen.
No se captura audio ni micrófono, y el puntero no aparece en los fotogramas. La captura se detiene
cuando el efecto está desactivado, cuando el Mac duerme o se bloquea, o poco después de abrir la
tapa por encima del ángulo de desactivación. La vista previa usa una imagen incluida y no necesita
acceso a la pantalla.

**Ajustes y diagnóstico:** los ajustes se guardan en UserDefaults. El inicio al iniciar sesión
lo gestiona macOS mediante SMAppService. El ángulo de la tapa se lee localmente por HID.
La opción de desarrollador `--diagnostics /ruta/absoluta/status.json` escribe un archivo local
con la versión, el ángulo, indicadores de estado, contadores de fotogramas y mensajes de error.
**Copiar informe** en Ajustes copia los mismos datos al portapapeles, sin imágenes ni audio.
Revise los mensajes de error antes de compartirlos.

**Donaciones:** la ventana **Dar las gracias** muestra direcciones de monederos y códigos QR
generados en el Mac. No se envía nada y la app nunca sabe si se hizo un pago.

---

## Русский

DUO Butterfly полностью работает на вашем Mac. В приложении нет аккаунтов, аналитики, отправки
отчётов о сбоях и сетевых запросов.

**Доступ к экрану.** Полноэкранный эффект получает кадры встроенного экрана через ScreenCaptureKit.
Кадры обрабатываются в памяти через Metal и не записываются в файлы. Окно эффекта исключено из
захвата, видимые окна приложения остаются. Звук и микрофон не захватываются, курсор в кадры не
попадает. Захват останавливается, когда эффект выключен, Mac спит или заблокирован, или вскоре
после того, как крышка открыта шире угла отключения. Предпросмотр в приложении использует
встроенную картинку и доступа к экрану не требует.

**Настройки и диагностика.** Настройки хранятся в UserDefaults. Автозапуском управляет macOS
через SMAppService. Угол крышки читается локально через HID. Параметр разработчика
`--diagnostics /абсолютный/путь/status.json` пишет локальный файл с версией, углом крышки, флагами
состояния, счётчиками кадров и текстами ошибок. Кнопка «Скопировать отчёт» в настройках кладёт те
же данные в буфер обмена. Изображений экрана и звука там нет. Перед публикацией проверьте тексты ошибок.

**Донаты.** Окно «Сказать спасибо» показывает адреса кошельков и QR-коды, созданные на Mac.
Никакие данные не отправляются, и приложение не знает, был ли платёж.
