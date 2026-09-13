// Generates DuoButterfly/Resources/PreviewDesktop.png: an original sample desktop for the settings preview.
// The wallpaper is procedural glossy ribbons in a macOS-like style; the seed picks the layout, the palette the colors.
// Usage: swift scripts/draw-preview-desktop.swift OUTPUT.png [seed] [ocean|dusk|sunrise|lagoon]
// Current image: swift scripts/draw-preview-desktop.swift DuoButterfly/Resources/PreviewDesktop.png 7 ocean
import AppKit
import CoreText
import CoreImage

let width = 1586, height = 992
let W = CGFloat(width), H = CGFloat(height)
let cs = CGColorSpace(name: CGColorSpace.sRGB)!
let ctx = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
// Draw in top-left coordinates.
ctx.translateBy(x: 0, y: H); ctx.scaleBy(x: 1, y: -1)

func rgb(_ hex: UInt32, _ a: CGFloat = 1) -> CGColor {
    CGColor(red: CGFloat(hex >> 16 & 0xFF) / 255, green: CGFloat(hex >> 8 & 0xFF) / 255, blue: CGFloat(hex & 0xFF) / 255, alpha: a)
}
func gradient(_ colors: [CGColor], _ locations: [CGFloat]) -> CGGradient {
    CGGradient(colorsSpace: cs, colors: colors as CFArray, locations: locations)!
}
func rounded(_ r: CGRect, _ radius: CGFloat) -> CGPath {
    CGPath(roundedRect: r, cornerWidth: radius, cornerHeight: radius, transform: nil)
}
func fill(_ path: CGPath, _ color: CGColor) { ctx.addPath(path); ctx.setFillColor(color); ctx.fillPath() }
func text(_ string: String, _ point: CGPoint, size: CGFloat, weight: NSFont.Weight = .regular, color: CGColor) {
    let font = NSFont.systemFont(ofSize: size, weight: weight)
    let attributed = NSAttributedString(string: string, attributes: [.font: font, .foregroundColor: NSColor(cgColor: color)!])
    let line = CTLineCreateWithAttributedString(attributed)
    ctx.saveGState()
    ctx.textMatrix = CGAffineTransform(scaleX: 1, y: -1)
    ctx.textPosition = CGPoint(x: point.x, y: point.y + size * 0.8)
    CTLineDraw(line, ctx)
    ctx.restoreGState()
}

// Wallpaper.
struct SplitMix64: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E3779B97F4A7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58476D1CE4E5B9
        z = (z ^ (z >> 27)) &* 0x94D049BB133111EB
        return z ^ (z >> 31)
    }
}
let arguments = CommandLine.arguments
var random = SplitMix64(state: UInt64(arguments.count > 2 ? arguments[2] : "") ?? UInt64.random(in: 1...UInt64.max))
let palettes: [String: (background: [UInt32], ribbons: [UInt32], glow: UInt32)] = [
    "ocean": ([0x0A1F6B, 0x1E5BD8, 0x7FC4FF], [0x1B4FE0, 0x3E8BFF, 0x9FD4FF, 0x0D2A9C, 0xC9E6FF], 0xDDF0FF),
    "dusk": ([0x160F45, 0x5A2FC2, 0xE58ACB], [0x6B3BE0, 0xB06CF0, 0xFF9FD0, 0x2A1780, 0xFFD1E8], 0xFFE0F0),
    "sunrise": ([0x3A1452, 0xE0567A, 0xFFC27A], [0xFF7A59, 0xFFB35C, 0xFF5C8A, 0x8A2E6B, 0xFFE2B0], 0xFFF1D6),
    "lagoon": ([0x06323F, 0x0F8C8C, 0x9BE8C8], [0x10A5A0, 0x3BD1B0, 0xA6F0D5, 0x07575E, 0xD8FFF0], 0xE6FFF6),
]
let paletteName = arguments.count > 3 ? arguments[3] : palettes.keys.sorted().randomElement(using: &random)!
let palette = palettes[paletteName]!

