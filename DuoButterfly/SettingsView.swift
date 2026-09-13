import SwiftUI
import AppKit

// MARK: - Window

struct SettingsView: View {
    @Bindable var model: AppModel
    let controller: AppController
    @Bindable private var localizer = Localizer.shared

    var body: some View {
        VStack(spacing: 0) {
            WindowHeader(model: model)
            Divider()
            if model.showsThanksBanner {
                ThanksBanner(model: model)
                Divider()
            }
            Group {
                switch model.section {
                case .effect: EffectPage(model: model, controller: controller)
                case .general: GeneralPage(model: model, controller: controller)
                case .about: AboutPage(model: model)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .sheet(isPresented: $model.showsDonations) { DonationSheet() }
        // Re-render every string when the interface language changes.
        .id(localizer.language)
    }
}

private struct WindowHeader: View {
    @Bindable var model: AppModel

    var body: some View {
        HStack(spacing: 10) {
            Toggle(tr("Эффект включен"), isOn: $model.preferences.enabled)
                .toggleStyle(PowerToggleStyle())
                .help(model.preferences.enabled ? tr("Приостановить эффект — ⌘⌥B") : tr("Включить эффект — ⌘⌥B"))
                .padding(.trailing, 6)
            AppIconView(size: 26)
            VStack(alignment: .leading, spacing: 1) {
                Text(verbatim: "DUO Butterfly").font(.system(size: 13, weight: .bold)).tracking(0.3)
                StatusLine(model: model)
            }
            .layoutPriority(1)
            Spacer(minLength: 16)
            Picker(tr("Раздел"), selection: $model.section) {
                ForEach(SettingsSection.allCases) { Text($0.title).tag($0) }
            }
            .pickerStyle(.segmented).labelsHidden().fixedSize()
        }
        .padding(.horizontal, 20)
        .frame(height: 56)
    }
}

/// Large ON/OFF pill for the main effect switch.
private struct PowerToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View { PowerSwitch(configuration: configuration) }
}

private struct PowerSwitch: View {
    let configuration: ToggleStyleConfiguration
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled

    var body: some View {
        let on = configuration.isOn
        Button {
            withAnimation(reduceMotion ? nil : .spring(response: 0.3, dampingFraction: 0.78)) { configuration.isOn.toggle() }
        } label: {
            ZStack(alignment: on ? .trailing : .leading) {
                Capsule().fill(on ? AnyShapeStyle(LinearGradient(
                    colors: [Color(red: 0.38, green: 0.86, blue: 0.51), Color(red: 0.13, green: 0.66, blue: 0.35)],
                    startPoint: .top, endPoint: .bottom)) : AnyShapeStyle(Color.primary.opacity(0.12)))
                Text(on ? tr("ВКЛ") : tr("ВЫКЛ"))
                    .font(.system(size: 10.5, weight: .heavy, design: .rounded)).tracking(0.8)
                    .foregroundStyle(on ? AnyShapeStyle(Color.white) : AnyShapeStyle(.secondary))
                    .frame(maxWidth: .infinity)
                    .padding(on ? .trailing : .leading, 24)
                Circle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.28), radius: 1.5, y: 1)
                    .frame(width: 22, height: 22)
                    .padding(2)
            }
            .frame(width: 78, height: 26)
            .overlay(Capsule().strokeBorder(.primary.opacity(on ? 0.0 : 0.1)))
            .opacity(isEnabled ? 1 : 0.5)
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) { configuration.label }
        }
    }
}

