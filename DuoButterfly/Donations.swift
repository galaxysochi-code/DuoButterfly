import AppKit
import CoreImage
import CoreImage.CIFilterBuiltins

struct DonationWallet: Identifiable, Hashable, Sendable, Decodable {
    let id: String
    let asset: String
    let network: String
    let logo: CoinLogo.Kind
    /// Small network mark for tokens that live on another chain (USDT on TON).
    let badge: CoinLogo.Kind?
    let address: String

    /// Payment link for the QR code: phone wallets open a prefilled transfer on the right network.
    var paymentURI: String {
        switch logo {
        case .bitcoin: "bitcoin:\(address)"
        case .ethereum, .usdc: "ethereum:\(address)"
        case .ton, .gram, .tether: network == "TON" ? "ton://transfer/\(address)" : address
        case .solana: "solana:\(address)"
        }
    }
}

enum Donations {
    /// Wallet addresses are not part of the public source code. Release builds bundle `Wallets.plist`,
    /// written from the `DONATION_WALLETS_PLIST` repository secret. Without it the donation UI stays hidden.
    nonisolated(unsafe) static var available: [DonationWallet] = load()

    static func load(bundle: Bundle = .main) -> [DonationWallet] {
        guard let url = bundle.url(forResource: "Wallets", withExtension: "plist"),
              let data = try? Data(contentsOf: url) else { return [] }
        return (try? decode(data)) ?? []
    }

    static func decode(_ data: Data) throws -> [DonationWallet] {
        try PropertyListDecoder().decode([DonationWallet].self, from: data)
            .filter { !$0.address.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    /// QR code rendered locally with Core Image.
    @MainActor static func qrCode(for text: String, size: CGFloat) -> NSImage? {
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(text.utf8)
        filter.correctionLevel = "M"
        guard let output = filter.outputImage else { return nil }
        let scale = (size / output.extent.width).rounded(.down)
        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        guard let cgImage = CIContext().createCGImage(scaled, from: scaled.extent) else { return nil }
        return NSImage(cgImage: cgImage, size: NSSize(width: scaled.extent.width, height: scaled.extent.height))
    }
}