func makeWallpaper() -> CGImage {
    let layer = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
    layer.drawLinearGradient(gradient(palette.background.map { rgb($0) }, [0, 0.55, 1]),
                             start: CGPoint(x: 0, y: H), end: CGPoint(x: W, y: 0), options: [])
    var image = CIImage(cgImage: layer.makeImage()!)
    let ci = CIContext(options: [.workingColorSpace: cs])
    // Back-to-front ribbons: far ones are wide and very blurred, near ones sharper with a glossy edge.
    let count = 7
    for index in 0..<count {
        let depth = CGFloat(index) / CGFloat(count - 1)
        let ribbon = CGContext(data: nil, width: width, height: height, bitsPerComponent: 8, bytesPerRow: 0, space: cs,
                               bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)!
        let thickness = CGFloat.random(in: 90...260, using: &random) * (1.3 - depth * 0.6)
        let startY = CGFloat.random(in: -0.2...1.1, using: &random) * H
        let endY = CGFloat.random(in: -0.2...1.1, using: &random) * H
        let c1 = CGPoint(x: W * CGFloat.random(in: 0.15...0.45, using: &random), y: CGFloat.random(in: -0.4...1.4, using: &random) * H)
        let c2 = CGPoint(x: W * CGFloat.random(in: 0.55...0.85, using: &random), y: CGFloat.random(in: -0.4...1.4, using: &random) * H)
        let twist = CGFloat.random(in: 0.4...1.6, using: &random)
        let path = CGMutablePath()
        path.move(to: CGPoint(x: -120, y: startY))
        path.addCurve(to: CGPoint(x: W + 120, y: endY), control1: c1, control2: c2)
        path.addLine(to: CGPoint(x: W + 120, y: endY + thickness))
        path.addCurve(to: CGPoint(x: -120, y: startY + thickness * twist),
                      control1: CGPoint(x: c2.x, y: c2.y + thickness * 1.8), control2: CGPoint(x: c1.x, y: c1.y + thickness * 0.4))
        path.closeSubpath()
        let colors = palette.ribbons.shuffled(using: &random)
        let alpha = 0.55 + depth * 0.4
        ribbon.saveGState()
        ribbon.addPath(path); ribbon.clip()
        ribbon.drawLinearGradient(gradient([rgb(colors[0], alpha), rgb(colors[1], alpha), rgb(colors[2], alpha * 0.9)], [0, 0.5, 1]),
                                  start: CGPoint(x: 0, y: min(startY, endY)), end: CGPoint(x: W, y: max(startY, endY) + thickness), options: [])
        ribbon.restoreGState()
        // Glossy highlight along the leading edge.
        let edge = CGMutablePath()
        edge.move(to: CGPoint(x: -120, y: startY + 3))
        edge.addCurve(to: CGPoint(x: W + 120, y: endY + 3), control1: CGPoint(x: c1.x, y: c1.y + 3), control2: CGPoint(x: c2.x, y: c2.y + 3))
        ribbon.addPath(edge)
        ribbon.setStrokeColor(rgb(palette.glow, 0.35 + depth * 0.45)); ribbon.setLineWidth(2 + depth * 4); ribbon.strokePath()
        let sigma = Double(28 - depth * 26)
        let layerImage = CIImage(cgImage: ribbon.makeImage()!).clampedToExtent()
            .applyingGaussianBlur(sigma: sigma).cropped(to: image.extent)
        image = layerImage.composited(over: image)
    }
    // Soft light bloom and gentle vignette.
    let bloom = CIFilter(name: "CIRadialGradient", parameters: [
        "inputCenter": CIVector(x: W * CGFloat.random(in: 0.2...0.8, using: &random), y: H * CGFloat.random(in: 0.3...0.8, using: &random)),
        "inputRadius0": 0, "inputRadius1": 620,
        "inputColor0": CIColor(cgColor: rgb(palette.glow, 0.32)), "inputColor1": CIColor(cgColor: rgb(palette.glow, 0)),
    ])!.outputImage!.cropped(to: image.extent)
    image = bloom.composited(over: image)
    image = image.applyingFilter("CIVignette", parameters: [kCIInputIntensityKey: 0.35, kCIInputRadiusKey: 2.2])
    return ci.createCGImage(image, from: CGRect(x: 0, y: 0, width: W, height: H), format: .RGBA8, colorSpace: cs)!
}
ctx.draw(makeWallpaper(), in: CGRect(x: 0, y: 0, width: W, height: H))

