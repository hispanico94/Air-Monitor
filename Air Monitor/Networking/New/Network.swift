//
//  Network.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 08/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Combine
import Foundation

extension World {
  struct Client {
    struct Configuration {
      var defaultHeaders = {
        [
          "Accept": "application/json",
          "Content-Type": "application/json"
        ]
      }
      
      var rootURL = { URL(string: "https://api.openaq.org/v1/")! }
      
      var validStatusCodes = (200...399)
    }
    
    var configuration = Configuration()
    
    var rootRequestExecution: (HTTP.Request) -> AnyPublisher<HTTP.Response, HTTP.Error> = { request in
      let urlRequest = request.urlRequest
      
      return URLSession.shared.dataTaskPublisher(for: urlRequest)
        .mapError { HTTP.Error.responseError($0) }
        .map(HTTP.Response.Raw.init)
        .tryMap { try $0.toHTTPResponse(originalRequest: urlRequest) }
        .mapError { $0 as! HTTP.Error }
        .eraseToAnyPublisher()
    }
  }
}

private var CurrentClient = World.Client()

extension World {
  var client: Client {
    get { CurrentClient }
    set { CurrentClient = newValue }
  }
}
