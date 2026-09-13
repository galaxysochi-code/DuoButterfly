import XCTest
@testable import DuoButterfly

final class DonationsTests: XCTestCase {
    private let sample = Data("""
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0"><array>
      <dict><key>id</key><string>btc</string><key>asset</key><string>Bitcoin</string>
        <key>network</key><string>BTC</string><key>logo</key><string>bitcoin</string>
        <key>address</key><string>bc1q-sample</string></dict>
      <dict><key>id</key><string>usdt-ton</string><key>asset</key><string>USDT</string>
        <key>network</key><string>TON</string><key>logo</key><string>tether</string><key>badge</key><string>ton</string>
        <key>address</key><string>UQ-sample</string></dict>
      <dict><key>id</key><string>usdc-erc20</string><key>asset</key><string>USDC</string>
        <key>network</key><string>ERC-20</string><key>logo</key><string>usdc</string><key>badge</key><string>ethereum</string>
        <key>address</key><string>0x-sample</string></dict>
      <dict><key>id</key><string>empty</string><key>asset</key><string>Solana</string>
        <key>network</key><string>SOL</string><key>logo</key><string>solana</string>
        <key>address</key><string> </string></dict>
    </array></plist>
    """.utf8)

    func testWalletListDecodesAndSkipsEmptyAddresses() throws {
        let wallets = try Donations.decode(sample)
        XCTAssertEqual(wallets.map(\.id), ["btc", "usdt-ton", "usdc-erc20"])
        XCTAssertEqual(wallets[1].badge, .ton)
        XCTAssertEqual(wallets.map(\.paymentURI), ["bitcoin:bc1q-sample", "ton://transfer/UQ-sample", "ethereum:0x-sample"])
    }

    func testMissingWalletFileHidesDonations() {
        XCTAssertTrue(Donations.load(bundle: Bundle(for: DonationsTests.self)).isEmpty)
    }

    func testUSDCLogoIsBundled() {
        XCTAssertNotNil(Bundle.main.url(forResource: "usdc", withExtension: "svg"))
    }

    /// Checks the wallets bundled into this build, if any (release builds and local builds with Wallets.plist).
    @MainActor func testBundledWalletsAreUsable() throws {
        for wallet in Donations.load() {
            XCTAssertFalse(wallet.address.contains(" "), wallet.id)
            XCTAssertTrue(wallet.paymentURI.hasSuffix(wallet.address), wallet.id)
            XCTAssertNotNil(Donations.qrCode(for: wallet.paymentURI, size: 200), wallet.id)
        }
    }

    @MainActor func testBannerHiddenWithoutWalletsAndUntilTomorrow() throws {
        let saved = Donations.available
        defer { Donations.available = saved }
        let domain = "DuoButterflyThanks.\(UUID().uuidString)"
        let defaults = try XCTUnwrap(UserDefaults(suiteName: domain))
        defer { defaults.removePersistentDomain(forName: domain) }
        let model = AppModel(defaults: defaults)

        Donations.available = []
        XCTAssertFalse(model.showsThanksBanner, "No wallets, no donation banner")

        Donations.available = try Donations.decode(sample)
        XCTAssertTrue(model.showsThanksBanner)
        model.hideThanksBanner()
        XCTAssertFalse(model.showsThanksBanner)
        XCTAssertFalse(AppModel(defaults: defaults).showsThanksBanner)
        let calendar = Calendar.current
        let hiddenUntil = try XCTUnwrap(model.thanksBannerHiddenUntil)
        XCTAssertEqual(hiddenUntil, calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: Date())))
        // Dismissing late in the evening still brings the banner back the next morning.
        let evening = try XCTUnwrap(calendar.date(bySettingHour: 23, minute: 50, second: 0, of: Date()))
        model.hideThanksBanner(now: evening)
        XCTAssertLessThanOrEqual(try XCTUnwrap(model.thanksBannerHiddenUntil).timeIntervalSince(evening), 10 * 60 + 1)
        model.thanksBannerHiddenUntil = Date(timeIntervalSinceNow: -1)
        XCTAssertTrue(model.showsThanksBanner, "The banner must reappear once the day is over")
    }
}
