//
//  SearchEntities.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 22/05/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct SearchMeasurementsState: Equatable {
  var measurements: [Measurement] = []
  var selectedCountry: Country? = nil
  var selectedZone: Zone? = nil
  var selectedLocation: Location? = nil
  var search: SearchState = .init()
}

struct SearchState: Equatable {
  var allCountries: [Country] = []
  var allZones: [Zone] = []
  var allLocations: [Location] = []
  
  var displayedCountries: [Country] = []
  var displayedZones: [Zone] = []
  var displayedLocations: [Location] = []
  
  var searchPlaceholder: String = "Search countries"
  var searchString: String = ""
  
  var errorMessage: String? = nil
  var isLoading: Bool = false
}

enum SearchAction {
  case countriesResponse(Result<[Country], OpenAQI.Failure>)
  case zonesResponse(Result<[Zone], OpenAQI.Failure>)
  case locationsResponse(Result<[Location], OpenAQI.Failure>)
  case measurementsResponse(Result<[Measurement], OpenAQI.Failure>)
  
  case countrySelected(Country)
  case zoneSelected(Zone)
  case locationSelected(Location)
  
  case searchTextEntered(String)
  
  case viewAppeared
  case errorAlertDismissed
  case searchCompleted
}

struct SearchEnvironment {
  var openAQIClient: OpenAQI = .live
  var mainQueue: AnySchedulerOf<DispatchQueue> = .init(DispatchQueue.main)
  var currentDate: Date = .init()
  var oldestDate: Date = .init(timeIntervalSinceNow: -60*60*24*30)
  var locale: Locale = .init(identifier: "it_IT")
}

let searchReducer = Reducer<SearchMeasurementsState, SearchAction, SearchEnvironment> { state, action, environment in
  switch action {
  case .countriesResponse(.success(let countries)):
    state.search.isLoading = false
    if countries.isEmpty {
      state.search.errorMessage = "No results"
    } else {
      state.search.allCountries = countries.sorted(by: \.name)
      state.search.displayedCountries = state.search.allCountries
    }
    return .none
    
  case .zonesResponse(.success(let zones)):
    state.search.isLoading = false
    if zones.isEmpty {
      state.search.errorMessage = "No results"
    } else {
      state.search.allZones = zones.sorted(by: \.name)
      state.search.displayedZones = state.search.allZones
    }
    return .none
    
  case .locationsResponse(.success(let locations)):
    state.search.isLoading = false
    if locations.isEmpty {
      state.search.errorMessage = "No results"
    } else {
      state.search.allLocations = locations.sorted(by: \.name)
      state.search.displayedLocations = state.search.allLocations
    }
    return .none
    
  case .measurementsResponse(.success(let measurements)):
    state.search.isLoading = false
    if measurements.isEmpty {
      state.search.errorMessage = "No results"
      return .none
    } else {
      state.measurements = measurements
      return Effect(value: .searchCompleted)
    }
    
  case .countrySelected(let country):
    state.search.searchString = ""
    
    if state.selectedCountry == country {
      state.selectedCountry = nil
      state.selectedZone = nil
      state.selectedLocation = nil
      state.search.allZones = []
      state.search.displayedZones = []
      state.search.allLocations = []
      state.search.displayedLocations = []
      state.search.displayedCountries = state.search.allCountries
      state.search.searchPlaceholder = "Search countries"
      return .none
    }
    state.selectedCountry = country
    state.search.isLoading = true
    state.search.searchPlaceholder = "Search zones"
    return environment.openAQIClient
      .getZones(country)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(SearchAction.zonesResponse)
    
  case .zoneSelected(let zone):
    state.search.searchString = ""
    
    if state.selectedZone == zone {
      state.selectedZone = nil
      state.selectedLocation = nil
      state.search.allLocations = []
      state.search.displayedLocations = []
      state.search.displayedZones = state.search.allZones
      state.search.searchPlaceholder = "Search zones"
      return .none
    }
    state.selectedZone = zone
    state.search.isLoading = true
    state.search.searchPlaceholder = "Search locations"
    return environment.openAQIClient
      .getLocations(zone)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(SearchAction.locationsResponse)
    
  case .locationSelected(let location):
    state.search.searchString = ""
    
    if state.selectedLocation == location {
      state.selectedLocation = nil
      state.search.displayedLocations = state.search.allLocations
      state.search.searchPlaceholder = "Search locations"
      return .none
    }
    state.selectedLocation = location
    state.search.isLoading = true
    return environment.openAQIClient
      .getMeasurements(location, environment.oldestDate, environment.currentDate, environment.locale)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(SearchAction.measurementsResponse)
    
  case .searchTextEntered(let searchText):
    state.search.searchString = searchText
    
    guard state.selectedLocation == nil else { return .none }
    
    if state.selectedZone != nil {
      state.search.displayedLocations = state.search.allLocations.filter {
        searchText.isEmpty
          ? true
          : $0.name.lowercased().contains(searchText.lowercased())
      }
      
    } else if state.selectedCountry != nil {
      state.search.displayedZones = state.search.allZones.filter {
        searchText.isEmpty
          ? true
          : $0.name.lowercased().contains(searchText.lowercased())
      }
      
    } else {
      state.search.displayedCountries = state.search.allCountries.filter {
        searchText.isEmpty
          ? true
          : $0.name.lowercased().contains(searchText.lowercased())
      }
    }
    
    return .none
  
  case .viewAppeared:
    if state.search.allCountries.isEmpty {
      state.search.isLoading = true
      return environment.openAQIClient
        .getCountries()
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(SearchAction.countriesResponse)
    }
    return .none
    
  case .errorAlertDismissed:
    state.search.errorMessage = nil
    return .none
    
  case .countriesResponse(.failure(let error)),
       .zonesResponse(.failure(let error)),
       .locationsResponse(.failure(let error)),
       .measurementsResponse(.failure(let error)):
    state.search.isLoading = false
    state.search.errorMessage = error.localizedDescription
    return .none
    
    // Signals to the MeasurementsView that the search is completed
  case .searchCompleted:
    return .none
  }
}
