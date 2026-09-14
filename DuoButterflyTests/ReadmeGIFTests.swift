import XCTest
import Metal
import MetalKit
import simd
import ImageIO
import UniformTypeIdentifiers
import AppKit
import CoreImage
@testable import DuoButterfly

/// Renders the lid-closing effect for every style into an animated GIF for the README.
/// Run through scripts/readme-gif.sh; skipped in normal test runs.
final class ReadmeGIFTests: XCTestCase {
    private let width = 720, height = 450
    private let canvasWidth = 760, canvasHeight = 540
    private let fps = 20.0

    @MainActor func testRenderEffectGIF() throws {
        guard let output = ProcessInfo.processInfo.environment["DUOBUTTERFLY_GIF"] else {
            throw XCTSkip("Run scripts/readme-gif.sh to render the README GIF")
        }
        Localizer.testLanguage = .en
        defer { Localizer.testLanguage = .ru }
        let resources = RenderResources.shared
        let device = try XCTUnwrap(resources.device)
        let queue = try XCTUnwrap(resources.queue)
        let source = try XCTUnwrap(resources.demoTexture)

        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm_srgb,
            width: width, height: height, mipmapped: false)
        descriptor.storageMode = .shared
        descriptor.usage = .renderTarget
        let target = try XCTUnwrap(device.makeTexture(descriptor: descriptor))
        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = target
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].storeAction = .store
        pass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)

        // Same motion as the in-app demo: close the lid, then open it again.
        let hold = 0.3, cycle = 2.6
        let framesPerStyle = Int(((hold + cycle) * fps).rounded())
        var frames: [CGImage] = []
        for style in FoldStyle.allCases {
            let preferences = Preferences().applying(style)
            let renderer = FoldRenderer { RenderParameters(progress: 0, preferences: preferences, overlay: false, reducedMotion: false) }
            for index in 0..<framesPerStyle {
                let time = Double(index) / fps
                let phase = max(0, time - hold) / cycle
                let progress = time < hold ? 0 : pow(sin(min(1, phase) * .pi), 2) * 0.62
                let params = RenderParameters(progress: progress, preferences: preferences, overlay: false, reducedMotion: false)
                let command = try XCTUnwrap(queue.makeCommandBuffer())
                XCTAssertTrue(renderer.encode(texture: source, pass: pass, command: command, params: params,
                                              progress: progress, size: CGSize(width: width, height: height)))
                command.commit()
                command.waitUntilCompleted()
                XCTAssertNil(command.error)
                let angle = preferences.clearAngle - progress * (preferences.clearAngle - 15)
                frames.append(try compose(image(from: target), style: style, angle: angle, progress: progress / 0.62))
            }
        }

        let picks = [0, framesPerStyle / 2, framesPerStyle + framesPerStyle / 2, framesPerStyle * 2 + framesPerStyle / 2]
        try writeGIF(frames, to: URL(fileURLWithPath: output), sheetPicks: picks)
    }

    private static let lidOpen = 116.0, lidClosed = 4.0
    private static let hold = 0.8, closing = 2.0, rest = 0.6, opening = 1.8, tail = 0.3
    private static var cycleDuration: Double { hold + closing + rest + opening + tail }

    private static func ease(_ x: Double) -> Double { x < 0.5 ? 4 * x * x * x : 1 - pow(-2 * x + 2, 3) / 2 }

    /// Lid angle over one close-and-open cycle.
    private static func lidAngle(at time: Double) -> Double {
        switch time {
        case ..<hold: lidOpen
        case ..<(hold + closing): lidOpen + (lidClosed - lidOpen) * ease((time - hold) / closing)
        case ..<(hold + closing + rest): lidClosed
        case ..<(hold + closing + rest + opening): lidClosed + (lidOpen - lidClosed) * ease((time - hold - closing - rest) / opening)
        default: lidOpen
        }
    }

    @MainActor private func effectTarget(width: Int, height: Int) throws -> (MTLTexture, MTLRenderPassDescriptor) {
        let device = try XCTUnwrap(RenderResources.shared.device)
        let descriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm_srgb, width: width, height: height, mipmapped: false)
        descriptor.storageMode = .shared
        descriptor.usage = .renderTarget
        let target = try XCTUnwrap(device.makeTexture(descriptor: descriptor))
        let pass = MTLRenderPassDescriptor()
        pass.colorAttachments[0].texture = target
        pass.colorAttachments[0].loadAction = .clear
        pass.colorAttachments[0].storeAction = .store
        pass.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 1)
        return (target, pass)
    }

    /// Renders the effect for one style at a lid angle into `target` and returns it as an image.
    /// Desktop picture shown on the laptop screen; scripts/readme-gif.sh passes a purple wallpaper render.
    @MainActor private lazy var wallpaper: MTLTexture? = {
        guard let path = ProcessInfo.processInfo.environment["DUOBUTTERFLY_GIF_WALLPAPER"],
              let device = RenderResources.shared.device else { return nil }
        return try? MTKTextureLoader(device: device).newTexture(URL: URL(fileURLWithPath: path),
            options: [.SRGB: true, .textureUsage: MTLTextureUsage.shaderRead.rawValue])
    }()

    @MainActor private func screen(_ renderer: FoldRenderer, _ preferences: Preferences, angle: Double,
                                   target: MTLTexture, pass: MTLRenderPassDescriptor) throws -> CGImage {
        let queue = try XCTUnwrap(RenderResources.shared.queue)
        let source = try XCTUnwrap(wallpaper ?? RenderResources.shared.demoTexture)
        let progress = FoldMath.progress(angle: angle, clearAngle: preferences.clearAngle)
        let params = RenderParameters(progress: progress, preferences: preferences, overlay: false, reducedMotion: false)
        let command = try XCTUnwrap(queue.makeCommandBuffer())
        XCTAssertTrue(renderer.encode(texture: source, pass: pass, command: command, params: params,
                                      progress: progress, size: CGSize(width: target.width, height: target.height)))
        command.commit()
        command.waitUntilCompleted()
        XCTAssertNil(command.error)
        return try image(from: target)
    }

    /// A MacBook-like laptop closes and opens for each style; the screen shows the effect at the current lid angle.
    @MainActor func testRenderLaptopGIF() throws {
        guard let output = ProcessInfo.processInfo.environment["DUOBUTTERFLY_LAPTOP_GIF"] else {
            throw XCTSkip("Run scripts/readme-gif.sh to render the README laptop GIF")
        }
        Localizer.testLanguage = .en
        Laptop.scale = 2
        defer { Localizer.testLanguage = .ru; Laptop.scale = 1 }
        let (target, pass) = try effectTarget(width: 1600, height: 1000)
        let labelFade = 0.4
        let framesPerStyle = Int((Self.cycleDuration * fps).rounded())
        var frames: [CGImage] = []
        var picks: [Int] = []
        for style in FoldStyle.allCases {
            let preferences = Preferences().applying(style)
            let renderer = FoldRenderer { RenderParameters(progress: 0, preferences: preferences, overlay: false, reducedMotion: false) }
            for index in 0..<framesPerStyle {
                let time = Double(index) / fps
                let angle = Self.lidAngle(at: time)
                let image = try screen(renderer, preferences, angle: angle, target: target, pass: pass)
                frames.append(try Laptop.frame(screen: image, angle: angle, style: style, labelTransition: Self.ease(min(1, time / labelFade))))
                if style == .silk, [0, Int((Self.hold + Self.closing * 0.5) * fps), Int((Self.hold + Self.closing * 0.66) * fps),
                                    Int((Self.hold + Self.closing * 0.82) * fps)].contains(index) {
                    picks.append(frames.count - 1)
                }
            }
        }
        try writeGIF(frames, to: URL(fileURLWithPath: output), sheetPicks: picks)
    }

    /// One looping animation per style: the laptop closes and opens with that style on its screen.
    @MainActor func testRenderLaptopStyleGIFs() throws {
        guard let directory = ProcessInfo.processInfo.environment["DUOBUTTERFLY_STYLE_GIF_DIR"] else {
            throw XCTSkip("Run scripts/readme-gif.sh to render the per-style laptop GIFs")
        }
        Localizer.testLanguage = .en
        Laptop.scale = 2
        defer { Localizer.testLanguage = .ru; Laptop.scale = 1 }
        let (target, pass) = try effectTarget(width: 1600, height: 1000)
        let count = Int((Self.cycleDuration * fps).rounded())
        let picks = [0, Int((Self.hold + Self.closing * 0.5) * fps), Int((Self.hold + Self.closing * 0.66) * fps), Int((Self.hold + Self.closing * 0.9) * fps)]
        for style in FoldStyle.allCases {
            let preferences = Preferences().applying(style)
            let renderer = FoldRenderer { RenderParameters(progress: 0, preferences: preferences, overlay: false, reducedMotion: false) }
            var frames: [CGImage] = []
            for index in 0..<count {
                let angle = Self.lidAngle(at: Double(index) / fps)
                let image = try screen(renderer, preferences, angle: angle, target: target, pass: pass)
                frames.append(try Laptop.frame(screen: image, angle: angle, style: style, labelTransition: 1))
            }
            let url = URL(fileURLWithPath: directory).appendingPathComponent("laptop-\(style.rawValue == "shade" ? "dusk" : style.rawValue == "frost" ? "mist" : "silk").gif")
            try writeGIF(frames, to: url, sheetPicks: picks)
        }
    }

    /// Writes a looping GIF and a 2×2 contact sheet of the picked frames next to it.
    private func writeGIF(_ frames: [CGImage], to url: URL, sheetPicks picks: [Int]) throws {
        let destination = try XCTUnwrap(CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, frames.count, nil))
        CGImageDestinationSetProperties(destination, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary)
        let frameProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1 / fps]] as CFDictionary
        for frame in frames { CGImageDestinationAddImage(destination, frame, frameProperties) }
        XCTAssertTrue(CGImageDestinationFinalize(destination))

        let cellWidth = frames[0].width, cellHeight = frames[0].height
        let sheetContext = try XCTUnwrap(CGContext(data: nil, width: cellWidth * 2, height: cellHeight * 2, bitsPerComponent: 8,
            bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        for (slot, pick) in picks.prefix(4).enumerated() {
            let x = slot % 2, y = 1 - slot / 2
            sheetContext.draw(frames[pick], in: CGRect(x: x * cellWidth, y: y * cellHeight, width: cellWidth, height: cellHeight))
        }
        let sheet = url.deletingPathExtension().appendingPathExtension("sheet.png")
        try XCTUnwrap(NSBitmapImageRep(cgImage: try XCTUnwrap(sheetContext.makeImage())).representation(using: .png, properties: [:])).write(to: sheet)
        print("GIF: \(url.path), frames: \(frames.count), sheet: \(sheet.path)")
    }

    private func image(from texture: MTLTexture) throws -> CGImage {
        let width = texture.width, height = texture.height
        var bytes = [UInt8](repeating: 0, count: width * height * 4)
        bytes.withUnsafeMutableBytes {
            texture.getBytes($0.baseAddress!, bytesPerRow: width * 4, from: MTLRegionMake2D(0, 0, width, height), mipmapLevel: 0)
        }
        let provider = try XCTUnwrap(CGDataProvider(data: Data(bytes) as CFData))
        return try XCTUnwrap(CGImage(width: width, height: height, bitsPerComponent: 8, bitsPerPixel: 32,
            bytesPerRow: width * 4, space: CGColorSpace(name: CGColorSpace.sRGB)!,
            bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue).union(.byteOrder32Little),
            provider: provider, decode: nil, shouldInterpolate: true, intent: .defaultIntent))
    }

    /// Frame on a dark card: the screen in a black bezel, style name, lid angle and a progress bar.
    private func compose(_ frame: CGImage, style: FoldStyle, angle: Double, progress: Double) throws -> CGImage {
        let context = try XCTUnwrap(CGContext(data: nil, width: canvasWidth, height: canvasHeight, bitsPerComponent: 8,
            bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue))
        context.setFillColor(CGColor(red: 0.051, green: 0.067, blue: 0.09, alpha: 1))
        context.fill(CGRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight))
        let screen = CGRect(x: 20, y: 70, width: width, height: height)
        context.setFillColor(CGColor(gray: 0, alpha: 1))
        context.addPath(CGPath(roundedRect: screen.insetBy(dx: -8, dy: -8), cornerWidth: 18, cornerHeight: 18, transform: nil))
        context.fillPath()
        context.saveGState()
        context.addPath(CGPath(roundedRect: screen, cornerWidth: 11, cornerHeight: 11, transform: nil))
        context.clip()
        context.interpolationQuality = .high
        context.draw(frame, in: screen)
        context.restoreGState()

        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
        let title = NSAttributedString(string: "\(style.title) · \(style.subtitle)", attributes: [
            .font: NSFont.systemFont(ofSize: 20, weight: .semibold), .foregroundColor: NSColor.white])
        title.draw(at: NSPoint(x: 22, y: 22))
        let angleText = NSAttributedString(string: "Lid \(Int(angle.rounded()))°", attributes: [
            .font: NSFont.monospacedDigitSystemFont(ofSize: 18, weight: .medium), .foregroundColor: NSColor(white: 0.72, alpha: 1)])
        angleText.draw(at: NSPoint(x: CGFloat(canvasWidth) - 22 - angleText.size().width, y: 24))
        NSGraphicsContext.restoreGraphicsState()

        let track = CGRect(x: 20, y: 12, width: CGFloat(width), height: 3)
        context.setFillColor(CGColor(gray: 1, alpha: 0.12))
        context.fill(track)
        context.setFillColor(CGColor(red: 0.95, green: 0.35, blue: 0.62, alpha: 1))
        context.fill(CGRect(x: track.minX, y: track.minY, width: track.width * min(1, max(0, progress)), height: track.height))
        return try XCTUnwrap(context.makeImage())
    }
}

