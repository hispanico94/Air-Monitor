//
//  DataModels.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 26/01/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftUI

// MARK: - Country

struct Country {
  let code: String
  let name: String
}

extension Country: Identifiable {
  var id: String { code }
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

extension Location: Identifiable {
  var id: String { name }
}

// MARK: - Measurement

struct Measurement: Decodable {
  var location: Location
  var date: Date
  var measurement: AirMeasurement
  
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
    
    let airParameter = AirParameter(rawValue: parameter)!
    let measurementUnit = MeasurementUnit(rawValue: unit)!
    self.measurement = AirMeasurement(parameter: airParameter, value: value, unit: measurementUnit)
    
    let dateContainer = try container.nestedContainer(keyedBy: CodingKeys.self, forKey: .date)
    let dateString = try dateContainer.decode(String.self, forKey: .utc)
    self.date = ISO8601DateFormatter.openAqiDateFormatter.date(from: dateString)!
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

extension Zone: Identifiable { }

// MARK: - Coordinate

struct Coordinate: Decodable {
  let latitude: Double
  let longitude: Double
  let radius: Int?
  
  var clLocationCoordinate: CLLocationCoordinate2D {
    CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
  }
}


// MARK: - AirMeasurement

struct AirMeasurement {
  let parameter: AirParameter
  private let internalValue: Double
  let unit: MeasurementUnit
  
  init(parameter: AirParameter, value: Double, unit: MeasurementUnit) {
    self.parameter = parameter
    self.internalValue = value
    self.unit = unit
  }
  
  /// Always in micrograms per cubic meter
  var value: Double {
    switch unit {
    case .microgramsPerCubicMeter:
      return internalValue
    case .partsPerMillion:
      return 40.9 * internalValue * parameter.molecularWeight
    }
  }
  
  var eaqi: EAQI? {
    .index(for: parameter, microgramsPerCubicMeter: value)
  }
}

// MARK: - AirParameter

enum AirParameter: String, Identifiable, CaseIterable {
  case pm10
  case pm25
  case no2
  case so2
  case o3
  
  var id: String {
    self.rawValue
  }
  
  var name: String {
    switch self {
    case .pm10:
      return "PM₁₀"
    case .pm25:
      return "PM₂.₅"
    case .no2:
      return "NO₂"
    case .so2:
      return "SO₂"
    case .o3:
      return "O₃"
    }
  }
  
  // Unit is g/mol
  var molecularWeight: Double {
    switch self {
    case .pm10:
      fatalError("unknown")
    case .pm25:
      fatalError("unknown")
    case .no2:
      return 46.01
    case .so2:
      return 64.06
    case .o3:
      return 48
    }
  }
  
  var unit: String {
    "µg/m³"
  }
}

// MARK: - MeasurementUnit

enum MeasurementUnit: String {
  case microgramsPerCubicMeter = "µg/m³"
  case partsPerMillion = "ppm"
}

// MARK: - EAQI

// European Air Quality Index
enum EAQI: Int {
  case extremelyPoor
  case veryPoor
  case poor
  case moderate
  case fair
  case good
  
  var color: Color {
    switch self {
    case .extremelyPoor:
      return Color(.systemPurple)
    case .veryPoor:
      return Color(.systemRed)
    case .poor:
      return Color(.systemOrange)
    case .moderate:
      return Color(.systemYellow)
    case .fair:
      return Color(.systemGreen)
    case .good:
      return Color(.systemTeal)
    }
  }
  
  static func index(for parameter: AirParameter, microgramsPerCubicMeter value: Double) -> EAQI? {
    switch parameter {
    case .pm10:
      return indexForPM10(ofValue: value)
    case .pm25:
      return indexForPM25(ofValue: value)
    case .no2:
      return indexForNO2(ofValue: value)
    case .so2:
      return indexForSO2(ofValue: value)
    case .o3:
      return indexForO3(ofValue: value)
    }
  }
  
  private static func indexForPM25(ofValue value: Double) -> EAQI? {
    switch value {
    case 0..<10:
      return .good
    case 10..<20:
      return .fair
    case 20..<25:
      return .moderate
    case 25..<50:
      return .poor
    case 50..<75:
      return .veryPoor
    case 75..<800:
      return .extremelyPoor
    default:
      return nil
    }
  }
  
  private static func indexForPM10(ofValue value: Double) -> EAQI? {
    switch value {
    case 0..<20:
      return .good
    case 20..<40:
      return .fair
    case 40..<50:
      return .moderate
    case 50..<100:
      return .poor
    case 100..<150:
      return .veryPoor
    case 150..<1200:
      return .extremelyPoor
    default:
      return nil
    }
  }
  
  private static func indexForNO2(ofValue value: Double) -> EAQI? {
    switch value {
    case 0..<40:
      return .good
    case 40..<90:
      return .fair
    case 90..<120:
      return .moderate
    case 120..<230:
      return .poor
    case 230..<340:
      return .veryPoor
    case 340..<1000:
      return .extremelyPoor
    default:
      return nil
    }
  }
  
  private static func indexForO3(ofValue value: Double) -> EAQI? {
    switch value {
    case 0..<50:
      return .good
    case 50..<100:
      return .fair
    case 100..<130:
      return .moderate
    case 130..<240:
      return .poor
    case 240..<380:
      return .veryPoor
    case 380..<800:
      return .extremelyPoor
    default:
      return nil
    }
  }
  
  private static func indexForSO2(ofValue value: Double) -> EAQI? {
    switch value {
    case 0..<100:
      return .good
    case 100..<200:
      return .fair
    case 200..<350:
      return .moderate
    case 350..<500:
      return .poor
    case 500..<750:
      return .veryPoor
    case 750..<1250:
      return .extremelyPoor
    default:
      return nil
    }
  }
}