private struct StatusLine: View {
    let model: AppModel
    var body: some View {
        HStack(spacing: 5) {
            Circle().fill(tint).frame(width: 6, height: 6).accessibilityHidden(true)
            Text(model.status).font(.system(size: 11)).foregroundStyle(.secondary).lineLimit(1)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(tr("Состояние: %@", model.status))
    }
    private var tint: Color {
        if !model.preferences.enabled || model.suspended { return .secondary }
        if model.needsAttention { return .orange }
        return .green
    }
}

private struct AppIconView: View {
    let size: CGFloat
    var body: some View {
        Image(nsImage: NSApp.applicationIconImage ?? NSImage())
            .resizable().frame(width: size, height: size).accessibilityHidden(true)
    }
}

// MARK: - Effect

private struct EffectPage: View {
    @Bindable var model: AppModel
    let controller: AppController

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                AttentionBanner(model: model, controller: controller)
                previewCard
                demoCard
            }
            .frame(maxWidth: 720)
            .padding(20)
            .frame(maxWidth: .infinity)
        }
    }

    private var displayedAngle: Int { Int(model.previewAngle) }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            CardTitle(tr("Предпросмотр"), systemImage: "eye")
            PreviewScreen(model: model, cornerRadius: 14)
            HStack(spacing: 10) {
                Image(systemName: "macbook").foregroundStyle(.secondary).accessibilityHidden(true)
                Slider(value: $model.previewAngle, in: 15...135, step: 1)
                    .accessibilityLabel(tr("Угол крышки в примере"))
                    .accessibilityValue(tr("%ld градусов", displayedAngle))
                Text(verbatim: "\(displayedAngle)°")
                    .font(.system(size: 13, weight: .medium)).monospacedDigit()
                    .frame(width: 42, alignment: .trailing)
            }
            Text(previewHint)
                .font(.system(size: 12)).foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            Divider()
            HStack(spacing: 8) {
                Image(systemName: "slider.horizontal.3").foregroundStyle(.secondary).accessibilityHidden(true)
                Text(tr("Стиль и настройка эффекта находятся в разделе «Настройки»."))
                    .font(.system(size: 12)).foregroundStyle(.secondary)
                Spacer(minLength: 8)
                Button(tr("Открыть")) { model.section = .general }.buttonStyle(.link).font(.system(size: 12))
            }
        }
        .card()
    }

    private var previewHint: String {
        if model.previewAngle >= model.preferences.clearAngle {
            return tr("При %ld° и шире эффекта нет. Сдвиньте ползунок влево.", Int(model.preferences.clearAngle))
        }
        return tr("Ползунок изображает угол крышки: чем меньше угол, тем сильнее эффект.")
    }

    private var demoCard: some View {
        HStack(spacing: 14) {
            Image(systemName: model.demoActive ? "sparkles" : "play.rectangle")
                .font(.system(size: 20)).foregroundStyle(.tint).frame(width: 28).accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(model.permissionGranted ? tr("Проверить на рабочем столе") : tr("Эффект на вашем экране"))
                    .font(.system(size: 13, weight: .semibold))
                Text(demoDetail).font(.system(size: 12)).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 8)
            if model.permissionGranted {
                Button {
                    if model.demoActive { controller.stopDemo() } else { controller.startDemo() }
                } label: {
                    Label(model.demoActive ? tr("Остановить") : tr("Показать"),
                          systemImage: model.demoActive ? "stop.fill" : "play.fill")
                        .padding(.horizontal, 4)
                }
                .buttonStyle(.glassProminent).controlSize(.large)
                .disabled(model.suspended)
            } else {
                Button(tr("Разрешить доступ…")) { controller.requestScreenPermission() }
                    .buttonStyle(.glassProminent).controlSize(.large)
            }
        }
        .card()
    }

    private var demoDetail: String {
        if !model.permissionGranted { return tr("Нужен доступ к записи экрана. Кадры не покидают этот Mac.") }
        if model.demoActive { return tr("Идет демонстрация. Esc или ⌘⌥B — остановить.") }
        return tr("Пятисекундная демонстрация на экране MacBook.")
    }
}

/// Live Metal preview in a black bezel.
private struct PreviewScreen: View {
    let model: AppModel
    let cornerRadius: CGFloat
    var body: some View {
        FoldPreview(model: model)
            .aspectRatio(1.6, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius - 5))
            .padding(5)
            .background(RoundedRectangle(cornerRadius: cornerRadius).fill(Color.black))
            .overlay(RoundedRectangle(cornerRadius: cornerRadius).strokeBorder(.primary.opacity(0.1)))
            .accessibilityLabel(tr("Пример рабочего стола с эффектом DUO Butterfly"))
    }
}

/// One prominent message with a single next step when the effect cannot work as expected.
private struct AttentionBanner: View {
    let model: AppModel
    let controller: AppController

