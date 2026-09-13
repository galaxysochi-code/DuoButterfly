import AppKit
import Observation
import QuartzCore

enum FoldStyle: String, Codable, CaseIterable, Identifiable, Sendable {
    case silk, shade, frost
    var id: String { rawValue }
    var title: String {
        switch self { case .silk: tr("Шёлк"); case .shade: tr("Сумерки"); case .frost: tr("Туман") }
    }
    var subtitle: String {
        switch self { case .silk: tr("Мягкий изгиб"); case .shade: tr("Глубокие тени"); case .frost: tr("Матовое стекло") }
    }
    var index: Float {
        switch self { case .silk: 0; case .shade: 1; case .frost: 2 }
    }
}

enum SettingsSection: String, CaseIterable, Identifiable, Sendable {
    case effect, general, about
    var id: String { rawValue }
    var title: String {
        switch self { case .effect: tr("Эффект"); case .general: tr("Настройки"); case .about: tr("О программе") }
    }
}

struct Preferences: Codable, Equatable, Sendable {
    var enabled = true
    var style: FoldStyle = .silk
    var perspective = 0.85
    var blur = 0.45
    var shadow = 0.35
    var clearAngle = 110.0
    var sound = false

    func applying(_ style: FoldStyle) -> Preferences {
        var next = self
        next.style = style
        switch style {
        case .silk: (next.perspective, next.blur, next.shadow) = (0.85, 0.45, 0.35)
        case .shade: (next.perspective, next.blur, next.shadow) = (0.90, 0.25, 0.85)
        case .frost: (next.perspective, next.blur, next.shadow) = (0.65, 0.90, 0.25)
        }
        return next
    }

    var hasCustomStyle: Bool {
        let preset = applying(style)
        return abs(perspective - preset.perspective) > 0.0001
            || abs(blur - preset.blur) > 0.0001 || abs(shadow - preset.shadow) > 0.0001
    }

    func validated() -> Preferences {
        var copy = self
        copy.perspective = perspective.isFinite ? min(1, max(0, perspective)) : 0.85
        copy.blur = blur.isFinite ? min(1, max(0, blur)) : 0.45
        copy.shadow = shadow.isFinite ? min(1, max(0, shadow)) : 0.35
        copy.clearAngle = clearAngle.isFinite ? min(135, max(60, clearAngle)) : 110
        return copy
    }
}

enum FoldMath {
    static func progress(angle: Double, clearAngle: Double) -> Double {
        guard angle.isFinite, clearAngle.isFinite, clearAngle > 15 else { return 0 }
        return min(1, max(0, (clearAngle - angle) / (clearAngle - 15)))
    }

    static func shouldCapture(angle: Double?, clearAngle: Double, enabled: Bool,
                              permitted: Bool, suspended: Bool, demo: Bool) -> Bool {
        guard enabled, permitted, !suspended else { return false }
        if demo { return true }
        guard let angle, angle.isFinite else { return false }
        return angle > 5 && angle < clearAngle + 8
    }
}

struct FoldMotion {
    private(set) var value = 0.0
    private var previousTime: Double?

    mutating func update(target: Double, at time: Double) -> Double {
        let dt = previousTime.map { min(0.1, max(0, time - $0)) } ?? 1.0 / 60
        previousTime = time
        value += (target - value) * (1 - exp(-dt / 0.015))
        if abs(value - target) < 0.0002 { value = target }
        return value
    }
}

struct LidMotion {
    private(set) var sample: LidSample?
    private var velocity = 0.0
    private var anchor = 0.0
    private var slowStart: Double?
    private var slowDuration = 0.0

    mutating func update(_ next: LidSample) {
        var nextAnchor = next.degrees
        if let previous = sample {
            let dt = next.timestamp - previous.timestamp
            guard dt > 0, next.degrees != previous.degrees else { return }
            let measured = (next.degrees - previous.degrees) / dt
            let continuingSlow = slowStart != nil && dt >= slowDuration * 0.4
            if dt <= 2.1, abs(next.degrees - previous.degrees) <= 1, dt >= 0.15 || continuingSlow {
                let duration = continuingSlow ? max(dt, slowDuration * 0.95) : dt
                slowStart = angle(at: next.timestamp) ?? previous.degrees
                slowDuration = duration
                velocity = 0
                anchor = next.degrees
                sample = next
                return
            }
            if dt > 0.25 { velocity = 0 }
            else if velocity * measured <= 0 { velocity = measured }
            else {
                let presented = angle(at: next.timestamp) ?? next.degrees
                nextAnchor = measured < 0 ? min(presented, next.degrees) : max(presented, next.degrees)
                velocity = velocity * 0.25 + measured * 0.75
            }
        }
        slowStart = nil
        anchor = nextAnchor
        sample = next
    }

