//
//  Endpoint.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 25/01/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation
import CoreLocation


enum Endpoint {
  case countries
  case zone(country: Country)
  case locations(Either<Zone, Coordinate>)
  case measurements(Either<Location, Coordinate>)
  case parameters
}

extension Endpoint: RequestProvider {
  private var baseURL: URL { URL(string: "https://api.openaq.org/v1/")! }
  
  var request: URLRequest {
    switch self {
    case .countries:
      return URLRequest(url: baseURL.appendingPathComponent("countries"))
      
    case .zone(let country):
      return URLRequest(url: baseURL.appendingPathComponent("cities?country=\(country.code)"))
      
    case .locations(let either):
      switch either {
      case .left(let zone):
        return URLRequest(url: baseURL.appendingPathComponent("locations?city=\(zone.name)"))
      case .right(let coordinate):
        var radiusParameter = ""
        if let radius = coordinate.radius {
          radiusParameter = "&radius=\(radius)"
        }
        
        return URLRequest(url: baseURL.appendingPathComponent("locations?coordinates=\(coordinate.latitude),\(coordinate.longitude)" + radiusParameter))
      }
      
    case .measurements(let either):
      let endpoint = baseURL.appendingPathComponent("measurements?", isDirectory: false)
      
      switch either {
      case .left(let location):
        return URLRequest(url: endpoint.appendingPathComponent("location=\(location.name)"))
      case .right(let coordinate):
        var radiusParameter = ""
        if let radius = coordinate.radius {
          radiusParameter = "&radius=\(radius)"
        }
        
        return URLRequest(url: endpoint.appendingPathComponent("coordinates=\(coordinate.latitude),\(coordinate.longitude)" + radiusParameter))
      }
      
    case .parameters:
      return URLRequest(url: baseURL.appendingPathComponent("parameters"))
    }
  }
  
  
}





enum Either<A, B> {
  case left(A)
  case right(B)
}
