//
//  CountryView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 14/03/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Combine
import SwiftUI

final class CountryViewModel: ObservableObject {
  private var cancellables = Set<AnyCancellable>()
  
  @Published var countries = [Country]()
  @Published var errorMessage = ""
  
  init() {
    bindCountryList()
  }
  
  private func bindCountryList() {
    ExecuteRequest.getCountries
      .run(with: .init())
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
        receiveValue: { [weak self] countries in
          guard
            let countries = countries,
            countries.isEmpty == false
            else {
              self?.countries = []
              self?.errorMessage = "No results"
              return
          }
          self?.countries = countries.sorted(by: \.name)
          self?.errorMessage = ""
      })
      .store(in: &cancellables)
  }
}

struct CountryView: View {
  @ObservedObject private var viewModel: CountryViewModel
  @State private var searchText = ""
  
  private var filteredCountries: [Country] {
    guard
      searchText.isEmpty == false
      else {
        return viewModel.countries
    }
    return viewModel.countries
      .filter { $0.name.lowercased().contains(searchText.lowercased()) }
  }
  
  private let onLocationSelection: (Location) -> Void
  
  
  init(viewModel: CountryViewModel, onLocationSelection: @escaping (Location) -> Void) {
    self.viewModel = viewModel
    self.onLocationSelection = onLocationSelection
  }
  
  var body: some View {
    NavigationView {
      VStack(spacing: 0) {
        SearchBar(text: $searchText, placeholder: "Search")
        List(filteredCountries) { country in
          NavigationLink(destination: ZoneView(viewModel: .init(country: country), onLocationSelection: self.onLocationSelection)) {
            Text(country.name)
          }
        }
        .gesture(DragGesture().onChanged { _ in UIApplication.shared.endEditing(true) })
      }
      .navigationBarTitle("Countries", displayMode: .inline)
    }
  }
}

struct CountryView_Previews: PreviewProvider {
  static var previews: some View {
    CountryView(viewModel: .init(), onLocationSelection: { _ in })
  }
}