// Menu bar.
ctx.setFillColor(rgb(0xFFFFFF, 0.22)); ctx.fill(CGRect(x: 0, y: 0, width: W, height: 28))
fill(rounded(CGRect(x: 22, y: 8, width: 12, height: 12), 3), rgb(0xFFFFFF, 0.95))
for (x, w) in [(52, 64), (136, 38), (192, 44), (254, 52), (324, 36)] {
    fill(rounded(CGRect(x: CGFloat(x), y: 10, width: CGFloat(w), height: 8), 4), rgb(0xFFFFFF, x == 52 ? 0.95 : 0.7))
}
for (x, w) in [(1340, 18), (1372, 26), (1414, 18), (1450, 110)] {
    fill(rounded(CGRect(x: CGFloat(x), y: 10, width: CGFloat(w), height: 8), 4), rgb(0xFFFFFF, 0.75))
}

func window(_ frame: CGRect, title: Bool) {
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 18), blur: 44, color: rgb(0x0B0820, 0.45))
    fill(rounded(frame, 14), rgb(0xFBFAFD))
    ctx.restoreGState()
    ctx.addPath(rounded(frame.insetBy(dx: 0.5, dy: 0.5), 14)); ctx.setStrokeColor(rgb(0x000000, 0.08)); ctx.setLineWidth(1); ctx.strokePath()
    for (i, color) in [rgb(0xFF5F57), rgb(0xFEBC2E), rgb(0x28C840)].enumerated() {
        fill(CGPath(ellipseIn: CGRect(x: frame.minX + 20 + CGFloat(i) * 20, y: frame.minY + 18, width: 12, height: 12), transform: nil), color)
    }
    if title { fill(rounded(CGRect(x: frame.minX + 96, y: frame.minY + 20, width: 90, height: 9), 4.5), rgb(0x3A3552, 0.55)) }
}

// Picture window with an original illustrated landscape.
let photoFrame = CGRect(x: 816, y: 120, width: 712, height: 530)
window(photoFrame, title: true)
let art = CGRect(x: photoFrame.minX, y: photoFrame.minY + 48, width: photoFrame.width, height: photoFrame.height - 48)
ctx.saveGState()
let artPath = CGMutablePath()
artPath.addRect(CGRect(x: art.minX, y: art.minY, width: art.width, height: art.height - 14))
artPath.addPath(rounded(CGRect(x: art.minX, y: art.maxY - 28, width: art.width, height: 28), 14))
ctx.addPath(artPath); ctx.clip()
ctx.drawLinearGradient(gradient([rgb(0x2B1F6B), rgb(0x9B5BD6), rgb(0xFFB38F)], [0, 0.55, 1]),
                       start: CGPoint(x: art.midX, y: art.minY), end: CGPoint(x: art.midX, y: art.minY + art.height * 0.62), options: [])
fill(CGPath(ellipseIn: CGRect(x: art.minX + 430, y: art.minY + 150, width: 120, height: 120), transform: nil), rgb(0xFFE6C9, 0.95))
func ridge(_ baseY: CGFloat, _ peaks: [(CGFloat, CGFloat)], _ color: CGColor) {
    let path = CGMutablePath()
    path.move(to: CGPoint(x: art.minX, y: art.maxY))
    path.addLine(to: CGPoint(x: art.minX, y: baseY))
    var previous = CGPoint(x: art.minX, y: baseY)
    for (x, y) in peaks {
        let point = CGPoint(x: art.minX + x, y: y)
        path.addQuadCurve(to: point, control: CGPoint(x: (previous.x + point.x) / 2, y: min(previous.y, point.y) - 18))
        previous = point
    }
    path.addLine(to: CGPoint(x: art.maxX, y: baseY)); path.addLine(to: CGPoint(x: art.maxX, y: art.maxY)); path.closeSubpath()
    fill(path, color)
}
ridge(art.minY + 250, [(120, art.minY + 200), (260, art.minY + 240), (420, art.minY + 180), (600, art.minY + 230), (712, art.minY + 210)], rgb(0x6A4BB8, 0.9))
ridge(art.minY + 300, [(90, art.minY + 270), (300, art.minY + 310), (480, art.minY + 250), (712, art.minY + 300)], rgb(0x40307F))
ctx.drawLinearGradient(gradient([rgb(0x5B7BD9), rgb(0x2A2F7A)], [0, 1]),
                       start: CGPoint(x: art.midX, y: art.minY + 330), end: CGPoint(x: art.midX, y: art.maxY), options: [])
