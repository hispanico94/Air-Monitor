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
  let store: Store<SearchMeasurementsState, SearchAction>
  
  init(store: Store<SearchMeasurementsState, SearchAction>) {
    self.store = store
    
    UITableView.appearance().tableHeaderView = UIView(
      frame: CGRect(
        x: 0,
        y: 0,
        width: 0,
        height: Double.leastNonzeroMagnitude
    ))
  }
  
  var body: some View {
    
    WithViewStore(self.store) { viewStore in
      NavigationView {
        ZStack {
          List {
            
            SearchBar(
              text: viewStore.binding(
                get: { $0.search.searchString },
                send: { .searchTextEntered($0) }),
              placeholder: viewStore.state.search.searchPlaceholder)
              .buttonStyle(PlainButtonStyle())
            
            if viewStore.state.search.allCountries.isEmpty == false {
              self.makeCountrySection(
                countries: viewStore.state.search.displayedCountries,
                selectedCountry: viewStore.state.selectedCountry,
                countryTapped: { viewStore.send(.countrySelected($0)) })
            }
            
            if viewStore.state.search.allZones.isEmpty == false {
              self.makeZoneSection(
                zones: viewStore.state.search.displayedZones,
                selectedZone: viewStore.state.selectedZone,
                zoneTapped: { viewStore.send(.zoneSelected($0)) })
            }
            
            if viewStore.state.search.allLocations.isEmpty == false {
              self.makeLocationSection(
                locations: viewStore.state.search.displayedLocations,
                selectedLocation: viewStore.state.selectedLocation,
                locationTapped: { viewStore.send(.locationSelected($0)) })
            }
          }
          .listStyle(GroupedListStyle())
          .alert(item: viewStore.binding(
            get: { $0.search.errorMessage.map(ErrorViewState.init(description:)) },
            send: .errorAlertDismissed)) {
              Alert.init(title: Text($0.title), message: Text($0.description))
          }
          
          if viewStore.state.search.isLoading {
            ActivityIndicator(
              isAnimating: true,
              style: .large
            )
          }
        }
        .onAppear { viewStore.send(.viewAppeared) }
        .navigationBarTitle("Search", displayMode: .inline)
      }
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
    .foregroundColor(.primary)
  }
}


struct SearchView_Previews: PreviewProvider {
  static var previews: some View {
    SearchView(store: .init(
      initialState: SearchMeasurementsState(),
      reducer: searchReducer.debug(),
      environment: SearchEnvironment()
      ))
  }
}
