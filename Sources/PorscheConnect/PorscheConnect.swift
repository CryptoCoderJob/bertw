import Foundation

// MARK: - Enums

public enum Environment: String {
  case Ireland, Germany, Test
  
  public var countryCode: String {
    switch self {
    case .Ireland:
      return "ie/en_GB"
    case .Germany:
      return "de/de_DE"
    case .Test:
      return "ie/en_IE"
    }
  }
}

public enum Application {
  case Portal
  
  public var clientId: String {
    switch self {
    case .Portal:
      return "TZ4Vf5wnKeipJxvatJ60lPHYEzqZ4WNp"
    }
  }
  
  public var redirectURL: URL {
    switch self {
    case .Portal:
      return URL(string: "https://my-static02.porsche.com/static/cms/auth.html")!
    }
  }
}

public enum PorscheConnectError: Error {
  case AuthFailure
}

// MARK: - Structs

public struct NetworkRoutes {
  let environment: Environment
  
  var loginAuthURL: URL {
    switch environment {
    case .Ireland, .Germany:
      return URL(string: "https://login.porsche.com/auth/api/v1/\(environment.countryCode)/public/login")!
    case .Test:
      return URL(string: "http://localhost:\(kTestServerPort)/auth/api/v1/\(environment.countryCode)/public/login")!
    }
  }
  
  var apiAuthURL: URL {
    switch environment {
    case .Ireland, .Germany:
      return URL(string: "https://login.porsche.com/as/authorization.oauth2")!
    case .Test:
      return URL(string: "http://localhost:\(kTestServerPort)/as/authorization.oauth2")!
    }
  }
}

struct PorscheConnect {
  typealias Success = ((Any?, HTTPURLResponse?, ResponseJson?) -> Void)
  typealias Failure = ((Error, HTTPURLResponse?) -> Void)
  
  let environment: Environment
  let username: String
  private(set) var authorized: Bool
  
  private let networkClient = NetworkClient()
  private let networkRoutes: NetworkRoutes
  private let password: String
  
  // MARK: - Init & Configuration
  
  public init(environment: Environment, username: String, password: String) {
    self.environment = environment
    self.networkRoutes = NetworkRoutes(environment: environment)
    self.username = username
    self.password = password
    self.authorized = false
  }
  
  // MARK: - Auth
  
  public func auth(success: Success? = nil, failure: Failure? = nil) {
    let apiAuthComplention = { (code: String?, error: PorscheConnectError?, response: HTTPURLResponse?) -> Void in
      if let code = code {
        AuthLogger.debug("Auth: Code received: \(code)")
      }
      
      if let success = success {
        success(nil, response, nil)
      }
    }
    
    let loginToRetrieveCookiesCompletion = { (error: PorscheConnectError?, response: HTTPURLResponse?) -> Void in
      getApiAuthCode(completion: apiAuthComplention)
    }
    
    loginToRetrieveCookies(completion: loginToRetrieveCookiesCompletion)
  }
  
  
  private func loginToRetrieveCookies(completion: @escaping ((PorscheConnectError?, HTTPURLResponse?) -> Void)) {
    let loginBody = buildLoginBody(username: username, password: password)
    networkClient.post(String.self, url: networkRoutes.loginAuthURL, body: buildPostFormBodyFrom(dictionary: loginBody), contentType: .form) { (body, response, error, responseJson) in
      
      if error != nil {
        completion(PorscheConnectError.AuthFailure, response)
      } else {
        AuthLogger.info("Auth: Login to retrieve cookies successful")
        completion(nil, nil)
      }
    }
  }
  
  private func getApiAuthCode(completion: @escaping (String?, PorscheConnectError?, HTTPURLResponse?) -> Void) {
    let apiAuthParams = buildApiAuthParams(clientId: Application.Portal.clientId, redirectURL: Application.Portal.redirectURL)
    
    networkClient.get(String.self, url: networkRoutes.apiAuthURL, params: apiAuthParams) { (_, response, error, _) in
      
      if let code = URLComponents(string: response!.url?.absoluteString ?? kBlankString)?.queryItems?.first(where: {$0.name == "code"})?.value {
        AuthLogger.info("Auth: Api Auth call for code successful")
        completion(code, nil, response)
      } else {
        completion(nil, PorscheConnectError.AuthFailure, response)
      }
    }
  }
  
  private func buildLoginBody(username: String, password: String) -> Dictionary<String, String> {
    return ["username": username,
            "password": password,
            "keeploggedin": "false",
            "sec": "",
            "resume": "",
            "thirdPartyId": "",
            "state": ""]
  }
  
  private func buildApiAuthParams(clientId: String, redirectURL: URL) -> Dictionary<String, String> {
    let codeChallenger = CodeChallenger(length: 40)
    return ["client_id": clientId,
            "redirect_uri": redirectURL.absoluteString,
            "code_challenge": codeChallenger.codeChallenge(for: codeChallenger.generateCodeVerifier()!)!, //TODO: Handle null
            "scope": "openid",
            "response_type": "code",
            "access_type": "offline",
            "prompt": "none",
            "code_challenge_method": "S256"]
  }
  
//  private func handleResponse(body: Any?, response: HTTPURLResponse?, error: Error?, json: ResponseJson?, success: Success?, failure: Failure?) {
//    DispatchQueue.main.async {
//      if let failure = failure, let error = error {
//        failure(error, response)
//      } else if let success = success {
//        success(body, response, json)
//      }
//    }
//  }
  
}
