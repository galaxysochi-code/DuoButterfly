import XCTest
import SwiftUI
@testable import DuoButterfly

/// Opens real windows for README screenshots. Run through scripts/readme-screenshots.sh,
/// which captures each window with `screencapture`; skipped in normal test runs.
final class ReadmeScreenshotTests: XCTestCase {
    private enum Content { case section(SettingsSection), donations }

    @MainActor func testOpenWindowsForScreenshots() async throws {
        guard let directory = ProcessInfo.processInfo.environment["DUOBUTTERFLY_SCREENSHOTS"] else {
            throw XCTSkip("Run scripts/readme-screenshots.sh to capture README screenshots")
        }
        defer { Localizer.testLanguage = .ru }
        let readmeShots: [(String, AppLanguage, NSAppearance.Name, Content)] = [
            ("main-ru", .ru, .darkAqua, .section(.effect)),
            ("settings-ru", .ru, .aqua, .section(.general)),
            ("main-en", .en, .darkAqua, .section(.effect)),
            ("settings-en", .en, .aqua, .section(.general)),
            ("main-zh", .zh, .darkAqua, .section(.effect)),
            ("main-es", .es, .darkAqua, .section(.effect)),
        ]
        // Broader set for interface reviews: every section in both appearances, plus the longest (Spanish) strings.
        var reviewShots: [(String, AppLanguage, NSAppearance.Name, Content)] = []
        for (language, suffix) in [(AppLanguage.ru, "ru"), (.es, "es")] {
            for (appearance, theme) in [(NSAppearance.Name.aqua, "light"), (.darkAqua, "dark")] {
                for section in SettingsSection.allCases {
                    reviewShots.append(("review-\(section.rawValue)-\(suffix)-\(theme)", language, appearance, .section(section)))
                }
            }
        }
        reviewShots.append(("review-donations-ru-dark", .ru, .darkAqua, .donations))
        let shots = ProcessInfo.processInfo.environment["DUOBUTTERFLY_SCREENSHOT_SET"] == "review" ? reviewShots : readmeShots
        for (name, language, appearance, content) in shots {
            Localizer.testLanguage = language
            let domain = "DuoButterflyScreenshots.\(UUID().uuidString)"
            let defaults = try XCTUnwrap(UserDefaults(suiteName: domain))
            defer { defaults.removePersistentDomain(forName: domain) }
            let model = AppModel(defaults: defaults)
            model.permissionGranted = true
            model.sensorAvailable = true
            model.angle = 128
            model.previewAngle = 58
            let root: AnyView
            let size: NSSize
            switch content {
            case .section(let section):
                model.section = section
                root = AnyView(SettingsView(model: model, controller: AppController.shared).frame(width: 900, height: 720))
                size = NSSize(width: 900, height: 720)
            case .donations:
                let sheet = NSHostingView(rootView: DonationSheet())
                size = sheet.fittingSize
                root = AnyView(DonationSheet().background(Color(nsColor: .windowBackgroundColor)))
            }
            let window = NSWindow(contentRect: NSRect(origin: .zero, size: size),
                                  styleMask: [.titled, .closable, .miniaturizable, .fullSizeContentView],
                                  backing: .buffered, defer: false)
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.isReleasedWhenClosed = false
            window.appearance = NSAppearance(named: appearance)
            window.contentView = NSHostingView(rootView: root)
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            try await Task.sleep(for: .milliseconds(1800))
            let base = URL(fileURLWithPath: directory).appendingPathComponent(name)
            try "\(window.windowNumber)".write(to: base.appendingPathExtension("id"), atomically: true, encoding: .utf8)
            let done = base.appendingPathExtension("done")
            let deadline = Date().addingTimeInterval(30)
            while !FileManager.default.fileExists(atPath: done.path), Date() < deadline {
                try await Task.sleep(for: .milliseconds(200))
            }
            window.orderOut(nil)
            XCTAssertTrue(FileManager.default.fileExists(atPath: done.path), "Screenshot \(name) was not captured")
        }
    }
}
