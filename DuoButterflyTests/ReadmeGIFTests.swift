import XCTest
import Metal
import ImageIO
import UniformTypeIdentifiers
import AppKit
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

        let url = URL(fileURLWithPath: output)
        let destination = try XCTUnwrap(CGImageDestinationCreateWithURL(url as CFURL, UTType.gif.identifier as CFString, frames.count, nil))
        CGImageDestinationSetProperties(destination, [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFLoopCount: 0]] as CFDictionary)
        let frameProperties = [kCGImagePropertyGIFDictionary: [kCGImagePropertyGIFDelayTime: 1 / fps]] as CFDictionary
        for frame in frames { CGImageDestinationAddImage(destination, frame, frameProperties) }
        XCTAssertTrue(CGImageDestinationFinalize(destination))

        // Contact sheet with key frames for a quick visual check.
        let picks = [0, framesPerStyle / 2, framesPerStyle + framesPerStyle / 2, framesPerStyle * 2 + framesPerStyle / 2]
        let sheetContext = try XCTUnwrap(CGContext(data: nil, width: canvasWidth * 2, height: canvasHeight * 2, bitsPerComponent: 8,
            bytesPerRow: 0, space: CGColorSpace(name: CGColorSpace.sRGB)!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue))
        for (slot, pick) in picks.enumerated() {
            let x = slot % 2, y = 1 - slot / 2
            sheetContext.draw(frames[pick], in: CGRect(x: x * canvasWidth, y: y * canvasHeight, width: canvasWidth, height: canvasHeight))
        }
        let sheet = url.deletingPathExtension().appendingPathExtension("sheet.png")
        try XCTUnwrap(NSBitmapImageRep(cgImage: try XCTUnwrap(sheetContext.makeImage())).representation(using: .png, properties: [:])).write(to: sheet)
        print("GIF: \(url.path), frames: \(frames.count), sheet: \(sheet.path)")
    }

    private func image(from texture: MTLTexture) throws -> CGImage {
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
