//
//  CurrentLocationIndexView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 05/04/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

//import SwiftUI
//
//class CurrentLocationIndexViewModel {
//  private let data: CurrentLocationSummaryData
//
//  var zoneName: String {
//    data.zone
//  }
//
//  var countryName: String {
//    data.country
//  }
//
//  var latestMeasurementDate: String {
//    DateFormatter.airParameterFormatter
//      .string(from: data.date)
//  }
//
//  var indexFromLatestMeasurements: String {
//    data.eaqi.description
//  }
//
//  var indexColorFromLatestMeasurements: Color {
//    data.eaqi.color
//  }
//
//  init(data: CurrentLocationSummaryData) {
//    self.data = data
//  }
//}
//
//struct CurrentLocationIndexView: View {
//  let viewModel: CurrentLocationIndexViewModel
//
//  var body: some View {
//    VStack {
//      Text("\(viewModel.zoneName), \(viewModel.countryName)")
//        .padding(.bottom)
//
//      Text("Last updated: \(viewModel.latestMeasurementDate)")
//        .padding(.bottom)
//
//      Text("Latest EAQI index:")
//
//      Text(viewModel.indexFromLatestMeasurements)
//        .font(.title)
//        .foregroundColor(viewModel.indexColorFromLatestMeasurements)
//    }
//    .padding(.all, 16)
//    .background(Color(.secondarySystemBackground))
//    .cornerRadius(16)
//    .shadow(radius: 3, y: 3)
//    .frame(maxWidth: .infinity)
//  }
//}
//
//struct CurrentLocationIndexView_Previews: PreviewProvider {
//  private static let viewModel = CurrentLocationIndexViewModel(data: CurrentLocationSummaryData(
//    zone: "Frosinone",
//    country: "Italy",
//    date: Date(),
//    eaqi: .moderate
//    )
//  )
//
//  static var previews: some View {
//    Group {
//      CurrentLocationIndexView(viewModel: viewModel)
//        .previewLayout(.sizeThatFits)
//      CurrentLocationIndexView(viewModel: viewModel)
//        .previewLayout(.sizeThatFits)
//        .background(Color(.systemBackground))
//        .environment(\.colorScheme, .dark)
//    }
//  }
//}
//
//struct CurrentLocationSummaryData {
//  let zone: String
//  let country: String
//  let date: Date
//  let eaqi: EAQI
//}
//
//extension CurrentLocationSummaryData {
//  init?(from measurement: Measurement) {
//    guard
//      let eaqi = measurement.measurement.eaqi
//      else { return nil }
//
//    self.zone = measurement.location.zone
//    self.country = measurement.location.country
//    self.date = measurement.date
//    self.eaqi = eaqi
//  }
//}
