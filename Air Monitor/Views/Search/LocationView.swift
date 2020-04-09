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
  
  var title: String {
    zone.name.lowercased().capitalized
  }
  
  @Published private(set) var locations = [Location]()
  @Published var error: HTTP.Error?
  @Published private(set) var isLoading = true
  
  init(zone: Zone) {
    self.zone = zone
  }
  
  func fetchLocationsList() {
    ExecuteRequest.getLocations
      .run(with: .init(parameter: .left(zone)))
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
        receiveValue: { [weak self] locations in
          guard
            let locations = locations,
            locations.isEmpty == false
            else {
              self?.locations = []
              return
          }
          self?.locations = locations
          self?.error = nil
      })
      .store(in: &cancellables)
  }
}

struct LocationView: View {
  @ObservedObject private var viewModel: LocationViewModel
  @State private var searchText = ""
  private let onLocationSelection: (Location) -> Void
  
  private var filteredLocations: [Location] {
    guard
    searchText.isEmpty == false
      else {
        return viewModel.locations
    }
    
    return viewModel.locations
      .filter { $0.name.lowercased().contains(searchText.lowercased()) }
  }
  
  init(viewModel: LocationViewModel, onLocationSelection: @escaping (Location) -> Void) {
    self.viewModel = viewModel
    self.onLocationSelection = onLocationSelection
  }
  
  var body: some View {
    VStack {
      SearchBar(text: $searchText, placeholder: "Search")
      
      ZStack {
        List(filteredLocations) { location in
          Button(location.name.lowercased().capitalized) {
            self.onLocationSelection(location)
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
    .onAppear(perform: viewModel.fetchLocationsList)
  }
}

struct LocationView_Previews: PreviewProvider {
  static var previews: some View {
    LocationView(viewModel: LocationViewModel(zone: Zone(id: "Frosinone", name: "Frosinone", countryCode: "IT")), onLocationSelection: { _ in })
  }
}
