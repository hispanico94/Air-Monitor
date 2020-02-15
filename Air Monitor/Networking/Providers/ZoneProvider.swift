//
//  ZoneProvider.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 09/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation

enum ZoneProvider {
  struct Request {
    let country: Country
    
    var HTTPRequest: HTTP.Request {
      let path = "cities"
      var paramteter = ""
      
      if let countryCode = country.code {
        paramteter = "?country=\(countryCode)"
      }
      
      return HTTP.Request(
        method: .get,
        body: nil,
        headers: Current.client.configuration.defaultHeaders(),
        url: Current.client.configuration.rootURL().appendingPathComponent(path + paramteter)
      )
    }
  }
  
  struct Repsonse: Decodable {
    var results: [Zone]
  }
}

extension ExecuteRequest where RequestModel == ZoneProvider.Request, ResponseModel == [Zone]? {
  static let getZones = ExecuteRequest(
    makeRequest: {
      $0.HTTPRequest
  },
    handleResponse: {
      try? JSONDecoder()
        .decode(ZoneProvider.Repsonse.self, from: $0.output)
        .results
  })
}
