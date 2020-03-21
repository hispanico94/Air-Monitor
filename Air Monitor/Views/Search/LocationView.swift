//
//  LocationView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 15/03/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Combine
import SwiftUI

final class LocationViewModel: ObservableObject {
  private var cancellables = Set<AnyCancellable>()
  let zone: Zone
  
  @Published var locations = [Location]()
  @Published var errorMessage = ""
  
  init(zone: Zone) {
    self.zone = zone
    bindLocationList()
  }
  
  private func bindLocationList() {
    ExecuteRequest.getLocations
      .run(with: .init(parameter: .left(zone)))
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          switch completion {
          case .finished:
            break
          case .failure(let error):
            self?.errorMessage = error.localizedDescription
          }
        },
        receiveValue: { [weak self] locations in
          guard
            let locations = locations,
            locations.isEmpty == false
            else {
              self?.locations = []
              self?.errorMessage = "No results"
              return
          }
          self?.locations = locations
          self?.errorMessage = ""
      })
      .store(in: &cancellables)
  }
}

struct LocationView: View {
  @ObservedObject private var viewModel: LocationViewModel
  private let onLocationSelection: (Location) -> Void
  
  init(viewModel: LocationViewModel, onLocationSelection: @escaping (Location) -> Void) {
    self.viewModel = viewModel
    self.onLocationSelection = onLocationSelection
  }
  
  var body: some View {
    Group {
      if viewModel.errorMessage.isEmpty {
        List(viewModel.locations) { location in
          Button(location.name) {
            self.onLocationSelection(location)
          }
        }
      } else {
        Text(viewModel.errorMessage)
      }
    }
    .navigationBarTitle(viewModel.zone.name)
  }
}

struct LocationView_Previews: PreviewProvider {
  static var previews: some View {
    LocationView(viewModel: LocationViewModel(zone: Zone(id: "Frosinone", name: "Frosinone", countryCode: "IT")), onLocationSelection: { _ in })
  }
}