    var body: some View {
        if let notice {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: notice.symbol)
                    .font(.system(size: 20)).foregroundStyle(notice.tint).frame(width: 28).accessibilityHidden(true)
                VStack(alignment: .leading, spacing: 2) {
                    Text(notice.title).font(.system(size: 13, weight: .semibold))
                    Text(notice.detail).font(.system(size: 12)).foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer(minLength: 8)
                if let secondary = notice.secondary {
                    Button(secondary.title, action: secondary.action).buttonStyle(.link).font(.system(size: 12))
                }
                Button(notice.primary.title, action: notice.primary.action).buttonStyle(.glass)
            }
            .padding(14)
            .background(notice.tint.opacity(0.1), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(notice.tint.opacity(0.25)))
            .accessibilityElement(children: .contain)
        }
    }

    private struct Action { let title: String; let action: () -> Void }
    private struct Notice {
        let symbol: String, tint: Color, title: String, detail: String
        let primary: Action
        var secondary: Action?
    }

    private var notice: Notice? {
        if !model.preferences.enabled {
            return Notice(symbol: "pause.circle.fill", tint: .secondary, title: tr("Эффект на паузе"),
                detail: tr("Рабочий стол не реагирует на крышку. Включить можно и сочетанием ⌘⌥B."),
                primary: Action(title: tr("Включить")) { controller.toggleEnabled() })
        }
        if model.suspended { return nil }
        if !model.permissionGranted {
            return Notice(symbol: "lock.rectangle", tint: .orange, title: tr("Нужен доступ к записи экрана"),
                detail: tr("Без него эффект не сможет изменить рабочий стол. Изображение обрабатывается только на этом Mac."),
                primary: Action(title: tr("Разрешить доступ…")) { controller.requestScreenPermission() },
                secondary: Action(title: tr("Уже разрешено?")) { controller.showPermissionRecovery() })
        }
        if let error = model.error {
            return Notice(symbol: "exclamationmark.triangle.fill", tint: .orange, title: tr("Эффект не запустился"),
                detail: error, primary: Action(title: tr("Проверить снова")) { controller.retry() })
        }
        if !model.sensorAvailable {
            return Notice(symbol: "sensor", tint: .orange, title: tr("Датчик угла крышки недоступен"),
                detail: tr("%@ Эффект можно проверить кнопкой «Показать».", model.sensorDetail),
                primary: Action(title: tr("Проверить снова")) { controller.retry() })
        }
        return nil
    }
}

// MARK: - Settings

private struct GeneralPage: View {
    @Bindable var model: AppModel
    let controller: AppController
    @Bindable private var localizer = Localizer.shared
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var copied = false

    var body: some View {
        Form {
            styleSection
            parametersSection
            generalSection
            accessSection
            diagnosticsSection
        }
        .formStyle(.grouped)
    }

    // Style

    private var styleSection: some View {
        Section {
            HStack(alignment: .top, spacing: 18) {
                PreviewScreen(model: model, cornerRadius: 10)
                    .frame(width: 220)
                VStack(alignment: .leading, spacing: 10) {
                    HStack(spacing: 8) {
                        ForEach(FoldStyle.allCases) { style in
                            StyleTile(style: style, selected: model.preferences.style == style) {
                                withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) { model.select(style) }
                            }
                        }
                    }
                    HStack(spacing: 6) {
                        Text(model.preferences.style.subtitle)
                        if model.preferences.hasCustomStyle {
                            Text(verbatim: "·")
                            Text(tr("изменен"))
                            Spacer(minLength: 4)
                            Button(tr("Вернуть")) { model.select(model.preferences.style) }
                                .buttonStyle(.link).foregroundStyle(.tint)
                                .help(tr("Вернуть изгиб, размытие и затемнение стиля «%@»", model.preferences.style.title))
                        }
                    }
                    .font(.system(size: 12)).foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 4)
        } header: { Text(tr("Стиль")) }
    }

    // Parameters

