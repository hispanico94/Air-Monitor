//
//  Models.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 26/01/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation
import CoreLocation

struct Country: Decodable {
  let code: String
  let name: String
}



struct Location: Decodable {
  let name: String
  let country: String
  let zone: String
  
  
  enum CodingKeys: String, CodingKey {
    case name = "location"
    case country
    case zone = "city"
  }
}



struct Measurements: Decodable {
  let zone: Zone
  let location: String
  let date: Date
  
  let coordinate: Coordinate
  
  enum CodingKeys: String, CodingKey {
    case countryCode
    case city
    case location
    case date
    case utc
    case coordinate = "coordinates"
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    let countryCode = try container.decode(String.self, forKey: .countryCode)
    let city = try container.decode(String.self, forKey: .city)
    self.zone = Zone(name: city, countryCode: countryCode)
    
    self.location = try container.decode(String.self, forKey: .location)
    self.coordinate = try container.decode(Coordinate.self, forKey: .coordinate)
    
    let dateContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .date)
    self.date = try dateContainer.decode(Date.self, forKey: .utc)
  }
}



struct AirParameter: Decodable {
  let id: String
  let name: String
  let description: String
  let preferredUnit: String
}



struct Zone: Decodable {
  let name: String
  let countryCode: String
  
  enum CodingKeys: String, CodingKey {
    case name = "city"
    case countryCode = "country"
  }
}



struct Coordinate: Decodable {
  let latitude: Double
  let longitude: Double
  let radius: Int?
  
  var clLocationCoordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}
