//
//  HTTP.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 06/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation

enum HTTP {
  enum Method: String {
    case get = "GET"
    case post = "POST"
  }
  
  struct Request {
    var method: Method
    var body: Data?
    var headers: [String: String]
    var url: URL
  }
  
  struct Response {
    let headers: [String: String]
    let output: Data
    let statusCode: Int
    
    struct Raw {
      var receivedData: Data?
      var receivedResponse: URLResponse?
    }
  }
  
  enum Error: Swift.Error {
    case invalidStatusCode(Int)
    case responseError(Swift.Error)
    case noHTTPResponse
    case noData
  }
}

extension HTTP.Request {
  var urlRequest: URLRequest {
    var request = URLRequest(url: url)
    request.allHTTPHeaderFields = headers
    request.httpMethod = method.rawValue
    request.httpBody = body
    return request
  }
}

extension HTTP.Response {
  func validateStatusCode<T: Collection>(validCodes: T) throws -> HTTP.Response where T.Element == Int {
    if validCodes.contains(statusCode) {
      return self
    }
    throw HTTP.Error.invalidStatusCode(statusCode)
  }
}

extension HTTP.Response.Raw {
  func toHTTPResponse(originalRequest: URLRequest) throws -> HTTP.Response {
    guard
      let httpResponse = receivedResponse as? HTTPURLResponse
      else {
        throw HTTP.Error.noHTTPResponse
    }
    
    guard
      let data = receivedData
      else {
        throw HTTP.Error.noData
    }
    
    return .init(
      headers: [String: String](
        httpResponse.allHeaderFields.map { ("\($0)", "\($1)") },
        uniquingKeysWith: { _, b in b }
      ) ,
      output: data,
      statusCode: httpResponse.statusCode
    )
  }
}

extension HTTP.Error: Identifiable {
  var id: Int {
    switch self {
    case .invalidStatusCode:
      return 0
    case .responseError:
      return 1
    case .noHTTPResponse:
      return 2
    case .noData:
      return 3
    }
  }
}
