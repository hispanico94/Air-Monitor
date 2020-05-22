import ComposableArchitecture
import Foundation

struct AppState: Equatable {
  var countries: [Country] = []
  var zones: [Zone] = []
  var locations: [Location] = []
  var measurements: [Measurement] = []
  var selectedCountry: Country? = nil
  var selectedZone: Zone? = nil
  var selectedLocation: Location? = nil
  var isLocationSelectionModalShown: Bool = false
  
  var measurementsCells: [ValueCellState] = []
  var isLocationSelectionScreenLoading: Bool = false
  
  var errorAlertMessage: String? = nil
}

extension AppState {
  var cells: [ValueCellState] {
    guard measurements.isEmpty == false else { return [] }
    return collectForAirParameter(measurements: measurements)
      .compactMap(ValueCellState.init(measurements:))
  }
  
  var emptyMessage: String {
    selectedLocation == nil
      ? "No location selected"
      : "No data available.\nPlease search another location"
  }
}

enum AppAction {
  case searchButtonTapped
  case countryListResponse(Result<[Country], OpenAQI.Failure>)
  case countrySelected(Country)
  case zoneListResponse(Result<[Zone], OpenAQI.Failure>)
  case zoneSelected(Zone)
  case locationListResponse(Result<[Location], OpenAQI.Failure>)
  case locationSelected(Location)
  case locationMeasurementsResponse(Result<[Measurement], OpenAQI.Failure>)
  case errorAlertDismissed
}

struct AppEnvironment {
  var openAQIClient: OpenAQI
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var currentDate: Date
  var oldestDate: Date
  var locale: Locale
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
  case .searchButtonTapped:
    state.isLocationSelectionModalShown = true
    state.isLocationSelectionScreenLoading = true
    return environment.openAQIClient
      .getCountries()
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(AppAction.countryListResponse)
    
  case .countryListResponse(.success(let countries)):
    state.isLocationSelectionScreenLoading = false
    state.countries = countries
    return .none
    
  case .countryListResponse(.failure(let error)):
    state.isLocationSelectionScreenLoading = false
    state.errorAlertMessage = error.localizedDescription
    return .none
    
  case .countrySelected(let country):
    state.selectedCountry = country
    state.isLocationSelectionScreenLoading = true
    return environment.openAQIClient
      .getZones(country)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(AppAction.zoneListResponse)
    
  case .zoneListResponse(.success(let zones)):
    state.isLocationSelectionScreenLoading = false
    state.zones = zones
    return .none
    
  case .zoneListResponse(.failure(let error)):
    state.isLocationSelectionScreenLoading = false
    state.errorAlertMessage = error.localizedDescription
    return .none
    
  case .zoneSelected(let zone):
    state.selectedZone = zone
    state.isLocationSelectionScreenLoading = true
    return environment.openAQIClient
      .getLocations(zone)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(AppAction.locationListResponse)
    
  case .locationListResponse(.success(let locations)):
    state.isLocationSelectionScreenLoading = false
    state.locations = locations
    return .none
    
  case .locationListResponse(.failure(let error)):
    state.isLocationSelectionScreenLoading = false
    state.errorAlertMessage = error.localizedDescription
    return .none
    
  case .locationSelected(let location):
    state.selectedLocation = location
    state.isLocationSelectionScreenLoading = true
    return environment.openAQIClient
      .getMeasurements(location, environment.currentDate, environment.oldestDate, environment.locale)
      .receive(on: environment.mainQueue)
      .catchToEffect()
      .map(AppAction.locationMeasurementsResponse)
    
  case .locationMeasurementsResponse(.success(let measurements)):
    state.isLocationSelectionScreenLoading = false
    state.measurements = measurements
    state.isLocationSelectionModalShown = false
    return .none
    
  case .locationMeasurementsResponse(.failure(let error)):
    state.isLocationSelectionScreenLoading = false
    state.errorAlertMessage = error.localizedDescription
    return .none
    
  case .errorAlertDismissed:
    state.errorAlertMessage = nil
    return .none
  }
}


// MARK: - Private helper functions

private func collectForAirParameter(measurements: [Measurement]) -> [[Measurement]] {
  let parameters = AirParameter.allCases
  
  var collectedMeasurements = [[Measurement]]()
  
  parameters
    .forEach({ parameter in
      collectedMeasurements
        .append(
          measurements
            .reduce([Measurement]()) { partialResult, measurement in
              if measurement.value.parameter == parameter {
                return partialResult + [measurement]
              }
              return partialResult
          }
      )
    })
  
  
  return collectedMeasurements
}
