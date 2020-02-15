//
//  DataModels.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 26/01/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation
import CoreLocation

// MARK: - Country

struct Country: Decodable {
  let code: String?
  let name: String?
}

// MARK: - Location

struct Location: Decodable {
  let name: String
  let country: String
  let zone: String
  let coordinate: Coordinate
  
  
  enum CodingKeys: String, CodingKey {
    case name = "location"
    case country
    case zone = "city"
    case coordinate = "coordinates"
  }
}

// MARK: - Measurement

struct Measurement: Decodable {
  let location: Location
  let date: Date
  let measurement: AirParameter
  
  enum CodingKeys: String, CodingKey {
    case location
    case coordinates
    case country
    case city
    
    case parameter
    case value
    case unit
    
    case date
    case utc
  }
  
  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    
    let location = try container.decode(String.self, forKey: .location)
    let coordinates = try container.decode(Coordinate.self, forKey: .coordinates)
    let country = try container.decode(String.self, forKey: .country)
    let city = try container.decode(String.self, forKey: .city)
    self.location = Location(name: location, country: country, zone: city, coordinate: coordinates)
    
    let parameter = try container.decode(String.self, forKey: .parameter)
    let value = try container.decode(Double.self, forKey: .value)
    let unit = try container.decode(String.self, forKey: .unit)
    self.measurement = AirParameter(name: parameter, value: value, unit: unit)
    
    let dateContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .date)
    self.date = try dateContainer.decode(Date.self, forKey: .utc)
  }
}

// MARK: - AirParameter

struct AirParameter: Decodable {
  let name: String
  let value: Double
  let unit: String
  
  enum CodingKeys: String, CodingKey {
    case name = "parameter"
    case value
    case unit
  }
}

// MARK: - Zone

struct Zone: Decodable {
  let id: String
  let name: String
  let countryCode: String
  
  enum CodingKeys: String, CodingKey {
    case id = "name"
    case name = "city"
    case countryCode = "country"
  }
}

// MARK: - Coordinate

struct Coordinate: Decodable {
  let latitude: Double
  let longitude: Double
  let radius: Int?
  
  var clLocationCoordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}
