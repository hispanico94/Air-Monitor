//
//  SearchView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 26/05/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct SearchView: View {
  let store: Store<SearchState, SearchAction>
  
  var body: some View {
    
    WithViewStore(self.store) { viewStore in
      ZStack {
        List {
          if viewStore.state.countries.isEmpty == false {
            self.makeCountrySection(
              countries: viewStore.state.countries,
              selectedCountry: viewStore.state.selectedCountry,
              countryTapped: { viewStore.send(.countrySelected($0)) })
          }
          
          if viewStore.state.zones.isEmpty == false {
            self.makeZoneSection(
              zones: viewStore.state.zones,
              selectedZone: viewStore.state.selectedZone,
              zoneTapped: { viewStore.send(.zoneSelected($0)) })
          }
          
          if viewStore.state.locations.isEmpty == false {
            self.makeLocationSection(
              locations: viewStore.state.locations,
              selectedLocation: viewStore.state.selectedLocation,
              locationTapped: { viewStore.send(.locationSelected($0)) })
          }
        }
        .listStyle(GroupedListStyle())
        .alert(item: viewStore.binding(
          get: { $0.errorMessage.map(ErrorViewState.init(description:)) },
          send: .errorAlertDismissed)) {
            Alert.init(title: Text($0.title), message: Text($0.description))
        }
        
        if viewStore.state.isLoading {
          ActivityIndicator(
            isAnimating: true,
            style: .large
          )
        }
      }
      .onAppear { viewStore.send(.viewAppeared) }
    }
  }
  
  private func makeCountrySection(countries: [Country], selectedCountry: Country?, countryTapped: @escaping (Country) -> Void) -> some View {
    Section(header: Text("Countries").font(.headline)) {
      if selectedCountry != nil {
        ForEach(0..<1) { _ in
          self.makeCell(
            withText: selectedCountry!.name,
            marked: true,
            onTap: { countryTapped(selectedCountry!) }
          )
        }
      } else {
        ForEach(countries, id: \.code) { country in
          self.makeCell(
            withText: country.name,
            onTap: { countryTapped(country) }
          )
        }
      }
    }
  }
  
  private func makeZoneSection(zones: [Zone], selectedZone: Zone?, zoneTapped: @escaping (Zone) -> Void) -> some View {
    Section(header: Text("Zones").font(.headline)) {
      if selectedZone != nil {
        ForEach(0..<1) { _ in
          self.makeCell(
            withText: selectedZone!.name,
            marked: true,
            onTap: { zoneTapped(selectedZone!) }
          )
        }
      } else {
        ForEach(zones, id: \.id) { zone in
          self.makeCell(
            withText: zone.name,
            onTap: { zoneTapped(zone) }
          )
        }
      }
    }
  }
  
  private func makeLocationSection(locations: [Location], selectedLocation: Location?, locationTapped: @escaping (Location) -> Void) -> some View {
    Section(header: Text("Locations").font(.headline)) {
      if selectedLocation != nil {
        ForEach(0..<1) { _ in
          self.makeCell(
            withText: selectedLocation!.formattedName,
            marked: true,
            onTap: { locationTapped(selectedLocation!) }
          )
        }
      } else {
        ForEach(locations, id: \.id) { location in
          self.makeCell(
            withText: location.formattedName,
            onTap: { locationTapped(location) }
          )
        }
      }
    }
  }
  
  private func makeCell(withText text: String, marked: Bool = false, onTap: @escaping () -> Void) -> some View {
    Button(action: onTap) {
      HStack {
        Text(text)
        Spacer()
        if marked {
          Image(systemName: "checkmark")
            .foregroundColor(Color(.systemBlue))
        }
      }
      .padding(.horizontal, 16)
    }
  }
}


struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    SearchView(store: .init(
      initialState: SearchState(),
      reducer: searchReducer.debug(),
      environment: SearchEnvironment()
      ))
  }
}
