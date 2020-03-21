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
          self?.countries = countries
          self?.errorMessage = ""
      })
      .store(in: &cancellables)
  }
}

struct CountryView: View {
  @ObservedObject private var viewModel: CountryViewModel
  private let onLocationSelection: (Location) -> Void
  
  
  init(viewModel: CountryViewModel, onLocationSelection: @escaping (Location) -> Void) {
    self.viewModel = viewModel
    self.onLocationSelection = onLocationSelection
  }
  
  var body: some View {
    NavigationView {
      List(viewModel.countries) { country in
        if country.name != nil {
          NavigationLink(destination: ZoneView(viewModel: .init(country: country), onLocationSelection: self.onLocationSelection)) {
            Text(country.name!)
          }
        } else {
          Text("No Name").foregroundColor(.red)
        }
      }
      .navigationBarTitle("Countries")
    }
  }
}

struct CountryView_Previews: PreviewProvider {
  static var previews: some View {
    CountryView(viewModel: .init(), onLocationSelection: { _ in })
  }
}
