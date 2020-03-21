//
//  LocationProvider.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 15/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation

enum LocationProvider {
  struct Request {
    let parameter: Either<Zone, Coordinate>
    
    var HTTPRequest: HTTP.Request {
      let path = "locations"
      var parameters = ""
      
      switch parameter {
      case .left(let zone):
        let urlParameter = zone.name.replacingOccurrences(of: " ", with: "+")
        parameters = "?city=\(urlParameter)"
      case .right(let coordinate):
        parameters =
          "?coordinates=\(coordinate.latitude),\(coordinate.longitude)"
          + (coordinate.radius.map { "&radius=\($0)" } ?? "")
      }
      
      return HTTP.Request(
        method: .get,
        body: nil,
        headers: Current.client.configuration.defaultHeaders(),
        url: URL(string: Current.client.configuration.rootURL().absoluteString + path + parameters)!
      )
    }
  }
  
  struct Response: Decodable {
    var results: [Location]
  }
}

extension ExecuteRequest where RequestModel == LocationProvider.Request, ResponseModel == [Location]? {
  static let getLocations = ExecuteRequest(
    makeRequest: {
      $0.HTTPRequest
  },
    handleResponse: {
      try? JSONDecoder()
        .decode(LocationProvider.Response.self, from: $0.output)
        .results
  })
}
