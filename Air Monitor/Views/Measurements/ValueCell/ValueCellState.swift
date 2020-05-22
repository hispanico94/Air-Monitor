//
//  ValueCellState.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 01/03/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation
import SwiftUI

struct ValueCellState: Equatable {
  let dateAscendingMeasurements: [Measurement]
  
  init?(measurements: [Measurement]) {
    guard measurements.isEmpty == false else { return nil }
    self.dateAscendingMeasurements = measurements
      .map { updating($0) { $00.date = $00.date.toMidnight(in: TimeZone(identifier: "UTC")!) ?? $00.date } }
      .sorted(by: \.date)
  }
  
  var currentMeasure: CurrentMeasure {
    dateAscendingMeasurements
      .last
      .map(CurrentMeasure.init(from:))!
  }
  
  var measureDateBounds: (String, String) {
    let olderDateString = (dateAscendingMeasurements.first?.date)
      .map(DateFormatter.airParameterFormatter.string(from:))
      ?? "---"
    
    let newerDateString = (dateAscendingMeasurements.last?.date)
      .map(DateFormatter.airParameterFormatter.string(from:))
      ?? "---"
    
    return (olderDateString, newerDateString)
  }
  
  var bars: [Bar] {
    return dateAscendingMeasurements
      .lazy
      .reduce(into: [Date: [Measurement]](), { partialResult, measurement in
        partialResult[measurement.date, default: []].append(measurement)
      })
      .map({ _, measurements -> Measurement in
        measurements.max(by: \.value.value)!
      })
      .sorted { $0.date < $1.date }
      .map { measurement -> Bar in
          Bar(
            id: UUID(),
            value: measurement.value.value,
            color: measurement.value.eaqi?.color ?? .gray
          )
      }
  }
}

extension ValueCellState: Identifiable {
  var id: String {
    currentMeasure.name
  }
}

struct CurrentMeasure: Equatable {
  let name: String
  let value: String
  let unit: String
  let riskColor: Color
  let date: String
}

extension CurrentMeasure {
  init(from measurement: Measurement) {
    
    self.name = measurement.value.parameter.name
    self.value = NumberFormatter
      .singleDecimal
      .string(from: measurement.value.value as NSNumber)!
    
    self.unit = measurement.value.unit.rawValue
    self.riskColor = measurement.value.eaqi?.color ?? .gray
    self.date = DateFormatter.airParameterFormatter.string(from: measurement.date)
  }
}