ctx.setFillColor(rgb(0x2A2F7A)); ctx.fill(CGRect(x: art.minX, y: art.minY + 330, width: art.width, height: 0))
for i in 0..<7 {
    let y = art.minY + 350 + CGFloat(i) * 20
    fill(rounded(CGRect(x: art.minX + 300 + CGFloat(i % 2) * 40 - CGFloat(i) * 8, y: y, width: 140 + CGFloat(i) * 14, height: 3), 1.5), rgb(0xFFE6C9, 0.35 - CGFloat(i) * 0.04))
}
ridge(art.maxY - 40, [(160, art.maxY - 90), (330, art.maxY - 60), (712, art.maxY - 30)], rgb(0x1C1640))
ctx.restoreGState()
// Picture window toolbar glyphs.
for x in stride(from: photoFrame.maxX - 330, through: photoFrame.maxX - 30, by: 50) {
    ctx.addPath(CGPath(ellipseIn: CGRect(x: x, y: photoFrame.minY + 17, width: 15, height: 15), transform: nil))
    ctx.setStrokeColor(rgb(0x3A3552, 0.6)); ctx.setLineWidth(1.6); ctx.strokePath()
}

// Notes-like window with sidebar, heading and checklist.
let notes = CGRect(x: 110, y: 198, width: 908, height: 570)
window(notes, title: false)
ctx.saveGState()
let sidebarPath = CGMutablePath()
sidebarPath.addPath(rounded(CGRect(x: notes.minX, y: notes.minY, width: 220, height: notes.height), 14))
ctx.addPath(sidebarPath); ctx.clip()
ctx.setFillColor(rgb(0xF0EEF6)); ctx.fill(CGRect(x: notes.minX, y: notes.minY, width: 202, height: notes.height))
ctx.restoreGState()
fill(rounded(CGRect(x: notes.minX + 22, y: notes.minY + 58, width: 52, height: 8), 4), rgb(0x3A3552, 0.4))
fill(rounded(CGRect(x: notes.minX + 10, y: notes.minY + 80, width: 182, height: 38), 8), rgb(0x8A4FD8, 0.22))
for (i, w) in [70, 58, 64].enumerated() {
    let y = notes.minY + 94 + CGFloat(i) * 40
    fill(rounded(CGRect(x: notes.minX + 24, y: y - 2, width: 16, height: 13), 3), rgb(i == 0 ? 0x8A4FD8 : 0x7A7590, 0.8))
    fill(rounded(CGRect(x: notes.minX + 52, y: y, width: CGFloat(w), height: 9), 4.5), rgb(0x2A2540, i == 0 ? 0.8 : 0.55))
}
for x in [notes.minX + 228, notes.minX + 274] {
    fill(rounded(CGRect(x: x, y: notes.minY + 17, width: 16, height: 16), 4), rgb(0x3A3552, 0.35))
}
for x in stride(from: notes.maxX - 360, through: notes.maxX - 40, by: 48) {
    fill(rounded(CGRect(x: x, y: notes.minY + 17, width: 18, height: 16), 4), rgb(0x3A3552, 0.3))
}
ctx.setFillColor(rgb(0x000000, 0.06)); ctx.fill(CGRect(x: notes.minX + 202, y: notes.minY + 50, width: notes.width - 202, height: 1))
let body = notes.minX + 252
text("DUO Butterfly", CGPoint(x: body, y: notes.minY + 92), size: 30, weight: .bold, color: rgb(0x1F1B30))
fill(rounded(CGRect(x: body, y: notes.minY + 160, width: 260, height: 11), 5.5), rgb(0x2A2540, 0.55))
for (i, (w, done)) in [(210, true), (250, false), (190, false)].enumerated() {
    let y = notes.minY + 212 + CGFloat(i) * 38
    let circle = CGRect(x: body, y: y - 4, width: 22, height: 22)
    if done {
        fill(CGPath(ellipseIn: circle, transform: nil), rgb(0x8A4FD8))
        ctx.move(to: CGPoint(x: circle.minX + 6, y: circle.midY)); ctx.addLine(to: CGPoint(x: circle.minX + 10, y: circle.maxY - 6))
        ctx.addLine(to: CGPoint(x: circle.maxX - 5, y: circle.minY + 6))
        ctx.setStrokeColor(rgb(0xFFFFFF)); ctx.setLineWidth(2.4); ctx.setLineCap(.round); ctx.strokePath()
    } else {
        ctx.addPath(CGPath(ellipseIn: circle.insetBy(dx: 1, dy: 1), transform: nil))
        ctx.setStrokeColor(rgb(0x3A3552, 0.45)); ctx.setLineWidth(1.6); ctx.strokePath()
    }
    fill(rounded(CGRect(x: body + 38, y: y + 2, width: CGFloat(w), height: 10), 5), rgb(0x2A2540, done ? 0.35 : 0.6))
}
for (i, w) in [520, 480, 540, 300].enumerated() {
    fill(rounded(CGRect(x: body, y: notes.minY + 360 + CGFloat(i) * 26, width: CGFloat(w), height: 9), 4.5), rgb(0x2A2540, 0.28))
}

