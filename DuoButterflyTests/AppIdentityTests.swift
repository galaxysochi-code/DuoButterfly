import XCTest
@testable import DuoButterfly

final class AppIdentityTests: XCTestCase {
    func testAppIdentity() {
        let bundle = Bundle.main
        XCTAssertEqual(bundle.bundleIdentifier, "local.duobutterfly.DuoButterfly")
        XCTAssertEqual(bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String, "DUO Butterfly")
        XCTAssertNil(bundle.object(forInfoDictionaryKey: "SUFeedURL"))
    }
}
