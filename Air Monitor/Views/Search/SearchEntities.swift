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
  var selectedLocation: Location? = nil
  var search: SearchState = .init()
}

struct SearchState: Equatable {
  var countries: [Country] = []
  var zones: [Zone] = []
  var locations: [Location] = []
  
  var selectedCountry: Country? = nil
  var selectedZone: Zone? = nil
  
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
      state.search.countries = countries.sorted(by: \.name)
    }
    return .none
    
  case .zonesResponse(.success(let zones)):
    state.search.isLoading = false
    if zones.isEmpty {
      state.search.errorMessage = "No results"
    } else {
      state.search.zones = zones.sorted(by: \.name)
    }
    return .none
    
  case .locationsResponse(.success(let locations)):
    state.search.isLoading = false
    if locations.isEmpty {
      state.search.errorMessage = "No results"
    } else {
      state.search.locations = locations.sorted(by: \.name)
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
    if state.search.selectedCountry == country {
      state.search.selectedCountry = nil
      state.search.selectedZone = nil
      state.selectedLocation = nil
      state.search.zones = []
      state.search.locations = []
      return .none
    }
    state.search.selectedCountry = country
    state.search.isLoading = true
    return environment.openAQIClient
      .getZones(country)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(SearchAction.zonesResponse)
    
  case .zoneSelected(let zone):
    if state.search.selectedZone == zone {
      state.search.selectedZone = nil
      state.selectedLocation = nil
      state.search.locations = []
      return .none
    }
    state.search.selectedZone = zone
    state.search.isLoading = true
    return environment.openAQIClient
      .getLocations(zone)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(SearchAction.locationsResponse)
    
  case .locationSelected(let location):
    if state.selectedLocation == location {
      state.selectedLocation = nil
      return .none
    }
    state.selectedLocation = location
    state.search.isLoading = true
    return environment.openAQIClient
      .getMeasurements(location, environment.oldestDate, environment.currentDate, environment.locale)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(SearchAction.measurementsResponse)
  
  case .viewAppeared:
    if state.search.countries.isEmpty {
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
