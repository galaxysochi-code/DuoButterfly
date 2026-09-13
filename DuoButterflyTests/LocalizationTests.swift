import XCTest
@testable import DuoButterfly

final class LocalizationTests: XCTestCase {
    /// Every `tr("…")` literal in the app sources must have English, Chinese and Spanish text.
    func testEveryInterfaceStringIsTranslated() throws {
        let sources = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
            .deletingLastPathComponent().appendingPathComponent("DuoButterfly")
        let files = try FileManager.default.contentsOfDirectory(at: sources, includingPropertiesForKeys: nil)
            .filter { $0.pathExtension == "swift" && $0.lastPathComponent != "Localization.swift" }
        XCTAssertFalse(files.isEmpty)
        let pattern = try NSRegularExpression(pattern: #"tr\("((?:[^"\\]|\\.)*)""#)
        var missing: [String] = []
        var count = 0
        for file in files {
            let text = try String(contentsOf: file, encoding: .utf8)
            for match in pattern.matches(in: text, range: NSRange(text.startIndex..., in: text)) {
                let raw = String(text[Range(match.range(at: 1), in: text)!])
                let key = raw.replacingOccurrences(of: #"\n"#, with: "\n").replacingOccurrences(of: #"\""#, with: "\"")
                count += 1
                if !Localizer.hasTranslation(key) { missing.append("\(file.lastPathComponent): \(key)") }
            }
        }
        XCTAssertGreaterThan(count, 100)
        XCTAssertTrue(missing.isEmpty, "Untranslated strings:\n" + missing.joined(separator: "\n"))
    }

    func testSystemLanguageResolvesToSupportedLanguage() {
        XCTAssertNotEqual(Localizer.systemLanguage, .system)
    }
}