// Dock with macOS-style icons drawn from scratch (no Apple artwork).
func tile(_ r: CGRect, _ top: UInt32, _ bottom: UInt32) {
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: 3), blur: 6, color: rgb(0x0B0820, 0.28))
    fill(rounded(r, r.width * 0.225), rgb(top))
    ctx.restoreGState()
    ctx.saveGState()
    ctx.addPath(rounded(r, r.width * 0.225)); ctx.clip()
    ctx.drawLinearGradient(gradient([rgb(top), rgb(bottom)], [0, 1]), start: CGPoint(x: r.midX, y: r.minY), end: CGPoint(x: r.midX, y: r.maxY), options: [])
    ctx.restoreGState()
}
func stroke(_ path: CGPath, _ color: CGColor, _ width: CGFloat) {
    ctx.addPath(path); ctx.setStrokeColor(color); ctx.setLineWidth(width); ctx.setLineCap(.round); ctx.setLineJoin(.round); ctx.strokePath()
}
func ellipse(_ r: CGRect) -> CGPath { CGPath(ellipseIn: r, transform: nil) }

let iconSize: CGFloat = 60, iconGap: CGFloat = 12, dockPadding: CGFloat = 22, dividerWidth: CGFloat = 20
let appCount = 9
let dockWidth = dockPadding * 2 + CGFloat(appCount + 1) * iconSize + CGFloat(appCount) * iconGap + dividerWidth
let dock = CGRect(x: ((W - dockWidth) / 2).rounded(), y: 888, width: dockWidth, height: 84)
ctx.saveGState()
ctx.setShadow(offset: CGSize(width: 0, height: 8), blur: 24, color: rgb(0x0B0820, 0.3))
fill(rounded(dock, 26), rgb(0xFFFFFF, 0.26))
ctx.restoreGState()
stroke(rounded(dock.insetBy(dx: 0.5, dy: 0.5), 26), rgb(0xFFFFFF, 0.5), 1)

var slotX = dock.minX + dockPadding
func nextSlot() -> CGRect {
    defer { slotX += iconSize + iconGap }
    return CGRect(x: slotX, y: dock.minY + 12, width: iconSize, height: iconSize)
}

