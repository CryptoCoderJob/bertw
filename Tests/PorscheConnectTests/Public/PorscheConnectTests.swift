import XCTest
import func XCTAsync.XCTAssertFalse

@testable import PorscheConnect

final class PorscheConnectTests: BaseMockNetworkTestCase {

  // MARK: - Properties

  var connect: PorscheConnect!
  let mockNetworkRoutes = MockNetworkRoutes()

  // MARK: - Lifecycle

  override func setUp() {
    super.setUp()
    connect = PorscheConnect(
      username: "homer.simpson@icloud.example", password: "Duh!", environment: .test)
  }

  // MARK: - Tests

  func testConstruction() async {
    XCTAssertNotNil(connect)
    XCTAssertEqual(Environment.test, connect.environment)
    XCTAssertEqual("homer.simpson@icloud.example", connect.username)
    XCTAssertNotNil(connect.authStorage)
    await XCTAsync.XCTAssertFalse(await connect.authorized(application: .api))
  }

  func testEnvironmentGermany() {
    let environment = Environment.germany
    XCTAssertNotNil(environment)
    XCTAssertEqual(environment.regionCode, "de/de_DE")
    XCTAssertEqual(environment.languageCode, LanguageCode.german.rawValue)
    XCTAssertEqual(environment.countryCode, CountryCode.germany.rawValue)
  }

  func testEnvironmentCustom() {
    let environment = Environment(
      countryCode: CountryCode.unitedStates.rawValue,
      languageCode: LanguageCode.english.rawValue,
      regionCode: "us/en_US"
    )
    XCTAssertNotNil(environment)
    XCTAssertEqual(environment.regionCode, "us/en_US")
    XCTAssertEqual(environment.languageCode, LanguageCode.english.rawValue)
    XCTAssertEqual(environment.countryCode, CountryCode.unitedStates.rawValue)
  }

  func testEnvironmentTest() {
    let environment = Environment.test
    XCTAssertNotNil(environment)
    XCTAssertEqual(environment.regionCode, "ie/en_IE")
    XCTAssertEqual(environment.languageCode, LanguageCode.english.rawValue)
    XCTAssertEqual(environment.countryCode, CountryCode.ireland.rawValue)
  }

  func testApplicationClientIdApi() {
    let application = OAuthApplication.api
    XCTAssertEqual(application.clientId, "UYsK00My6bCqJdbQhTQ0PbWmcSdIAMig")
  }

  func testAuthLoggerIsDefined() {
    XCTAssertNotNil(AuthLogger)
  }
}
