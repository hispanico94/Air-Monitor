//
//  ZoneView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 14/03/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Combine
import SwiftUI

final class ZoneViewModel: ObservableObject {
  private var cancellables = Set<AnyCancellable>()
  private let country: Country
  
  var title: String {
    country.name ?? ""
  }
  
  @Published var zones = [Zone]()
  @Published var errorMessage = ""
  
  init(country: Country) {
    self.country = country
    bindZoneList()
  }
  
  private func bindZoneList() {
    ExecuteRequest.getZones
      .run(with: .init(country: country))
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
        receiveValue: { [weak self] zones in
          guard
            let zones = zones,
            zones.isEmpty == false
            else {
              self?.zones = []
              self?.errorMessage = "No results"
              return
          }
          self?.zones = zones
          self?.errorMessage = ""
      })
      .store(in: &cancellables)
  }
}

struct ZoneView: View {
  @ObservedObject private var viewModel: ZoneViewModel
  private let onLocationSelection: (Location) -> Void
  
  init(viewModel: ZoneViewModel, onLocationSelection: @escaping (Location) -> Void) {
    self.viewModel = viewModel
    self.onLocationSelection = onLocationSelection
  }
  
  var body: some View {
    Group {
      if viewModel.errorMessage.isEmpty {
        List(viewModel.zones) { zone in
          NavigationLink(destination: LocationView(viewModel: LocationViewModel(zone: zone), onLocationSelection: self.onLocationSelection)) {
            Text(zone.name.lowercased().capitalized)
          }
        }
        .navigationBarTitle(viewModel.title)
      } else {
        Text(viewModel.errorMessage)
      }
    }
  }
}

struct ZoneView_Previews: PreviewProvider {
  static var previews: some View {
    ZoneView(viewModel: ZoneViewModel(country: Country(code: "IT", name: "Italy")), onLocationSelection: { _ in })
  }
}