// 1. Files: folder.
do {
    let r = nextSlot(); tile(r, 0x8FD3FF, 0x2F86EA)
    let back = CGMutablePath()
    back.addPath(rounded(CGRect(x: r.minX + 11, y: r.minY + 17, width: 16, height: 10), 3))
    back.addPath(rounded(CGRect(x: r.minX + 11, y: r.minY + 21, width: 38, height: 24), 4))
    fill(back, rgb(0xD6EEFF))
    fill(rounded(CGRect(x: r.minX + 11, y: r.minY + 26, width: 38, height: 21), 4), rgb(0xFFFFFF, 0.95))
}
// 2. Browser: compass.
do {
    let r = nextSlot(); tile(r, 0xFFFFFF, 0xE9EEF5)
    let dial = r.insetBy(dx: 8, dy: 8)
    ctx.saveGState(); ctx.addPath(ellipse(dial)); ctx.clip()
    ctx.drawLinearGradient(gradient([rgb(0x5AC8FA), rgb(0x1560D8)], [0, 1]), start: CGPoint(x: dial.midX, y: dial.minY), end: CGPoint(x: dial.midX, y: dial.maxY), options: [])
    ctx.restoreGState()
    for i in 0..<12 {
        let angle = CGFloat(i) / 12 * .pi * 2
        let inner = dial.width / 2 - (i % 3 == 0 ? 6 : 4), outer = dial.width / 2 - 1.5
        let line = CGMutablePath()
        line.move(to: CGPoint(x: dial.midX + cos(angle) * inner, y: dial.midY + sin(angle) * inner))
        line.addLine(to: CGPoint(x: dial.midX + cos(angle) * outer, y: dial.midY + sin(angle) * outer))
        stroke(line, rgb(0xFFFFFF, 0.85), 1.2)
    }
    let c = CGPoint(x: dial.midX, y: dial.midY), t = CGAffineTransform(translationX: c.x, y: c.y).rotated(by: .pi / 4)
    let north = CGMutablePath(); north.move(to: CGPoint(x: 0, y: -18)); north.addLine(to: CGPoint(x: 4, y: 0)); north.addLine(to: CGPoint(x: -4, y: 0)); north.closeSubpath()
    let south = CGMutablePath(); south.move(to: CGPoint(x: 0, y: 18)); south.addLine(to: CGPoint(x: 4, y: 0)); south.addLine(to: CGPoint(x: -4, y: 0)); south.closeSubpath()
    ctx.addPath(north.copy(using: [t])!); ctx.setFillColor(rgb(0xFF3B30)); ctx.fillPath()
    ctx.addPath(south.copy(using: [t])!); ctx.setFillColor(rgb(0xFFFFFF)); ctx.fillPath()
}
// 3. Messages: speech bubble.
do {
    let r = nextSlot(); tile(r, 0x6CF08A, 0x1DB954)
    let bubble = CGMutablePath()
    bubble.addEllipse(in: CGRect(x: r.minX + 10, y: r.minY + 13, width: 40, height: 31))
    bubble.move(to: CGPoint(x: r.minX + 17, y: r.minY + 38))
    bubble.addQuadCurve(to: CGPoint(x: r.minX + 11, y: r.minY + 49), control: CGPoint(x: r.minX + 17, y: r.minY + 46))
    bubble.addQuadCurve(to: CGPoint(x: r.minX + 26, y: r.minY + 42), control: CGPoint(x: r.minX + 20, y: r.minY + 47))
    bubble.closeSubpath()
    fill(bubble, rgb(0xFFFFFF))
}
// 4. Mail: envelope.
do {
    let r = nextSlot(); tile(r, 0x5FB8FF, 0x1A6CF0)
    let env = CGRect(x: r.minX + 10, y: r.minY + 17, width: 40, height: 27)
    fill(rounded(env, 4), rgb(0xFFFFFF))
    let flap = CGMutablePath(); flap.move(to: CGPoint(x: env.minX + 2, y: env.minY + 3)); flap.addLine(to: CGPoint(x: env.midX, y: env.midY + 2)); flap.addLine(to: CGPoint(x: env.maxX - 2, y: env.minY + 3))
    stroke(flap, rgb(0x1A6CF0, 0.55), 2)
}
// 5. Maps: roads and a pin.
do {
    let r = nextSlot(); tile(r, 0xDFF3D2, 0xB6E1A8)
    ctx.saveGState(); ctx.addPath(rounded(r, r.width * 0.225)); ctx.clip()
    let water = CGMutablePath(); water.move(to: CGPoint(x: r.maxX, y: r.minY)); water.addLine(to: CGPoint(x: r.maxX, y: r.minY + 26)); water.addQuadCurve(to: CGPoint(x: r.minX + 30, y: r.minY), control: CGPoint(x: r.minX + 42, y: r.minY + 20)); water.closeSubpath()
    fill(water, rgb(0x8FD0FF))
    let road = CGMutablePath(); road.move(to: CGPoint(x: r.minX - 4, y: r.maxY - 12)); road.addCurve(to: CGPoint(x: r.maxX + 4, y: r.minY + 34), control1: CGPoint(x: r.minX + 22, y: r.maxY - 18), control2: CGPoint(x: r.minX + 36, y: r.minY + 30))
    stroke(road, rgb(0xFFFFFF), 7); stroke(road, rgb(0xFFC94A), 2.5)
    ctx.restoreGState()
    let pin = CGMutablePath(); pin.addEllipse(in: CGRect(x: r.minX + 23, y: r.minY + 14, width: 16, height: 16))
    pin.move(to: CGPoint(x: r.minX + 24.5, y: r.minY + 25)); pin.addLine(to: CGPoint(x: r.minX + 31, y: r.minY + 38)); pin.addLine(to: CGPoint(x: r.minX + 37.5, y: r.minY + 25)); pin.closeSubpath()
    fill(pin, rgb(0xFF3B30)); fill(ellipse(CGRect(x: r.minX + 28, y: r.minY + 19, width: 6, height: 6)), rgb(0xFFFFFF))
}
// 6. Gallery: landscape picture.
do {
    let r = nextSlot(); tile(r, 0xFFFFFF, 0xF1F1F4)
    let pic = CGRect(x: r.minX + 9, y: r.minY + 12, width: 42, height: 36)
    ctx.saveGState(); ctx.addPath(rounded(pic, 6)); ctx.clip()
    ctx.drawLinearGradient(gradient([rgb(0xFFB36B), rgb(0xFF6FA8)], [0, 1]), start: CGPoint(x: pic.midX, y: pic.minY), end: CGPoint(x: pic.midX, y: pic.maxY), options: [])
    fill(ellipse(CGRect(x: pic.minX + 25, y: pic.minY + 6, width: 10, height: 10)), rgb(0xFFF2B0))
    let hills = CGMutablePath(); hills.move(to: CGPoint(x: pic.minX, y: pic.maxY)); hills.addLine(to: CGPoint(x: pic.minX, y: pic.minY + 26)); hills.addQuadCurve(to: CGPoint(x: pic.minX + 22, y: pic.minY + 22), control: CGPoint(x: pic.minX + 10, y: pic.minY + 14)); hills.addQuadCurve(to: CGPoint(x: pic.maxX, y: pic.minY + 24), control: CGPoint(x: pic.minX + 34, y: pic.minY + 12)); hills.addLine(to: CGPoint(x: pic.maxX, y: pic.maxY)); hills.closeSubpath()
    fill(hills, rgb(0x7A3FD0))
    ctx.restoreGState()
}
// 7. Notes: yellow header with lines.
do {
    let r = nextSlot(); tile(r, 0xFFFFFF, 0xF4F2EA)
    ctx.saveGState(); ctx.addPath(rounded(r, r.width * 0.225)); ctx.clip()
    ctx.drawLinearGradient(gradient([rgb(0xFFE27A), rgb(0xFFC928)], [0, 1]), start: CGPoint(x: r.midX, y: r.minY), end: CGPoint(x: r.midX, y: r.minY + 17), options: [])
    ctx.setFillColor(rgb(0xFFC928)); ctx.fill(CGRect(x: r.minX, y: r.minY, width: r.width, height: 0))
    ctx.restoreGState()
    for i in 0..<4 {
        let y = r.minY + 26 + CGFloat(i) * 8
        let line = CGMutablePath(); line.move(to: CGPoint(x: r.minX + 9, y: y)); line.addLine(to: CGPoint(x: r.maxX - 9, y: y))
        stroke(line, rgb(0xD9D5C8), 1.2)
    }
}
// 8. Calendar: red band and a date.
do {
    let r = nextSlot(); tile(r, 0xFFFFFF, 0xF4F4F6)
    ctx.saveGState(); ctx.addPath(rounded(r, r.width * 0.225)); ctx.clip()
    ctx.setFillColor(rgb(0xFF3B30)); ctx.fill(CGRect(x: r.minX, y: r.minY, width: r.width, height: 15))
    ctx.restoreGState()
    for (i, w) in [8.0, 6.0].enumerated() { fill(rounded(CGRect(x: r.midX - 9 + CGFloat(i) * 11, y: r.minY + 5, width: w, height: 4), 2), rgb(0xFFFFFF, 0.9)) }
    text("11", CGPoint(x: r.minX + 13, y: r.minY + 18), size: 30, weight: .light, color: rgb(0x1C1C1E))
}
// 9. Settings: gear.
do {
    let r = nextSlot(); tile(r, 0xD1D3D9, 0x8E929B)
    let c = CGPoint(x: r.midX, y: r.midY)
    let gear = CGMutablePath()
    let teeth = 12
    for i in 0..<(teeth * 2) {
        let angle = CGFloat(i) / CGFloat(teeth * 2) * .pi * 2
        let radius: CGFloat = i % 2 == 0 ? 22 : 18
        let point = CGPoint(x: c.x + cos(angle) * radius, y: c.y + sin(angle) * radius)
        if i == 0 { gear.move(to: point) } else { gear.addLine(to: point) }
    }
    gear.closeSubpath()
    fill(gear, rgb(0x3A3C42))
    fill(ellipse(CGRect(x: c.x - 14, y: c.y - 14, width: 28, height: 28)), rgb(0xE6E7EB))
    fill(ellipse(CGRect(x: c.x - 6, y: c.y - 6, width: 12, height: 12)), rgb(0x5A5D64))
}
// Divider and trash.
let dividerX = slotX - iconGap + dividerWidth / 2
let divider = CGMutablePath(); divider.move(to: CGPoint(x: dividerX, y: dock.minY + 14)); divider.addLine(to: CGPoint(x: dividerX, y: dock.maxY - 14))
stroke(divider, rgb(0xFFFFFF, 0.45), 1)
slotX += dividerWidth - iconGap / 2
do {
    let r = nextSlot()
    let bin = CGMutablePath()
    bin.move(to: CGPoint(x: r.minX + 12, y: r.minY + 10)); bin.addLine(to: CGPoint(x: r.maxX - 12, y: r.minY + 10))
    bin.addLine(to: CGPoint(x: r.maxX - 16, y: r.maxY - 4)); bin.addLine(to: CGPoint(x: r.minX + 16, y: r.maxY - 4)); bin.closeSubpath()
    ctx.saveGState(); ctx.addPath(bin); ctx.clip()
    ctx.drawLinearGradient(gradient([rgb(0xFFFFFF, 0.85), rgb(0xDDE3EC, 0.75)], [0, 1]), start: CGPoint(x: r.minX, y: r.midY), end: CGPoint(x: r.maxX, y: r.midY), options: [])
    ctx.restoreGState()
    stroke(bin, rgb(0xFFFFFF, 0.9), 1.2)
    fill(ellipse(CGRect(x: r.minX + 11, y: r.minY + 6, width: r.width - 22, height: 8)), rgb(0xC9D2DE, 0.9))
    for dx in [-8.0, 0.0, 8.0] {
        let rib = CGMutablePath(); rib.move(to: CGPoint(x: r.midX + dx, y: r.minY + 18)); rib.addLine(to: CGPoint(x: r.midX + dx * 0.8, y: r.maxY - 9))
        stroke(rib, rgb(0xAEB7C4, 0.7), 1)
    }
}

let image = ctx.makeImage()!
let data = NSBitmapImageRep(cgImage: image).representation(using: .png, properties: [:])!
try! data.write(to: URL(fileURLWithPath: CommandLine.arguments[1]))
print("Wrote \(CommandLine.arguments[1]) \(width)x\(height), palette \(paletteName)")
