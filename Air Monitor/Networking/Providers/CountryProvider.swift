//
//  CountryProvider.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 30/01/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation

enum CountryProvider {
  struct Request {
    var HTTPRequest: HTTP.Request {
      let path = "countries"
      
      return HTTP.Request(
        method: .get,
        body: nil,
        headers: Current.client.configuration.defaultHeaders(),
        url: Current.client.configuration.rootURL().appendingPathComponent(path)
      )
    }
  }
  
  struct Response: Decodable {
    struct CountryDTO: Decodable {
      let name: String?
      let code: String?
      
      var toCountry: Country? {
        guard
          let name = name,
          let code = code
          else { return nil }
        
        return Country(code: code, name: name)
      }
    }
    
    var results: [CountryDTO]
    
    var countries : [Country] {
      results
        .compactMap(\.toCountry)
    }
  }
}

extension ExecuteRequest where RequestModel == CountryProvider.Request, ResponseModel == [Country]? {
  static let getCountries = ExecuteRequest(
    makeRequest: {
      $0.HTTPRequest
  },
    handleResponse: {
      try? JSONDecoder()
        .decode(CountryProvider.Response.self, from: $0.output)
        .countries
  })
}