    private var parametersSection: some View {
        Section {
            PercentSlider(title: tr("Изгиб"), value: $model.preferences.perspective)
            PercentSlider(title: tr("Размытие"), value: $model.preferences.blur)
            PercentSlider(title: tr("Затемнение"), value: $model.preferences.shadow)
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(tr("Угол отключения"))
                    Spacer()
                    Text(verbatim: "\(Int(model.preferences.clearAngle))°").monospacedDigit().foregroundStyle(.secondary)
                }
                Slider(value: $model.preferences.clearAngle, in: 60...135, step: 1)
                    .accessibilityLabel(tr("Угол отключения эффекта"))
                    .accessibilityValue(tr("%ld градусов", Int(model.preferences.clearAngle)))
                Text(tr("Крышка открыта на %ld° или шире — эффекта нет.", Int(model.preferences.clearAngle)))
                    .font(.system(size: 12)).foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            HStack {
                Spacer()
                Button(tr("Сбросить настройки эффекта")) { model.resetEffect() }
                    .help(tr("Вернуть стандартный стиль, изгиб, размытие, затемнение и угол отключения. Звук и автозапуск сохранятся."))
            }
        } header: { Text(tr("Настройка эффекта")) }
    }

    // General

    private var generalSection: some View {
        Section {
            Picker(tr("Язык интерфейса"), selection: $localizer.language) {
                ForEach(AppLanguage.allCases) { Text($0.nativeName).tag($0) }
            }
            Toggle(tr("Эффект включен"), isOn: $model.preferences.enabled)
            LabeledContent(tr("Включить или приостановить")) { KeyCaps(keys: ["⌘", "⌥", "B"]) }
            if let error = model.hotKeyError {
                Label(error, systemImage: "exclamationmark.triangle").foregroundStyle(.orange)
            }
            Toggle(tr("Запускать при входе в систему"), isOn: Binding(
                get: { model.launchAtLogin }, set: { controller.setLaunchAtLogin($0) }))
            LabeledContent {
                HStack(spacing: 10) {
                    Button { controller.previewSound() } label: { Image(systemName: "speaker.wave.2") }
                        .buttonStyle(.borderless).help(tr("Прослушать")).accessibilityLabel(tr("Прослушать звук"))
                    Toggle(tr("Звук при открытии крышки"), isOn: $model.preferences.sound)
                        .labelsHidden().toggleStyle(.switch)
                }
            } label: {
                Text(tr("Звук при открытии крышки"))
                Text(tr("Короткий щелчок, когда эффект полностью исчезает."))
            }
        } header: { Text(tr("Основные")) } footer: {
            Text(tr("Меню macOS и системные окна сменят язык после перезапуска приложения."))
                .foregroundStyle(.secondary)
        }
    }

    // Access

    private var accessSection: some View {
        Section {
            LabeledContent(tr("Запись экрана")) {
                Label(model.permissionGranted ? tr("Разрешена") : tr("Не разрешена"),
                      systemImage: model.permissionGranted ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                    .foregroundStyle(model.permissionGranted ? .green : .orange)
            }
            if !model.permissionGranted {
                HStack {
                    Button(tr("Разрешить доступ…")) { controller.requestScreenPermission() }.buttonStyle(.glassProminent)
                    Button(tr("Доступ включен, но не работает?")) { controller.showPermissionRecovery() }.buttonStyle(.link)
                }
            }
            VStack(alignment: .leading, spacing: 6) {
                Text(tr("Кадры обрабатываются в памяти этого Mac. DUO Butterfly не сохраняет снимки, не записывает звук и не отправляет содержимое экрана в интернет. Когда эффект не нужен, захват останавливается."))
                    .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                Button(tr("Открыть настройки конфиденциальности")) { controller.openPrivacySettings() }.buttonStyle(.link)
            }
        } header: { Text(tr("Доступ и конфиденциальность")) }
    }

    // Diagnostics

    private var diagnosticsSection: some View {
        Section {
            LabeledContent(tr("Модель Mac"), value: controller.sensor.modelIdentifier)
            LabeledContent(tr("Угол крышки")) {
                Text(model.angle.map { "\(Int($0))°" } ?? tr("Нет данных")).monospacedDigit()
            }
            LabeledContent(tr("Датчик"), value: sensorState)
            LabeledContent(tr("Состояние"), value: model.status)
            if model.preferences.enabled && !model.sensorAvailable && !model.suspended {
                Text(model.sensorDetail).foregroundStyle(.secondary)
            }
            if let error = model.error { Text(error).foregroundStyle(.orange) }
            HStack {
                Button(tr("Проверить снова")) { controller.retry() }
                Button(copied ? tr("Скопировано") : tr("Скопировать отчет")) {
                    NSPasteboard.general.clearContents()
                    NSPasteboard.general.setString(controller.diagnosticsReport(), forType: .string)
                    copied = true
                    Task { try? await Task.sleep(for: .seconds(2)); copied = false }
                }
                .help(tr("Скопировать состояние приложения без изображений экрана — для сообщения об ошибке"))
            }
        } header: { Text(tr("Диагностика")) } footer: {
            Text(tr("Эффект работает только на встроенном экране MacBook. При закрытой крышке Mac засыпает как обычно."))
                .foregroundStyle(.secondary)
        }
    }

    private var sensorState: String {
        if !model.preferences.enabled || model.suspended { return tr("Не используется") }
        return model.sensorAvailable ? tr("Подключен") : tr("Недоступен")
    }
}