/// Perspective drawing of a generic aluminium laptop (no logos) with the effect frame mapped onto its screen.
/// Solids are drawn as extruded rounded rectangles: the convex hull of both outlines gives the side walls.
private enum Laptop {
    static let canvas = CGSize(width: 720, height: 540)
    // Apple dark chapter: absolute black canvas, white headline, #86868b secondary, #6e6e73 inactive (large text).
    static let ink = rgb(1, 1, 1), secondary = rgb(0.525, 0.525, 0.545), inactive = rgb(0.431, 0.431, 0.451)
    // World units: laptop width 1. The hinge runs along x at y = 0, z = 0; the base extends toward the camera (+z).
    static let depth = 0.70, lidHeight = 0.655, baseThickness = 0.02, lidThickness = 0.011, corner = 0.03
    // A distant camera with a long lens keeps the lid straight instead of flaring toward the viewer.
    static let eye = SIMD3<Double>(0, 1.55, 4.6), look = SIMD3<Double>(0, 0.24, 0.28)
    static let focal = 1480.0, center = CGPoint(x: 360, y: 228)
    static let space = CGColorSpace(name: CGColorSpace.sRGB)!
    /// Pixels per design point for rendered frames.
    nonisolated(unsafe) static var scale: CGFloat = 1

    typealias Plane = (Double, Double) -> SIMD3<Double>

