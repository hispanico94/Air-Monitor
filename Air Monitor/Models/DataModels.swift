//
//  DataModels.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 26/01/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

// MARK: -

struct OpenAQIReponse<T: Decodable>: Decodable {
  let results: [T]
}

struct OpenAQIFailureResponse: Decodable {
  let statusCode: Int
  let error: String
  let message: String
}

// MARK: - Country

struct Country: Equatable {
  let code: String
  let name: String
  
  struct Raw: Decodable {
    let code: String?
    let name: String?
    
    var toCountry: Country? {
      zip(code, name)
        .map { ($0, $1.lowercased().capitalized) }
        .map(Country.init)
    }
  }
}

//extension Country: Identifiable {
//  var id: String { code }
//}

// MARK: - Zone

struct Zone: Equatable {
  let id: String
  let name: String
  
  struct Raw: Decodable {
    let name: String?
    
    var toZone: Zone? {
      name
        .map { ($0, $0.lowercased().capitalized) }
        .map(Zone.init)
    }
  }
}

// MARK: - Location

struct Location: Equatable {
  let id: String
  let name: String
  let formattedName: String
  let lastUpdated: Date

  struct Raw: Decodable {
    let id: String?
    let location: String?
    let lastUpdated: Date?
    
    var toLocation: Location? {
      zip(id, location, lastUpdated)
        .map { ($0, $1, $1.lowercased().capitalized, $2) }
        .map(Location.init)
    }
  }
}

// MARK: - Measurement

struct Measurement: Equatable {
  let date: Date
  let value: MeasurementValue
  
  struct Raw: Decodable {
    let parameter: String?
    let value: Double?
    let unit: String?
    let date: DateContainer?
    
    var toMeasurement: Measurement? {
      guard
        let airParameter = AirParameter(rawValue: parameter ?? ""),
        let unit = MeasurementUnit(rawValue: unit ?? ""),
        let value = value,
        let date = date?.utc
        else { return nil }
      
      let measurementValue = MeasurementValue(
        parameter: airParameter,
        value: value,
        unit: unit
      )
      
      return Measurement(date: date, value: measurementValue)
    }
    
    struct DateContainer: Decodable {
      let utc: Date?
    }
  }
}

// MARK: - MeasurementValue

struct MeasurementValue: Equatable {
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
  
  var description: String {
    switch self {
    case .extremelyPoor:
      return "Extremely Poor"
    case .veryPoor:
      return "Very Poor"
    case .poor:
      return "Poor"
    case .moderate:
      return "Moderate"
    case .fair:
      return "Fair"
    case .good:
      return "Good"
    }
  }
  
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