private struct StyleTile: View {
    let style: FoldStyle
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack(alignment: .topTrailing) {
                    if let image = StyleArtwork.image(for: style) {
                        Image(nsImage: image).resizable().aspectRatio(1.6, contentMode: .fit)
                    } else {
                        Rectangle().fill(.secondary.opacity(0.15)).aspectRatio(1.6, contentMode: .fit)
                    }
                    if selected {
                        Image(systemName: "checkmark.circle.fill")
                            .symbolRenderingMode(.palette).foregroundStyle(.white, Color.accentColor)
                            .font(.system(size: 13)).padding(3)
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .padding(3)
                .overlay(RoundedRectangle(cornerRadius: 9)
                    .strokeBorder(selected ? Color.accentColor : .primary.opacity(0.12), lineWidth: selected ? 2 : 1))
                Text(style.title)
                    .font(.system(size: 12, weight: selected ? .semibold : .regular))
                    .foregroundStyle(selected ? .primary : .secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(style.title), \(style.subtitle.lowercased())")
        .accessibilityAddTraits(selected ? .isSelected : [])
        .help(style.subtitle)
    }
}

private struct PercentSlider: View {
    let title: String
    @Binding var value: Double

    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(title)
                Spacer()
                Text(verbatim: "\(Int((value * 100).rounded()))%").foregroundStyle(.secondary).monospacedDigit()
            }
            Slider(value: $value, in: 0...1)
                .accessibilityLabel(title)
                .accessibilityValue(tr("%ld процентов", Int((value * 100).rounded())))
        }
    }
}

private struct KeyCaps: View {
    let keys: [String]
    var body: some View {
        HStack(spacing: 3) {
            ForEach(keys, id: \.self) { key in
                Text(verbatim: key).font(.system(size: 12, weight: .medium, design: .rounded))
                    .frame(minWidth: 20, minHeight: 20)
                    .background(.quaternary, in: RoundedRectangle(cornerRadius: 5))
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(verbatim: "Command, Option, B"))
    }
}

// MARK: - About

private struct AboutPage: View {
    @Bindable var model: AppModel
    private var version: String {
        let short = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "—"
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "—"
        return tr("Версия %@ (%@)", short, build)
    }

    var body: some View {
        Form {
            Section {
                HStack(spacing: 16) {
                    AppIconView(size: 72)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(verbatim: "DUO Butterfly").font(.system(size: 22, weight: .bold)).tracking(0.4)
                        Text(version).foregroundStyle(.secondary).textSelection(.enabled)
                        Text(tr("Прикройте крышку MacBook — рабочий стол изгибается, размывается и темнеет."))
                            .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                    }
                }
                .padding(.vertical, 6)
            }

            if !Donations.available.isEmpty {
                Section {
                    HStack {
                        Text(tr("Если приложение вам нравится, поддержите разработчика любой суммой в криптовалюте."))
                            .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
                        Spacer(minLength: 12)
                        Button {
                            model.showsDonations = true
                        } label: {
                            Label(tr("Сказать спасибо"), systemImage: "heart")
                        }
                        .buttonStyle(.glassProminent).tint(.pink)
                    }
                } header: { Text(tr("Поддержать разработчика")) }
            }

            Section {
                Text(tr("Распространяется по лицензии MIT. Не связано с Apple."))
                    .foregroundStyle(.secondary).fixedSize(horizontal: false, vertical: true)
            } header: { Text(tr("Лицензия")) }
        }
        .formStyle(.grouped)
    }
}

// MARK: - Shared

private struct CardTitle: View {
    let title: String
    let systemImage: String
    init(_ title: String, systemImage: String) { self.title = title; self.systemImage = systemImage }
    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.system(size: 13, weight: .semibold))
            .labelStyle(.titleAndIcon)
            .accessibilityAddTraits(.isHeader)
    }
}

private extension View {
    func card() -> some View {
        padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: 14))
            .overlay(RoundedRectangle(cornerRadius: 14).strokeBorder(.primary.opacity(0.06)))
    }
}