    static func project(_ p: SIMD3<Double>) -> CGPoint {
        let forward = simd_normalize(look - eye)
        let right = simd_normalize(simd_cross(forward, SIMD3(0, 1, 0)))
        let up = simd_cross(right, forward)
        let relative = p - eye
        let z = simd_dot(relative, forward)
        return CGPoint(x: center.x + focal * simd_dot(relative, right) / z, y: center.y + focal * simd_dot(relative, up) / z)
    }

    /// Rounded rectangle in a plane's (u, v) coordinates, projected to the canvas.
    static func outline(_ plane: Plane, _ u0: Double, _ u1: Double, _ v0: Double, _ v1: Double, radius: Double, segments: Int = 7) -> [CGPoint] {
        let r = min(radius, (u1 - u0) / 2, (v1 - v0) / 2)
        let corners: [(Double, Double, Double)] = [(u1 - r, v1 - r, 0), (u0 + r, v1 - r, 90), (u0 + r, v0 + r, 180), (u1 - r, v0 + r, 270)]
        var points: [CGPoint] = []
        for (cu, cv, start) in corners {
            for step in 0...segments {
                let angle = (start + 90 * Double(step) / Double(segments)) * .pi / 180
                points.append(project(plane(cu + r * cos(angle), cv + r * sin(angle))))
            }
        }
        return points
    }

    static func path(_ points: [CGPoint]) -> CGPath {
        let path = CGMutablePath()
        path.addLines(between: points)
        path.closeSubpath()
        return path
    }

