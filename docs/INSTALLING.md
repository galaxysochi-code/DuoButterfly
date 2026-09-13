# Installing DUO Butterfly

**English** · [简体中文](#简体中文) · [Español](#español) · [Русский](#русский)

## Install

1. Download `DuoButterfly-…-macos-arm64-adhoc.zip` from the
   [latest release](https://github.com/galaxysochi-code/DuoButterfly/releases/latest).
2. Optionally verify it: `shasum -a 256 DuoButterfly-*.zip` should match the `.sha256` file.
3. Unzip it and move **DUO Butterfly** to Applications.
4. Open the app. macOS says it can't verify the developer because the build isn't notarized.
5. Open **System Settings → Privacy & Security**, scroll down, and click **Open Anyway**
   next to DUO Butterfly. Confirm.
6. In the app, click **Allow Access…** and turn on DUO Butterfly under
   **Screen & System Audio Recording**. Restart the app if macOS asks.

If there's no **Open Anyway** button, remove the quarantine flag and open the app again:

```bash
xattr -dr com.apple.quarantine "/Applications/DUO Butterfly.app"
```

## Update

Quit the app (menu bar menu → **Quit DUO Butterfly**) and replace `DUO Butterfly.app` in
Applications with the new version. Settings are kept; you may need to allow screen recording again.

## Troubleshooting

| Problem | What to do |
|---|---|
| "Screen recording access needed" although it's on | In Screen Recording settings select DUO Butterfly, click "−", then "+" and add the app again. Restart it. |
| "Lid angle sensor unavailable" | Check your model in the [compatibility table](COMPATIBILITY.md). Click **Check Again** after the Mac wakes. |
| ⌘⌥B does nothing | Another app uses the shortcut. Use the ON/OFF switch or the menu bar menu. |
| No effect on an external display | By design: the effect works only on the built-in MacBook display. |

Still stuck? [Open an issue](https://github.com/galaxysochi-code/DuoButterfly/issues/new/choose)
and attach **Settings → Diagnostics → Copy Report**.

## Uninstall

1. Turn off **Open at login** in the app's settings.
2. Quit the app and delete `DUO Butterfly.app` from Applications.
3. Optionally remove settings: `defaults delete local.duobutterfly.DuoButterfly`.
4. Remove DUO Butterfly from the Screen Recording list in System Settings.

---

## 简体中文

### 安装

1. 从[最新版本](https://github.com/galaxysochi-code/DuoButterfly/releases/latest)下载
   `DuoButterfly-…-macos-arm64-adhoc.zip`。
2. 可选：运行 `shasum -a 256 DuoButterfly-*.zip`，结果应与 `.sha256` 文件一致。
3. 解压后将 **DUO Butterfly** 拖到“应用程序”文件夹。
4. 打开应用。由于未经公证，macOS 会提示无法验证开发者。
5. 打开 **系统设置 → 隐私与安全性**，向下滚动，点按 DUO Butterfly 旁边的 **“仍要打开”** 并确认。
6. 在应用中点按 **“允许访问…”**，在 **“录屏与系统录音”** 中开启 DUO Butterfly。如果 macOS 要求，请重新启动应用。

如果没有“仍要打开”按钮，请移除隔离标记后再次打开：

```bash
xattr -dr com.apple.quarantine "/Applications/DUO Butterfly.app"
```

### 更新

退出应用（菜单栏菜单 → **退出 DUO Butterfly**），用新版本替换“应用程序”中的 `DUO Butterfly.app`。
设置会保留，可能需要重新允许屏幕录制。

### 常见问题

| 问题 | 解决方法 |
|---|---|
| 已开启权限但仍提示“需要屏幕录制权限” | 在屏幕录制设置中选中 DUO Butterfly，点按“−”，再点按“+”重新添加，然后重启应用。 |
| “屏幕盖角度传感器不可用” | 在[兼容性表格](COMPATIBILITY.md)中查看你的机型。Mac 唤醒后点按 **“重新检查”**。 |
| ⌘⌥B 没有反应 | 该快捷键被其他应用占用。请使用开/关开关或菜单栏菜单。 |
| 外接显示器上没有效果 | 这是设计如此：效果仅适用于 MacBook 内置屏幕。 |

仍有问题？请[提交 issue](https://github.com/galaxysochi-code/DuoButterfly/issues/new/choose)，
并附上 **设置 → 诊断 → 复制报告** 的内容。

### 卸载

1. 在应用设置中关闭 **“登录时打开”**。
2. 退出应用，并从“应用程序”中删除 `DUO Butterfly.app`。
3. 可选：删除设置 `defaults delete local.duobutterfly.DuoButterfly`。
4. 在系统设置的屏幕录制列表中移除 DUO Butterfly。

---

## Español

### Instalación

1. Descargue `DuoButterfly-…-macos-arm64-adhoc.zip` desde la
   [última versión](https://github.com/galaxysochi-code/DuoButterfly/releases/latest).
2. Opcional: `shasum -a 256 DuoButterfly-*.zip` debe coincidir con el archivo `.sha256`.
3. Descomprímalo y mueva **DUO Butterfly** a Aplicaciones.
4. Abra la app. macOS indicará que no puede verificar al desarrollador porque no está notarizada.
5. Abra **Ajustes del Sistema → Privacidad y seguridad**, desplácese hacia abajo y pulse
   **Abrir igualmente** junto a DUO Butterfly. Confirme.
6. En la app, pulse **Permitir acceso…** y active DUO Butterfly en
   **Grabación de pantalla y audio del sistema**. Reinicie la app si macOS lo pide.

Si no aparece **Abrir igualmente**, quite la cuarentena y vuelva a abrir la app:

```bash
xattr -dr com.apple.quarantine "/Applications/DUO Butterfly.app"
```

### Actualización

Salga de la app (menú de la barra de menús → **Salir de DUO Butterfly**) y sustituya
`DUO Butterfly.app` en Aplicaciones por la nueva versión. Los ajustes se conservan; puede que
tenga que volver a permitir la grabación de pantalla.

### Solución de problemas

| Problema | Qué hacer |
|---|---|
| «Se necesita acceso a la grabación de pantalla» aunque está activado | En Grabación de pantalla, seleccione DUO Butterfly, pulse «−», luego «+» y añada la app de nuevo. Reiníciela. |
| «Sensor del ángulo de la tapa no disponible» | Compruebe su modelo en la [tabla de compatibilidad](COMPATIBILITY.md). Pulse **Volver a comprobar** cuando el Mac se reactive. |
| ⌘⌥B no hace nada | Otra app usa el atajo. Use el interruptor SÍ/NO o el menú de la barra de menús. |
| Sin efecto en una pantalla externa | Es intencionado: el efecto solo funciona en la pantalla integrada del MacBook. |

¿Sigue sin funcionar? [Abra un issue](https://github.com/galaxysochi-code/DuoButterfly/issues/new/choose)
y adjunte **Ajustes → Diagnóstico → Copiar informe**.

### Desinstalación

1. Desactive **Abrir al iniciar sesión** en los ajustes de la app.
2. Salga de la app y elimine `DUO Butterfly.app` de Aplicaciones.
3. Opcional: borre los ajustes con `defaults delete local.duobutterfly.DuoButterfly`.
4. Quite DUO Butterfly de la lista de Grabación de pantalla en Ajustes del Sistema.

---

## Русский

### Установка

1. Скачайте `DuoButterfly-…-macos-arm64-adhoc.zip` из
   [последнего выпуска](https://github.com/galaxysochi-code/DuoButterfly/releases/latest).
2. По желанию проверьте архив: `shasum -a 256 DuoButterfly-*.zip` должен совпасть с файлом `.sha256`.
3. Распакуйте архив и перенесите **DUO Butterfly** в «Программы».
4. Запустите приложение. macOS сообщит, что не может проверить разработчика: сборка не нотарифицирована.
5. Откройте **Системные настройки → Конфиденциальность и безопасность**, прокрутите вниз и нажмите
   **«Всё равно открыть»** рядом с DUO Butterfly. Подтвердите запуск.
6. В приложении нажмите **«Разрешить доступ…»** и включите DUO Butterfly в разделе
   **«Запись экрана и системного звука»**. Если macOS предложит, перезапустите приложение.

Если кнопки «Всё равно открыть» нет, снимите карантин и запустите снова:

```bash
xattr -dr com.apple.quarantine "/Applications/DUO Butterfly.app"
```

### Обновление

Закройте приложение (меню в строке меню → «Выйти из DUO Butterfly») и замените `DUO Butterfly.app`
в «Программах» новой версией. Настройки сохранятся, доступ к записи экрана, возможно, придётся выдать заново.

### Если что-то не работает

| Проблема | Что сделать |
|---|---|
| «Нужен доступ к записи экрана», хотя доступ включён | В настройках записи экрана выберите DUO Butterfly, нажмите «−», затем «+» и добавьте приложение заново. Перезапустите его. |
| «Датчик угла крышки недоступен» | Проверьте модель по [таблице совместимости](COMPATIBILITY.md). Нажмите «Проверить снова» после пробуждения Mac. |
| ⌘⌥B не работает | Сочетание занято другой программой. Пользуйтесь переключателем ВКЛ/ВЫКЛ или меню в строке меню. |
| Нет эффекта на внешнем мониторе | Так и задумано: эффект работает только на встроенном экране MacBook. |

Не помогло? [Создайте issue](https://github.com/galaxysochi-code/DuoButterfly/issues/new/choose)
и приложите отчёт: «Настройки» → «Диагностика» → «Скопировать отчёт».

### Удаление

1. Выключите «Запускать при входе в систему» в настройках приложения.
2. Закройте приложение и удалите `DUO Butterfly.app` из «Программ».
3. По желанию удалите настройки: `defaults delete local.duobutterfly.DuoButterfly`.
4. Уберите DUO Butterfly из списка записи экрана в системных настройках.