    func angle(at time: Double) -> Double? {
        guard let sample else { return nil }
        let age = max(0, time - sample.timestamp)
        if let slowStart {
            let fraction = min(1, age / slowDuration)
            return min(180, max(0, slowStart + (sample.degrees - slowStart) * fraction))
        }
        let forecast = anchor - sample.degrees + velocity * min(age, 0.1)
        let offset = min(4, max(-4, forecast)) * exp(-max(0, age - 0.15) / 0.045)
        return min(180, max(0, sample.degrees + offset))
    }
}

struct OpenCycle: Sendable {
    private(set) var folded = false
    mutating func update(progress: Double) -> Bool {
        if progress > 0.08 { folded = true }
        if progress <= 0.001 && folded { folded = false; return true }
        return false
    }
    mutating func reset() { folded = false }
}

@MainActor @Observable final class AppModel {
    @ObservationIgnored private let defaults: UserDefaults
    var preferences: Preferences {
        didSet {
            if let data = try? JSONEncoder().encode(preferences) {
                defaults.set(data, forKey: "preferences.v1")
            }
            onPreferencesChanged?()
        }
    }
    var angle: Double?
    @ObservationIgnored var lidMotion = LidMotion()
    var sensorAvailable = false
    var sensorDetail = tr("Подключаем датчик…")
    var permissionGranted = false
    var capturing = false
    var overlayVisible = false
    var suspended = false
    var demoActive = false
    var previewAngle = 70.0
    var section: SettingsSection = .effect
    var showsDonations = false
    var thanksBannerHiddenUntil: Date? {
        didSet { defaults.set(thanksBannerHiddenUntil, forKey: "thanksBanner.hiddenUntil") }
    }
    var launchAtLogin = false
    var error: String?
    var hotKeyError: String?
    var framesReceived = 0
    @ObservationIgnored var onPreferencesChanged: (() -> Void)?

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: "preferences.v1"),
           let saved = try? JSONDecoder().decode(Preferences.self, from: data) {
            preferences = saved.validated()
        } else { preferences = Preferences() }
        thanksBannerHiddenUntil = defaults.object(forKey: "thanksBanner.hiddenUntil") as? Date
        previewAngle = (preferences.clearAngle - (preferences.clearAngle - 15) * 0.32).rounded()
    }

    var previewProgress: Double {
        FoldMath.progress(angle: previewAngle,
                          clearAngle: preferences.clearAngle)
    }
    var status: String {
        if !preferences.enabled { return tr("На паузе") }
        if suspended { return tr("Экран выключен") }
        if !permissionGranted { return tr("Нужен доступ к экрану") }
        if error != nil { return tr("Требуется внимание") }
        if demoActive { return tr("Демонстрация") }
        if !sensorAvailable { return tr("Датчик недоступен") }
        if overlayVisible { return tr("Работает") }
        if let angle, angle > 5, angle < preferences.clearAngle { return tr("Подготовка эффекта") }
        return tr("Готов к работе")
    }
    var toggleActionTitle: String {
        if demoActive { return tr("Остановить демонстрацию") }
        return preferences.enabled ? tr("Приостановить эффект") : tr("Включить эффект")
    }

    var showsThanksBanner: Bool {
        guard !Donations.available.isEmpty else { return false }
        return thanksBannerHiddenUntil.map { $0 <= Date() } ?? true
    }

    /// Hides the banner for the rest of the day; it comes back tomorrow.
    func hideThanksBanner(now: Date = Date(), calendar: Calendar = .current) {
        thanksBannerHiddenUntil = calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: now))
    }

    func select(_ style: FoldStyle) {
        preferences = preferences.applying(style)
    }

    func resetEffect() {
        var defaults = Preferences()
        defaults.enabled = preferences.enabled
        defaults.sound = preferences.sound
        preferences = defaults
    }
}
