//
//  ValueCellState.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 01/03/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation
import SwiftUI

struct ValueCellState {
  private let dateAscendingMeasurements: [Measurement]
  
  init?(measurements: [Measurement]) {
    guard measurements.isEmpty == false else { return nil }
    self.dateAscendingMeasurements = measurements
      .sorted { $0.date < $1.date }
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
  
  // TODO: COLLECT BY DAY ONLY MAX VALUE MEASUREMENT
  var bars: [Bar] {
    dateAscendingMeasurements
      .map { measurement in
        Bar(
          id: UUID(),
          value: Int(measurement.measurement.value.rounded()),
          color: measurement.measurement.eaqi?.color ?? .gray
        )
    }
  }
}

extension ValueCellState: Identifiable {
  var id: String {
    currentMeasure.name
  }
}

struct CurrentMeasure {
  let name: String
  let value: String
  let unit: String
  let riskColor: Color
  let date: String
}

extension CurrentMeasure {
  init(from measurement: Measurement) {
    
    self.name = measurement.measurement.parameter.name
    self.value = NumberFormatter
      .singleDecimal
      .string(from: measurement.measurement.value as NSNumber)!
    
    self.unit = measurement.measurement.unit.rawValue
    self.riskColor = measurement.measurement.eaqi?.color ?? .gray
    self.date = DateFormatter.airParameterFormatter.string(from: measurement.date)
  }
}

