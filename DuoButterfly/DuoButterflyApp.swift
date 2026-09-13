import SwiftUI
import AppKit

@main struct DuoButterflyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var delegate
    private let controller = AppController.shared
    var body: some Scene {
        Window("DUO Butterfly", id: "main") {
            SettingsView(model: controller.model, controller: controller)
                .frame(width: 900, height: 680)
                .onExitCommand { controller.stopDemo() }
        }
        .defaultSize(width: 900, height: 680)
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .commands {
            CommandGroup(replacing: .appInfo) {
                OpenSectionCommand(title: tr("О DUO Butterfly"), section: .about)
            }
            CommandGroup(replacing: .newItem) {}
            CommandGroup(replacing: .appSettings) {
                OpenSectionCommand(title: tr("Настройки…"), section: .general)
                    .keyboardShortcut(",", modifiers: .command)
            }
            CommandMenu(tr("Эффект")) {
                Button(controller.model.toggleActionTitle) {
                    controller.toggleEnabled()
                }.keyboardShortcut("b", modifiers: [.command, .option])
                Button(tr("Показать на рабочем столе")) { controller.startDemo() }
                    .disabled(!controller.model.permissionGranted || controller.model.demoActive)
            }
        }
        MenuBarExtra("DUO Butterfly", systemImage: controller.model.menuBarSymbol) {
            MenuContent(model: controller.model, controller: controller)
        }
        .menuBarExtraStyle(.menu)
    }
}

@MainActor final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        AppController.shared.start()
        NSApp.activate(ignoringOtherApps: true)
    }
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { false }
}

extension AppModel {
    var needsAttention: Bool {
        preferences.enabled && !suspended && (!permissionGranted || error != nil || !sensorAvailable)
    }
    var menuBarSymbol: String {
        if !preferences.enabled { return "pause.circle" }
        return needsAttention ? "exclamationmark.triangle" : "macbook"
    }
}

/// Opens the single app window on a given section and brings the app forward.
private struct OpenSectionCommand: View {
    let title: String
    let section: SettingsSection
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        Button(title) {
            AppController.shared.model.section = section
            openWindow(id: "main"); NSApp.activate(ignoringOtherApps: true)
        }
    }
}

private struct MenuContent: View {
    @Bindable var model: AppModel
    let controller: AppController
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        Text(tr("DUO Butterfly — %@", model.status.lowercased()))
        if let angle = model.angle { Text(tr("Угол крышки: %ld°", Int(angle))) }
        Divider()
        if model.demoActive {
            Button(tr("Остановить демонстрацию")) { controller.stopDemo() }
                .keyboardShortcut("b", modifiers: [.command, .option])
        } else {
            Toggle(tr("Эффект включен"), isOn: $model.preferences.enabled)
                .keyboardShortcut("b", modifiers: [.command, .option])
            Button(tr("Показать на рабочем столе")) {
                open(.effect)
                controller.startDemo()
            }.disabled(!model.permissionGranted || model.suspended)
        }
        Divider()
        Button(tr("Открыть DUO Butterfly…")) { open(.effect) }
        Button(tr("Настройки…")) { open(.general) }
        Divider()
        if !Donations.available.isEmpty {
            Button(tr("Сказать спасибо разработчику…")) {
                open(model.section)
                model.showsDonations = true
            }
        }
        Button(tr("О DUO Butterfly")) { open(.about) }
        Button(tr("Выйти из DUO Butterfly")) { NSApplication.shared.terminate(nil) }.keyboardShortcut("q")
    }

    private func open(_ section: SettingsSection) {
        model.section = section
        openWindow(id: "main"); NSApp.activate(ignoringOtherApps: true)
    }
}