    /// Andrew's monotone chain; used for the silhouette of an extruded shape.
    static func hull(_ input: [CGPoint]) -> [CGPoint] {
        let points = input.sorted { $0.x == $1.x ? $0.y < $1.y : $0.x < $1.x }
        func cross(_ o: CGPoint, _ a: CGPoint, _ b: CGPoint) -> CGFloat { (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x) }
        var lower: [CGPoint] = [], upper: [CGPoint] = []
        for p in points {
            while lower.count >= 2 && cross(lower[lower.count - 2], lower[lower.count - 1], p) <= 0 { lower.removeLast() }
            lower.append(p)
        }
        for p in points.reversed() {
            while upper.count >= 2 && cross(upper[upper.count - 2], upper[upper.count - 1], p) <= 0 { upper.removeLast() }
            upper.append(p)
        }
        return Array(lower.dropLast() + upper.dropLast())
    }

    static func rgb(_ r: Double, _ g: Double, _ b: Double, _ a: Double = 1) -> CGColor { CGColor(red: r, green: g, blue: b, alpha: a) }

    static func fill(_ context: CGContext, _ shape: CGPath, from start: CGPoint? = nil, to end: CGPoint? = nil, colors: [CGColor], locations: [CGFloat]? = nil) {
        context.saveGState()
        context.addPath(shape)
        context.clip()
        let box = shape.boundingBox
        let gradient = CGGradient(colorsSpace: space, colors: colors as CFArray, locations: locations)!
        context.drawLinearGradient(gradient, start: start ?? CGPoint(x: box.midX, y: box.maxY), end: end ?? CGPoint(x: box.midX, y: box.minY),
                                   options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        context.restoreGState()
    }

    static func smoothstep(_ edge0: Double, _ edge1: Double, _ x: Double) -> Double {
        let t = min(1, max(0, (x - edge0) / (edge1 - edge0)))
        return t * t * (3 - 2 * t)
    }

    /// Average colour of the current screen frame; drives the light the display spills onto the body.
    static func averageColor(of image: CGImage) -> SIMD3<Double> {
        var pixel = [UInt8](repeating: 0, count: 4)
        guard let context = CGContext(data: &pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: space,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return SIMD3(0, 0, 0) }
        context.interpolationQuality = .medium
        context.draw(image, in: CGRect(x: 0, y: 0, width: 1, height: 1))
        return SIMD3(Double(pixel[0]), Double(pixel[1]), Double(pixel[2])) / 255
    }

    /// Bead-blasted aluminium: fine neutral grain with faint horizontal brushing, generated once at 3× the canvas.
    nonisolated(unsafe) static var brushedTexture: CGImage? = {
        let w = Int(canvas.width) * 3, h = Int(canvas.height) * 3
        guard let context = CGContext(data: nil, width: w, height: h, bitsPerComponent: 8, bytesPerRow: 0, space: space,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        var seed: UInt64 = 0x9E3779B97F4A7C15
        func next() -> Double { seed = seed &* 6364136223846793005 &+ 1442695040888963407; return Double(seed >> 33) / Double(1 << 31) }
        for _ in 0..<60_000 {
            context.setFillColor(gray: next() > 0.5 ? 1 : 0, alpha: 0.10 + next() * 0.22)
            context.fill(CGRect(x: next() * Double(w), y: next() * Double(h), width: 1.1, height: 1.1))
        }
        for _ in 0..<2400 {
            let length = 120 + next() * 700
            context.setFillColor(gray: next() > 0.5 ? 1 : 0, alpha: 0.05 + next() * 0.08)
            context.fill(CGRect(x: next() * Double(w) - length / 2, y: next() * Double(h), width: length, height: 0.9))
        }
        return context.makeImage()
    }()

    /// Overlays the aluminium texture inside `shape`.
    static func finish(_ context: CGContext, _ shape: CGPath, strength: CGFloat) {
        guard let texture = brushedTexture else { return }
        context.saveGState()
        context.addPath(shape)
        context.clip()
        context.setBlendMode(.overlay)
        context.setAlpha(strength)
        context.draw(texture, in: CGRect(origin: .zero, size: canvas))
        context.restoreGState()
    }

    /// Soft elliptical highlight, like a studio softbox reflected in satin metal.
    static func sheen(_ context: CGContext, _ shape: CGPath, center: CGPoint, radius: CGFloat, squash: CGFloat, alpha: Double) {
        context.saveGState()
        context.addPath(shape)
        context.clip()
        context.translateBy(x: center.x, y: center.y)
        context.scaleBy(x: 1, y: squash)
        let gradient = CGGradient(colorsSpace: space, colors: [rgb(1, 1, 1, alpha), rgb(1, 1, 1, alpha * 0.35), rgb(1, 1, 1, 0)] as CFArray,
                                  locations: [0, 0.45, 1])!
        context.drawRadialGradient(gradient, startCenter: .zero, startRadius: 0, endCenter: .zero, endRadius: radius, options: [])
        context.restoreGState()
    }

    /// Darkens the left and right ends of a surface, the way curved metal falls off from the light.
    static func falloff(_ context: CGContext, _ shape: CGPath, alpha: Double) {
        let box = shape.boundingBox
        fill(context, shape, from: CGPoint(x: box.minX, y: box.midY), to: CGPoint(x: box.maxX, y: box.midY),
             colors: [rgb(0, 0, 0, alpha), rgb(0, 0, 0, 0), rgb(0, 0, 0, 0), rgb(0, 0, 0, alpha)], locations: [0, 0.2, 0.8, 1])
    }

    static func stroke(_ context: CGContext, _ shape: CGPath, _ color: CGColor, width: CGFloat) {
        context.addPath(shape)
        context.setStrokeColor(color)
        context.setLineWidth(width)
        context.setLineJoin(.round)
        context.strokePath()
    }

    /// Bitmap context addressed in design points and backed by `scale`× pixels.
    static func makeContext(_ size: CGSize, scale: CGFloat) throws -> CGContext {
        guard let context = CGContext(data: nil, width: Int((size.width * scale).rounded()), height: Int((size.height * scale).rounded()),
                                      bitsPerComponent: 8, bytesPerRow: 0, space: space,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { throw CocoaError(.featureUnsupported) }
        context.scaleBy(x: scale, y: scale)
        context.interpolationQuality = .high
        return context
    }

    /// The product on its stage without typography. `studio` paints the black canvas and light.
    @MainActor static func stage(screen: CGImage, angle: Double, studio: Bool) throws -> CGImage {
        let bounds = CGRect(origin: .zero, size: canvas)
        let context = try makeContext(canvas, scale: scale)
        let sceneContext = try makeContext(canvas, scale: scale)
        drawLaptop(in: sceneContext, screen: screen, angle: angle)
        guard let scene = sceneContext.makeImage() else { throw CocoaError(.featureUnsupported) }

        if studio {
            // Black canvas with a soft studio light behind the product.
            context.setFillColor(rgb(0, 0, 0))
            context.fill(bounds)
            // Overhead softbox: a broad cone of light falling from the top of the frame.
            context.saveGState()
            context.translateBy(x: canvas.width / 2, y: canvas.height + 40)
            context.scaleBy(x: 1.35, y: 1)
            let cone = CGGradient(colorsSpace: space, colors: [rgb(0.25, 0.25, 0.27), rgb(0.10, 0.10, 0.11), rgb(0.02, 0.02, 0.025)] as CFArray,
                                  locations: [0, 0.45, 1])!
            context.drawRadialGradient(cone, startCenter: .zero, startRadius: 0, endCenter: .zero, endRadius: 520, options: [.drawsAfterEndLocation])
            context.restoreGState()
            // Light streak on the floor behind the laptop.
            let streak = project(SIMD3(0, -baseThickness, -0.06))
            context.saveGState()
            context.translateBy(x: streak.x, y: streak.y)
            context.scaleBy(x: 1, y: 0.035)
            let line = CGGradient(colorsSpace: space, colors: [rgb(0.62, 0.63, 0.66, 0.55), rgb(0.3, 0.3, 0.32, 0.18), rgb(0, 0, 0, 0)] as CFArray,
                                  locations: [0, 0.5, 1])!
            context.drawRadialGradient(line, startCenter: .zero, startRadius: 0, endCenter: .zero, endRadius: canvas.width * 0.52, options: [])
            context.restoreGState()
        }

        // Floor reflection: mirrored scene fading out below the base.
        let floorY = project(SIMD3(0, -baseThickness, depth)).y
        let reflection = try makeContext(canvas, scale: scale)
        reflection.saveGState()
        reflection.translateBy(x: 0, y: floorY * 2)
        reflection.scaleBy(x: 1, y: -1)
        reflection.draw(scene, in: bounds)
        reflection.restoreGState()
        reflection.setBlendMode(.destinationIn)
        let fade = CGGradient(colorsSpace: space, colors: [rgb(0, 0, 0, 0.15), rgb(0, 0, 0, 0)] as CFArray, locations: [0, 1])!
        reflection.drawLinearGradient(fade, start: CGPoint(x: 0, y: floorY), end: CGPoint(x: 0, y: floorY - 58), options: [.drawsAfterEndLocation])
        if let image = reflection.makeImage() { context.draw(image, in: bounds) }
        context.draw(scene, in: bounds)
        guard let image = context.makeImage() else { throw CocoaError(.featureUnsupported) }
        return image
    }

    @MainActor static func frame(screen: CGImage, angle: Double, style: FoldStyle, labelTransition: Double) throws -> CGImage {
        let context = try makeContext(canvas, scale: scale)
        context.draw(try stage(screen: screen, angle: angle, studio: true), in: CGRect(origin: .zero, size: canvas))

        // Typography: bold headline with a white-to-silver fill, grey subhead, style switcher with a sliding underline.
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.current = NSGraphicsContext(cgContext: context, flipped: false)
        let headline = NSAttributedString(string: "Close the lid.", attributes: [
            .font: NSFont.systemFont(ofSize: 50, weight: .bold), .foregroundColor: NSColor.white, .kern: -1.4])
        let headlineSize = headline.size()
        let headlineOrigin = NSPoint(x: (canvas.width - headlineSize.width) / 2, y: 452)
        context.beginTransparencyLayer(auxiliaryInfo: nil)
        headline.draw(at: headlineOrigin)
        context.setBlendMode(.sourceAtop)
        let silver = CGGradient(colorsSpace: space, colors: [rgb(1, 1, 1), rgb(0.86, 0.86, 0.88), rgb(0.70, 0.70, 0.73)] as CFArray,
                                locations: [0, 0.55, 1])!
        context.drawLinearGradient(silver, start: CGPoint(x: headlineOrigin.x, y: headlineOrigin.y + headlineSize.height),
                                   end: CGPoint(x: headlineOrigin.x, y: headlineOrigin.y), options: [])
        context.endTransparencyLayer()
        let subhead = NSAttributedString(string: "The desktop bends, blurs, and darkens.", attributes: [
            .font: NSFont.systemFont(ofSize: 20, weight: .regular), .foregroundColor: NSColor(srgbRed: 0.63, green: 0.63, blue: 0.66, alpha: 1), .kern: -0.1])
        subhead.draw(at: NSPoint(x: (canvas.width - subhead.size().width) / 2, y: 422))

        let styles = FoldStyle.allCases
        let current = styles.firstIndex(of: style) ?? 0
        let previous = (current + styles.count - 1) % styles.count
        let spacing: CGFloat = 76
        let labelFont = NSFont.systemFont(ofSize: 16, weight: .semibold)
        func centerX(_ index: Int) -> CGFloat { canvas.width / 2 + CGFloat(index - 1) * spacing }
        var widths: [CGFloat] = []
        for (index, item) in styles.enumerated() {
            let emphasis = index == current ? labelTransition : (index == previous ? 1 - labelTransition : 0)
            let value = 0.557 + (1 - 0.557) * emphasis
            let label = NSAttributedString(string: item.title, attributes: [
                .font: labelFont, .kern: -0.2, .foregroundColor: NSColor(srgbRed: value, green: value, blue: min(1, value + 0.02), alpha: 1)])
            let width = label.size().width
            widths.append(width)
            label.draw(at: NSPoint(x: centerX(index) - width / 2, y: 30))
        }
        NSGraphicsContext.restoreGraphicsState()
        // The underline slides from the previous style to the current one.
        let t = CGFloat(labelTransition)
        let underlineX = centerX(previous) + (centerX(current) - centerX(previous)) * t
        let underlineWidth = (widths[previous] + (widths[current] - widths[previous]) * t) + 8
        context.addPath(CGPath(roundedRect: CGRect(x: underlineX - underlineWidth / 2, y: 20, width: underlineWidth, height: 2.4),
                               cornerWidth: 1.2, cornerHeight: 1.2, transform: nil))
        context.setFillColor(rgb(1, 1, 1))
        context.fillPath()
        guard let image = context.makeImage() else { throw CocoaError(.featureUnsupported) }
        return image
    }

    static func drawLaptop(in context: CGContext, screen: CGImage, angle: Double) {
        context.setShouldAntialias(true)
        let a = angle * .pi / 180
        let screenColor = averageColor(of: screen)
        // Display light reaching the body: strongest with the lid open, gone as it shuts.
        let spill = smoothstep(8, 70, angle) * min(1, 0.35 + simd_reduce_max(screenColor))
        // macOS turns the keyboard backlight off as the lid closes.
        let backlight = smoothstep(28, 60, angle)
        let top: Plane = { u, v in SIMD3(u, 0, v) }
        let bottom: Plane = { u, v in SIMD3(u * 0.985, -baseThickness, 0.006 + v * 0.983) }
        let deck = outline(top, -0.5, 0.5, 0, depth, radius: corner)

        // Contact shadow on the floor.
        let left = project(SIMD3(-0.5, -baseThickness, depth * 0.55)), right = project(SIMD3(0.5, -baseThickness, depth * 0.55))
        context.saveGState()
        context.translateBy(x: (left.x + right.x) / 2, y: left.y - 4)
        context.scaleBy(x: 1, y: 0.08)
        let shadow = CGGradient(colorsSpace: space, colors: [rgb(0, 0, 0, 0.9), rgb(0, 0, 0, 0)] as CFArray, locations: [0, 1])!
        context.drawRadialGradient(shadow, startCenter: .zero, startRadius: 0, endCenter: .zero, endRadius: (right.x - left.x) * 0.6, options: [])
        context.restoreGState()

        // Base slab: side walls, deck, chamfer highlight.
        let baseSilhouette = path(hull(deck + outline(bottom, -0.5, 0.5, 0, depth, radius: corner)))
        fill(context, baseSilhouette, colors: [rgb(0.80, 0.805, 0.81), rgb(0.62, 0.625, 0.635), rgb(0.40, 0.405, 0.415)], locations: [0, 0.35, 1])
        falloff(context, baseSilhouette, alpha: 0.22)
        finish(context, baseSilhouette, strength: 0.16)
        let deckPath = path(deck)
        // Warm silver: darker toward the hinge, brightest where the deck faces the light.
        fill(context, deckPath, from: project(SIMD3(0, 0, 0)), to: project(SIMD3(0, 0, depth)),
             colors: [rgb(0.54, 0.545, 0.555), rgb(0.72, 0.725, 0.732), rgb(0.82, 0.824, 0.83), rgb(0.74, 0.745, 0.752)],
             locations: [0, 0.35, 0.72, 1])
        falloff(context, deckPath, alpha: 0.14)
        let deckLeft = project(SIMD3(-0.5, 0, depth * 0.7)), deckRight = project(SIMD3(0.5, 0, depth * 0.7))
        sheen(context, deckPath, center: project(SIMD3(-0.08, 0, depth * 0.74)), radius: (deckRight.x - deckLeft.x) * 0.5, squash: 0.2, alpha: 0.20)
        finish(context, deckPath, strength: 0.22)
        // Diamond-cut chamfer: a bright edge with a darker line just inside it.
        stroke(context, deckPath, rgb(1, 1, 1, 0.85), width: 1.2)
        stroke(context, path(outline(top, -0.496, 0.496, 0.004, depth - 0.004, radius: corner - 0.004)), rgb(0.42, 0.43, 0.45, 0.35), width: 0.7)
        // Thumb notch on the front edge.
        let notch = path([project(SIMD3(-0.065, 0, depth)), project(SIMD3(0.065, 0, depth)),
                          project(SIMD3(0.05, -baseThickness * 0.55, depth + 0.001)), project(SIMD3(-0.05, -baseThickness * 0.55, depth + 0.001))])
        fill(context, notch, colors: [rgb(0.30, 0.31, 0.34), rgb(0.44, 0.45, 0.49)])

        // Hinge shadow cast by an open lid.
        if angle > 20 {
            let band = path([project(SIMD3(-0.49, 0, 0.004)), project(SIMD3(0.49, 0, 0.004)), project(SIMD3(0.49, 0, 0.07)), project(SIMD3(-0.49, 0, 0.07))])
            fill(context, band, from: project(SIMD3(0, 0, 0.004)), to: project(SIMD3(0, 0, 0.07)), colors: [rgb(0, 0, 0, 0.35), rgb(0, 0, 0, 0)])
        }

        // Speaker grilles.
        context.setFillColor(rgb(0.18, 0.19, 0.21, 0.8))
        for side in [-1.0, 1.0] {
            for column in 0..<4 {
                for row in 0..<24 {
                    let u = side * (0.445 + Double(column) * 0.011), v = depth * (0.08 + 0.4 * Double(row) / 23)
                    let p = project(SIMD3(u, 0.0005, v))
                    context.fill(CGRect(x: p.x - 0.45, y: p.y - 0.3, width: 0.9, height: 0.6))
                }
            }
        }

        // Keyboard well and keys laid out like a MacBook keyboard.
        let key: Plane = { u, v in SIMD3(u, 0.0012, v) }
        let well = path(outline(top, -0.415, 0.415, depth * 0.062, depth * 0.515, radius: 0.012))
        context.saveGState()
        context.setShadow(offset: CGSize(width: 0, height: 0.6), blur: 3, color: rgb(0, 0, 0, 0.45))
        context.addPath(well)
        context.setFillColor(rgb(0.10, 0.105, 0.115))
        context.fillPath()
        context.restoreGState()
        fill(context, well, colors: [rgb(0.09, 0.093, 0.10), rgb(0.13, 0.133, 0.14)])
        stroke(context, well, rgb(1, 1, 1, 0.38), width: 0.8)
        let rows: [(height: Double, widths: [Double])] = [
            (0.62, Array(repeating: 1, count: 15)),
            (1, Array(repeating: 1, count: 13) + [2]),
            (1, [1.5] + Array(repeating: 1, count: 12) + [1.5]),
            (1, [1.8] + Array(repeating: 1, count: 11) + [2.2]),
            (1, [2.35] + Array(repeating: 1, count: 10) + [2.65]),
            (1, [1, 1, 1, 1.25, 5.5, 1.25, 1, 3]),
        ]
        let keyGap = 0.0055
        let rowUnits = rows.reduce(0) { $0 + $1.height }
        let v0 = depth * 0.075, v1 = depth * 0.502
        var cursor = v0
        for row in rows {
            let rowDepth = (v1 - v0) * row.height / rowUnits
            let total = row.widths.reduce(0, +)
            var u = -0.402
            for (index, units) in row.widths.enumerated() {
                let keyWidth = 0.804 * units / total
                if row.widths.count == 8 && index == 7 {
                    // Inverted-T arrow cluster.
                    let third = keyWidth / 3
                    for column in 0..<3 {
                        let ku = u + Double(column) * third
                        let lower = path(outline(key, ku + keyGap / 2, ku + third - keyGap / 2, cursor + rowDepth / 2 + keyGap / 4, cursor + rowDepth - keyGap / 2, radius: 0.003))
                        context.addPath(lower)
                    }
                    let upper = path(outline(key, u + third + keyGap / 2, u + 2 * third - keyGap / 2, cursor + keyGap / 2, cursor + rowDepth / 2 - keyGap / 4, radius: 0.003))
                    context.addPath(upper)
                } else {
                    context.addPath(path(outline(key, u + keyGap / 2, u + keyWidth - keyGap / 2, cursor + keyGap / 2, cursor + rowDepth - keyGap / 2, radius: 0.004)))
                }
                u += keyWidth
            }
            cursor += rowDepth
        }
        guard let keys = context.path?.copy() else { return }
        context.beginPath()
        if backlight > 0 {
            context.saveGState()
            context.addPath(keys)
            context.setStrokeColor(rgb(0.95, 0.96, 1.0, 0.22 * backlight))
            context.setLineWidth(1.6)
            context.setShadow(offset: .zero, blur: 3, color: rgb(0.85, 0.9, 1.0, 0.55 * backlight))
            context.strokePath()
            context.restoreGState()
        }
        context.addPath(keys)
        context.setFillColor(rgb(0.045, 0.047, 0.052))
        context.fillPath()
        context.saveGState()
        context.addPath(keys)
        context.clip()
        let wellTop = project(SIMD3(0, 0, depth * 0.06)), wellBottom = project(SIMD3(0, 0, depth * 0.52))
        let capLight = CGGradient(colorsSpace: space, colors: [rgb(1, 1, 1, 0.07), rgb(1, 1, 1, 0.015)] as CFArray, locations: [0, 1])!
        context.drawLinearGradient(capLight, start: wellTop, end: wellBottom, options: [])
        context.restoreGState()

        // Trackpad.
        let pad = path(outline(top, -0.235, 0.235, depth * 0.565, depth * 0.955, radius: 0.016))
        context.saveGState()
        context.setShadow(offset: CGSize(width: 0, height: 0.5), blur: 1.8, color: rgb(0, 0, 0, 0.22))
        fill(context, pad, colors: [rgb(0.79, 0.795, 0.80), rgb(0.87, 0.873, 0.877)])
        context.restoreGState()
        fill(context, pad, colors: [rgb(0.79, 0.795, 0.80), rgb(0.87, 0.873, 0.877)])
        sheen(context, pad, center: project(SIMD3(-0.05, 0, depth * 0.8)), radius: 90, squash: 0.35, alpha: 0.18)
        finish(context, pad, strength: 0.08)
        stroke(context, pad, rgb(0.48, 0.49, 0.51, 0.75), width: 0.8)
        stroke(context, path(outline(top, -0.232, 0.232, depth * 0.568, depth * 0.952, radius: 0.014)), rgb(1, 1, 1, 0.35), width: 0.6)

        if spill > 0.01 {
            context.saveGState()
            context.addPath(deckPath)
            context.clip()
            context.setBlendMode(.plusLighter)
            let origin = project(SIMD3(0, 0, 0.02)), reach = project(SIMD3(0, 0, depth))
            let tint = screenColor * 0.55 + SIMD3(0.12, 0.13, 0.16)
            let glow = CGGradient(colorsSpace: space, colors: [rgb(tint.x, tint.y, tint.z, 0.62 * spill), rgb(tint.x, tint.y, tint.z, 0)] as CFArray,
                                  locations: [0, 1])!
            context.translateBy(x: origin.x, y: origin.y)
            context.scaleBy(x: 1, y: 0.42)
            context.drawRadialGradient(glow, startCenter: .zero, startRadius: 0, endCenter: .zero,
                                       endRadius: abs(origin.y - reach.y) * 2.6, options: [])
            context.restoreGState()
        }

        // Hinge barrel along the back edge.
        let hinge = path(outline({ u, v in SIMD3(u, v, -0.004) }, -0.36, 0.36, -0.012, 0.01, radius: 0.01))
        fill(context, hinge, colors: [rgb(0.20, 0.21, 0.23), rgb(0.07, 0.07, 0.08)])

        // Lid slab: edge silhouette first, then the face turned toward the camera.
        let face: Plane = { u, v in SIMD3(u, 0.004 + v * sin(a), v * cos(a)) }
        let backOffset = SIMD3(0, cos(a), -sin(a)) * lidThickness
        let back: Plane = { u, v in face(u, v) + backOffset }
        let faceOutline = outline(face, -0.5, 0.5, 0, lidHeight, radius: corner)
        let backOutline = outline(back, -0.5, 0.5, 0, lidHeight, radius: corner)
        let lidSilhouette = path(hull(faceOutline + backOutline))
        fill(context, lidSilhouette, colors: [rgb(0.86, 0.865, 0.87), rgb(0.62, 0.625, 0.635), rgb(0.44, 0.445, 0.455)], locations: [0, 0.4, 1])
        falloff(context, lidSilhouette, alpha: 0.18)
        let normal = SIMD3(0, -cos(a), sin(a))
        if simd_dot(normal, eye - face(0, lidHeight / 2)) > 0 {
            let facePath = path(faceOutline)
            context.addPath(facePath)
            context.setFillColor(rgb(0.03, 0.03, 0.035))
            context.fillPath()
            stroke(context, facePath, rgb(0.80, 0.805, 0.81, 0.95), width: 1.5)
            let su0 = -0.478, su1 = 0.478, sv0 = 0.046, sv1 = lidHeight - 0.02
            // Core Image works in pixels, so corners are mapped at the output scale.
            func pixel(_ p: SIMD3<Double>) -> CIVector { let q = project(p); return CIVector(x: q.x * scale, y: q.y * scale) }
            let mapped = CIImage(cgImage: screen).applyingFilter("CIPerspectiveTransform", parameters: [
                "inputTopLeft": pixel(face(su0, sv1)), "inputTopRight": pixel(face(su1, sv1)),
                "inputBottomLeft": pixel(face(su0, sv0)), "inputBottomRight": pixel(face(su1, sv0))])
            let pixelBounds = CGRect(x: 0, y: 0, width: canvas.width * scale, height: canvas.height * scale)
            if let layer = CIContext(options: [.workingColorSpace: space]).createCGImage(mapped, from: pixelBounds) {
                let screenPath = path(outline(face, su0, su1, sv0, sv1, radius: 0.012))
                context.saveGState()
                context.addPath(screenPath)
                context.clip()
                context.draw(layer, in: CGRect(origin: .zero, size: canvas))
                let notch = path(outline(face, -0.042, 0.042, sv1 - 0.024, sv1 + 0.01, radius: 0.008))
                context.addPath(notch)
                context.setFillColor(rgb(0.02, 0.02, 0.025))
                context.fillPath()
                let sweep = CGFloat(0.25 + 0.5 * smoothstep(20, 116, angle))
                fill(context, screenPath, from: project(face(su0, sv1)), to: project(face(su1 * 0.4, sv0)),
                     colors: [rgb(1, 1, 1, 0.09), rgb(1, 1, 1, 0.015), rgb(1, 1, 1, 0.06), rgb(1, 1, 1, 0)],
                     locations: [0, max(0.05, sweep - 0.12), sweep, min(1, sweep + 0.1)])
                context.restoreGState()
            }
        } else {
            let backPath = path(backOutline)
            // The lid's back catches more light as it tilts toward the camera.
            let lift = 0.06 * smoothstep(0, 40, angle)
            fill(context, backPath, from: project(back(0, lidHeight)), to: project(back(0, 0)),
                 colors: [rgb(0.74 + lift, 0.745 + lift, 0.75 + lift), rgb(0.86 + lift, 0.863 + lift, 0.867 + lift), rgb(0.70, 0.705, 0.712)],
                 locations: [0, CGFloat(0.35 + 0.3 * smoothstep(0, 40, angle)), 1])
            falloff(context, backPath, alpha: 0.16)
            let lidLeft = project(back(-0.5, lidHeight / 2)), lidRight = project(back(0.5, lidHeight / 2))
            sheen(context, backPath, center: project(back(-0.1, lidHeight * 0.55)), radius: (lidRight.x - lidLeft.x) * 0.5, squash: 0.3, alpha: 0.26)
            finish(context, backPath, strength: 0.22)
            stroke(context, backPath, rgb(1, 1, 1, 0.8), width: 1.1)
        }

    }
}
