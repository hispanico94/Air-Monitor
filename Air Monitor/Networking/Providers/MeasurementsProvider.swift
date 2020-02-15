//
//  MeasurementsProvider.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 15/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation

enum MeasurementsProvider {
  struct Request {
    let parameter: Either<Location, Coordinate>
    
    var HTTPRequest: HTTP.Request {
      let path = "measurements"
      let standardParameter = "?limit=10000"
      var parameters = ""
      
      switch parameter {
      case .left(let location):
        parameters = "&location=\(location.name)"
      case .right(let coordinate):
        parameters =
        "&coordinates=\(coordinate.latitude),\(coordinate.longitude)"
        + (coordinate.radius.map { "&radius=\($0)" } ?? "")
      }
      
      return HTTP.Request(
        method: .get,
        body: nil,
        headers: Current.client.configuration.defaultHeaders(),
        url: Current.client.configuration.rootURL().appendingPathComponent(path + standardParameter + parameters)
      )
    }
  }
  
  struct Response: Decodable {
    let results: [Measurement]
  }
}

extension ExecuteRequest where RequestModel == MeasurementsProvider.Request, ResponseModel == [Measurement]? {
  static let getMeasurements = ExecuteRequest(
    makeRequest: {
      $0.HTTPRequest
  },
    handleResponse: { response in
      let decoder = JSONDecoder()
      decoder.dateDecodingStrategy = .iso8601
      
      return try? decoder
        .decode(MeasurementsProvider.Response.self, from: response.output)
        .results
  })
}
