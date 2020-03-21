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
    let location: Either<Location, Coordinate>
    
    private var oneMonthAgo: String {
      let oneMonthAgoDate = Date(timeIntervalSinceNow: -2_592_000)
      
      let formatter = ISO8601DateFormatter()
      formatter.formatOptions = .withFullDate
      
      return formatter.string(from: oneMonthAgoDate)
    }
    
    var HTTPRequest: HTTP.Request {
      let path = "measurements"
      let standardParameter = "?limit=10000"
      var parameters = ""
      
      switch location {
      case .left(let location):
        parameters = "&location=\(location.name)"
      case .right(let coordinate):
        parameters =
        "&coordinates=\(coordinate.latitude),\(coordinate.longitude)"
        + (coordinate.radius.map { "&radius=\($0)" } ?? "")
      }
      
      // returning only the air parameter we need
      AirParameter.allCases.forEach { parameter in
        parameters.append(contentsOf: "&parameter=\(parameter.rawValue)")
      }
      
      // returning only the last month data
      parameters.append(contentsOf: "&date_from=\(oneMonthAgo)")
      
      return HTTP.Request(
        method: .get,
        body: nil,
        headers: Current.client.configuration.defaultHeaders(),
        url: URL(string: Current.client.configuration.rootURL().absoluteString + path + standardParameter + parameters)!
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
      
      return try? decoder
        .decode(MeasurementsProvider.Response.self, from: response.output)
        .results
  })
}
