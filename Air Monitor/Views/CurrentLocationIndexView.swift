//
//  CurrentLocationIndexView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 05/04/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

class CurrentLocationIndexViewModel {
  private var measurement: Measurement
  
  var zoneName: String {
    measurement.location.zone
  }
  
  var countryName: String {
    measurement.location.country
  }
  
  var latestMeasurementDate: String {
    DateFormatter.airParameterFormatter
      .string(from: measurement.date)
  }
  
  var indexFromLatestMeasurements: String {
    measurement.measurement.eaqi?.description ?? "N/A"
  }
  
  var indexColorFromLatestMeasurements: Color {
    measurement.measurement.eaqi?.color ?? Color(.label)
  }
  
  init(measurement: Measurement) {
    self.measurement = measurement
  }
}

struct CurrentLocationIndexView: View {
  let viewModel: CurrentLocationIndexViewModel
  
  var body: some View {
    VStack {
      Text("\(viewModel.zoneName), \(viewModel.countryName)")
        .padding(.bottom)
      
      Text("Last updated: \(viewModel.latestMeasurementDate)")
        .padding(.bottom)
      
      Text("Current EAQI index:")
      
      Text(viewModel.indexFromLatestMeasurements)
        .font(.title)
        .foregroundColor(viewModel.indexColorFromLatestMeasurements)
    }
    .padding(.all, 16)
    .background(Color(.secondarySystemBackground))
    .cornerRadius(16)
  }
}

struct CurrentLocationIndexView_Previews: PreviewProvider {
  private static let viewModel = CurrentLocationIndexViewModel(measurement: Measurement(
    location: Location(
      name: "Cassino",
      country: "Italy",
      zone: "Frosinone",
      coordinate: Coordinate(
        latitude: 41.49,
        longitude: 13.83,
        radius: nil)),
    date: Date(),
    measurement: AirMeasurement(
      parameter: .pm10,
      value: 86,
      unit: .microgramsPerCubicMeter)
    )
  )
  
  static var previews: some View {
    Group {
      CurrentLocationIndexView(viewModel: viewModel)
        .previewLayout(.sizeThatFits)
      CurrentLocationIndexView(viewModel: viewModel)
        .previewLayout(.sizeThatFits)
        .background(Color(.systemBackground))
        .environment(\.colorScheme, .dark)
    }
  }
}
