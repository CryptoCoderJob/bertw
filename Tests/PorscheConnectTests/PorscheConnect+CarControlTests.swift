import XCTest
@testable import PorscheConnect

final class PorscheConnectCarControlTests: BaseMockNetworkTestCase {
  
  // MARK: - Properties
  
  var connect: PorscheConnect!
  let mockNetworkRoutes = MockNetworkRoutes()
  let application: Application = .CarControl
  let vehicle = Vehicle(vin: "A1234")
  // MARK: - Lifecycle
  
  override func setUp() {
    super.setUp()
    self.connect = PorscheConnect(username: "homer.simpson@icloud.example", password: "Duh!", environment: .Test)
    self.connect.auths[application] = kTestPorschePortalAuth
  }

  // MARK: - Summary Tests
  
  func testSummaryAuthRequiredSuccessful() {
    connect.auths[application] = nil
    let expectation = self.expectation(description: "Network Expectation")
    
    mockNetworkRoutes.mockPostLoginAuthSuccessful(router: MockServer.shared.router)
    mockNetworkRoutes.mockGetApiAuthSuccessful(router: MockServer.shared.router)
    mockNetworkRoutes.mockPostApiTokenSuccessful(router: MockServer.shared.router)
    
    mockNetworkRoutes.mockGetSummarySuccessful(router: MockServer.shared.router)
    
    XCTAssertFalse(self.connect.authorized(application: application))
    
    connect.summary(vehicle: vehicle) { result in
      expectation.fulfill()
      XCTAssert(self.connect.authorized(application: self.application))
      
      switch result {
      case .success(let (summary, response)):
        XCTAssertNotNil(response)
        XCTAssertNotNil(summary)
        self.assertSummary(summary!)
      case .failure:
        XCTFail("Should not have reached here")
      }
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
  
  func testSummaryNoAuthRequiredSuccessful() {
    let expectation = self.expectation(description: "Network Expectation")
    mockNetworkRoutes.mockGetSummarySuccessful(router: MockServer.shared.router)
    
    XCTAssert(connect.authorized(application: application))

    connect.summary(vehicle: vehicle) { result in
      expectation.fulfill()
      XCTAssert(self.connect.authorized(application: self.application))
      
      switch result {
      case .success(let (summary, response)):
        XCTAssertNotNil(response)
        XCTAssertNotNil(summary)
        self.assertSummary(summary!)
      case .failure:
        XCTFail("Should not have reached here")
      }
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
  
  func testSummaryNoAuthRequiredFailure() {
    let expectation = self.expectation(description: "Network Expectation")
    mockNetworkRoutes.mockGetSummaryFailure(router: MockServer.shared.router)
    
    XCTAssert(connect.authorized(application: application))
    
    connect.summary(vehicle: vehicle) { result in
      expectation.fulfill()
      XCTAssert(self.connect.authorized(application: self.application))
      
      switch result {
      case .success:
        XCTFail("Should not have reached here")
      case .failure(let error):
        XCTAssertEqual(HttpStatusCode.BadRequest, error as! HttpStatusCode)
      }
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }

  func testSummaryAuthRequiredAuthFailure() {
    connect.auths[application] = nil
    let expectation = self.expectation(description: "Network Expectation")
    
    mockNetworkRoutes.mockPostLoginAuthFailure(router: MockServer.shared.router)

    XCTAssertFalse(connect.authorized(application: application))
    
    connect.summary(vehicle: vehicle) { result in
      expectation.fulfill()
      XCTAssertFalse(self.connect.authorized(application: self.application))
      
      switch result {
      case .success:
        XCTFail("Should not have reached here")
      case .failure(let error):
        XCTAssertEqual(PorscheConnectError.AuthFailure, error as! PorscheConnectError)
      }
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
  
  // MARK: - Position Tests
  
  func testPositionAuthRequiredSuccessful() {
    connect.auths[application] = nil
    let expectation = self.expectation(description: "Network Expectation")
    
    mockNetworkRoutes.mockPostLoginAuthSuccessful(router: MockServer.shared.router)
    mockNetworkRoutes.mockGetApiAuthSuccessful(router: MockServer.shared.router)
    mockNetworkRoutes.mockPostApiTokenSuccessful(router: MockServer.shared.router)
    
    mockNetworkRoutes.mockGetPositionSuccessful(router: MockServer.shared.router)

    XCTAssertFalse(self.connect.authorized(application: application))
    
    connect.position(vehicle: vehicle) { result in
      expectation.fulfill()
      XCTAssert(self.connect.authorized(application: self.application))
      
      switch result {
      case .success(let (position, response)):
        XCTAssertNotNil(response)
        XCTAssertNotNil(position)
        self.assertPosition(position!)
      case .failure:
        XCTFail("Should not have reached here")
      }
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
  
  func testPositionNoAuthRequiredSuccessful() {
    let expectation = self.expectation(description: "Network Expectation")
    mockNetworkRoutes.mockGetPositionSuccessful(router: MockServer.shared.router)
    
    XCTAssert(connect.authorized(application: application))

    connect.position(vehicle: vehicle) { result in
      expectation.fulfill()
      XCTAssert(self.connect.authorized(application: self.application))
      
      switch result {
      case .success(let (position, response)):
        XCTAssertNotNil(response)
        XCTAssertNotNil(position)
        self.assertPosition(position!)
      case .failure:
        XCTFail("Should not have reached here")
      }
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
  
  func testPositionNoAuthRequiredFailure() {
    let expectation = self.expectation(description: "Network Expectation")
    mockNetworkRoutes.mockGetPositionFailure(router: MockServer.shared.router)
    
    XCTAssert(connect.authorized(application: application))
    
    connect.position(vehicle: vehicle) { result in
      expectation.fulfill()
      XCTAssert(self.connect.authorized(application: self.application))
      
      switch result {
      case .success:
        XCTFail("Should not have reached here")
      case .failure(let error):
        XCTAssertEqual(HttpStatusCode.BadRequest, error as! HttpStatusCode)
      }
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
  
  func testPositionAuthRequiredAuthFailure() {
    connect.auths[application] = nil
    let expectation = self.expectation(description: "Network Expectation")
    
    mockNetworkRoutes.mockPostLoginAuthFailure(router: MockServer.shared.router)

    XCTAssertFalse(connect.authorized(application: application))
    
    connect.position(vehicle: vehicle) { result in
      expectation.fulfill()
      XCTAssertFalse(self.connect.authorized(application: self.application))
      
      switch result {
      case .success:
        XCTFail("Should not have reached here")
      case .failure(let error):
        XCTAssertEqual(PorscheConnectError.AuthFailure, error as! PorscheConnectError)
      }
    }
    
    waitForExpectations(timeout: kDefaultTestTimeout, handler: nil)
  }
  
  // MARK: - Private functions
  
  private func assertSummary(_ summary: Summary) {
    XCTAssertEqual("Taycan 4S", summary.modelDescription)
    XCTAssertEqual("211-D-12345", summary.nickName)
  }
  
  private func assertPosition(_ position: Position) {
    XCTAssertEqual(68, position.heading)
    let carCoordinate = position.carCoordinate
    
    XCTAssertEqual("WGS84", carCoordinate.geoCoordinateSystem)
    XCTAssertEqual(53.395367, carCoordinate.latitude)
    XCTAssertEqual(-6.389296, carCoordinate.longitude)
  }
}