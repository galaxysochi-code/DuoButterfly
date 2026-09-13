# MacBook compatibility

The lid-driven effect needs a sensor that reports the lid **angle**. An M-series chip alone
doesn't guarantee one. Current DUO Butterfly builds require Apple silicon and macOS 26 or later.

| Family | Lid-angle sensor | Status |
| --- | --- | --- |
| MacBook Pro 14″ and 16″ with Apple silicon, 2021 and later | Yes, for the generations listed below | Verified on M4 Pro; others need testing |
| MacBook Air M2, M3, and M4, 13″ and 15″ | Yes | Needs testing; some units expose interfaces that aren't reachable through standard HID |
| MacBook Air M1 (2020) | No; only open/closed state | Angle-based effect isn't possible |
| MacBook Pro 13″ with M1 or M2 | No | Angle-based effect isn't possible |
| MacBook Pro 16″ Intel (2019) | Yes | The arm64 build doesn't run on Intel |
| Other older Intel MacBooks | Not confirmed; most use a lid switch | Not supported by current builds |
| Newer models not in the table | Detected at launch | Not blocked by a model list; needs testing on the device |

The hardware list is based on [LidAngleSensor project data](https://github.com/samhenrigold/LidAngleSensor/issues/36)
and its [model checks](https://github.com/samhenrigold/LidAngleSensor/blob/main/LidAngleSensor/HardwareCompat.swift).
MacBook Pro models with Apple silicon listed there: M1 Pro/Max, M2 Pro/Max, M3/M3 Pro/M3 Max,
and M4/M4 Pro/M4 Max. Having the sensor doesn't mean DUO Butterfly has been verified on that
exact model and macOS version.

Some [MacBook Air M2](https://github.com/samhenrigold/LidAngleSensor/issues/45) units show
Apple SPU devices with the same Product ID but no angle interface. A matching Product ID alone
isn't enough to treat those readings as a lid angle. DUO Butterfly doesn't substitute ambient
light or accelerometer readings for a missing angle.

On a MacBook Air M1, reinstalling the app or granting screen recording won't add a sensor.
SMC exposes a [two-state MSLD lid switch](https://github.com/AsahiLinux/docs/blob/main/docs/hw/soc/smc.md)
without intermediate angles. The manual preview and the five-second demo still work.

## Reporting a MacBook

From the project root, run:

```bash
zsh scripts/diagnose-lid.sh
```

The script only reads the model, macOS version, and the Apple HID device list. It doesn't ask
for a password, change settings, or send data. Attach its output to a
[bug report](https://github.com/galaxysochi-code/DuoButterfly/issues/new/choose) together with
the DUO Butterfly version and **Settings → Diagnostics → Copy Report**.

The report shows whether the interface is available. Reading reliability and animation smoothness
are checked separately by moving the lid, and after sleep and wake.

---

**简体中文：** 效果需要能报告屏幕盖**角度**的传感器。MacBook Air M1 和 13 英寸 MacBook Pro M1/M2
没有该传感器；配备 Apple 芯片的 14/16 英寸 MacBook Pro 以及 MacBook Air M2/M3/M4 带有传感器。
可运行 `zsh scripts/diagnose-lid.sh` 生成报告并提交 issue。

**Español:** el efecto necesita un sensor que informe del **ángulo** de la tapa. El MacBook Air M1
y el MacBook Pro de 13″ M1/M2 no lo tienen; los MacBook Pro de 14/16″ con chip de Apple y los
MacBook Air M2/M3/M4 sí. Ejecute `zsh scripts/diagnose-lid.sh` y adjunte el resultado a un issue.

**Русский:** для эффекта нужен датчик, который передаёт **угол** крышки. У MacBook Air M1 и
MacBook Pro 13″ с M1/M2 его нет; у MacBook Pro 14/16″ с Apple silicon и MacBook Air M2/M3/M4 он есть.
Запустите `zsh scripts/diagnose-lid.sh` и приложите вывод к issue.
