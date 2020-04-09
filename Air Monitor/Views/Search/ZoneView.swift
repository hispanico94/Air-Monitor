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
    country.name.lowercased().capitalized
  }
  
  @Published private(set) var zones = [Zone]()
  @Published var error: HTTP.Error?
  @Published private(set) var isLoading = true
  
  init(country: Country) {
    self.country = country
  }
  
  func fetchZonesList() {
    ExecuteRequest.getZones
      .run(with: .init(country: country))
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { [weak self] completion in
          self?.isLoading = false
          switch completion {
          case .finished:
            break
          case .failure(let error):
            self?.error = error
          }
        },
        receiveValue: { [weak self] zones in
          guard
            let zones = zones,
            zones.isEmpty == false
            else {
              self?.zones = []
              return
          }
          self?.zones = zones.sorted(by: \.name)
          self?.error = nil
      })
      .store(in: &cancellables)
  }
}

struct ZoneView: View {
  @ObservedObject private var viewModel: ZoneViewModel
  @State private var searchText = ""
  
  private var filteredZones: [Zone] {
    guard
    searchText.isEmpty == false
      else {
        return viewModel.zones
    }
    
    return viewModel.zones
      .filter { $0.name.lowercased().contains(searchText.lowercased()) }
  }
  
  private let onLocationSelection: (Location) -> Void
  
  init(viewModel: ZoneViewModel, onLocationSelection: @escaping (Location) -> Void) {
    self.viewModel = viewModel
    self.onLocationSelection = onLocationSelection
  }
  
  var body: some View {
    VStack {
      SearchBar(text: $searchText, placeholder: "Search")
      
      ZStack {
        List(filteredZones) { zone in
          NavigationLink(destination: LocationView(viewModel: LocationViewModel(zone: zone), onLocationSelection: self.onLocationSelection)) {
            Text(zone.name.lowercased().capitalized)
          }
        }
        .gesture(DragGesture().onChanged { _ in UIApplication.shared.endEditing(true) })
        .alert(item: $viewModel.error) { error in
            Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("Ok")))
        }
        
        ActivityIndicator(isAnimating: viewModel.isLoading, style: .large)
      }
    }
    .navigationBarTitle(viewModel.title)
    .onAppear(perform: viewModel.fetchZonesList)
  }
}

struct ZoneView_Previews: PreviewProvider {
  static var previews: some View {
    ZoneView(viewModel: ZoneViewModel(country: Country(code: "IT", name: "Italy")), onLocationSelection: { _ in })
  }
}
