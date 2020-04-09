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
  
  @Published private(set) var countries = [Country]()
  @Published var error: HTTP.Error?
  @Published private(set) var isLoading = true
  
  func fetchCountryList() {
    ExecuteRequest.getCountries
      .run(with: .init())
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
        receiveValue: { [weak self] countries in
          guard
            let countries = countries,
            countries.isEmpty == false
            else {
              self?.countries = []
              return
          }
          self?.countries = countries.sorted(by: \.name)
          self?.error = nil
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
        
        ZStack {
          List(filteredCountries) { country in
            NavigationLink(destination: ZoneView(viewModel: .init(country: country), onLocationSelection: self.onLocationSelection)) {
              Text(country.name)
            }
          }
          .gesture(DragGesture().onChanged { _ in UIApplication.shared.endEditing(true) })
          .alert(item: $viewModel.error) { error in
              Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("Ok")))
          }
          
          ActivityIndicator(isAnimating: viewModel.isLoading, style: .large)
        }
      }
      .navigationBarTitle("Countries", displayMode: .inline)
    }
    .onAppear(perform: viewModel.fetchCountryList)
  }
}

struct CountryView_Previews: PreviewProvider {
  static var previews: some View {
    CountryView(viewModel: .init(), onLocationSelection: { _ in })
  }
}
