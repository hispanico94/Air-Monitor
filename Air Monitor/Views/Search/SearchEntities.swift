//
//  SearchEntities.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 22/05/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import ComposableArchitecture
import Foundation

struct SearchState: Equatable {
  var countries: [Country] = []
  var zones: [Zone] = []
  var locations: [Location] = []
  var measurements: [Measurement] = []
  
  var selectedCountry: Country? = nil
  var selectedZone: Zone? = nil
  var selectedLocation: Location? = nil
  
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
}

struct SearchEnvironment {
  var openAQIClient: OpenAQI = .live
  var mainQueue: AnySchedulerOf<DispatchQueue> = .init(DispatchQueue.main)
  var currentDate: Date = .init()
  var oldestDate: Date = .init(timeIntervalSinceNow: -60*60*24*30)
  var locale: Locale = .init(identifier: "it_IT")
}

let searchReducer = Reducer<SearchState, SearchAction, SearchEnvironment> { state, action, environment in
  switch action {
  case .countriesResponse(.success(let countries)):
    state.isLoading = false
    if countries.isEmpty {
      state.errorMessage = "No results!"
    } else {
      state.countries = countries
    }
    return .none
    
  case .zonesResponse(.success(let zones)):
    state.isLoading = false
    if zones.isEmpty {
      state.errorMessage = "No results!"
    } else {
      state.zones = zones
    }
    return .none
    
  case .locationsResponse(.success(let locations)):
    state.isLoading = false
    if locations.isEmpty {
      state.errorMessage = "No results!"
    } else {
      state.locations = locations
    }
    return .none
    
  case .measurementsResponse(.success(let measurements)):
    state.isLoading = false
    if measurements.isEmpty {
      state.errorMessage = "No results"
    } else {
      state.measurements = measurements
    }
    return .none
    
  case .countrySelected(let country):
    if state.selectedCountry == country {
      state.selectedCountry = nil
      state.selectedZone = nil
      state.selectedLocation = nil
      state.zones = []
      state.locations = []
      return .none
    }
    state.selectedCountry = country
    state.isLoading = true
    return environment.openAQIClient
      .getZones(country)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(SearchAction.zonesResponse)
    
  case .zoneSelected(let zone):
    if state.selectedZone == zone {
      state.selectedZone = nil
      state.selectedLocation = nil
      state.locations = []
      return .none
    }
    state.selectedZone = zone
    state.isLoading = true
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
    state.isLoading = true
    return environment.openAQIClient
      .getMeasurements(location, environment.oldestDate, environment.currentDate, environment.locale)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(SearchAction.measurementsResponse)
  
  case .viewAppeared:
    if state.countries.isEmpty {
      return environment.openAQIClient
        .getCountries()
        .receive(on: environment.mainQueue)
        .catchToEffect()
        .map(SearchAction.countriesResponse)
    }
    return .none
    
  case .errorAlertDismissed:
    state.errorMessage = nil
    return .none
    
  case .countriesResponse(.failure(let error)),
       .zonesResponse(.failure(let error)),
       .locationsResponse(.failure(let error)),
       .measurementsResponse(.failure(let error)):
    state.isLoading = false
    state.errorMessage = error.localizedDescription
    return .none
  }
}
