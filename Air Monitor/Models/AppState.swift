import Foundation

struct AppState {
  var selectedCountry: Country? = nil
  var selectedZone: Zone? = nil
  var selectedLocation: Location? = nil
  
  var measurementsCells: [ValueCellState] = []
  var isMeasurementsLoading: Bool = false
  var isLocationSelectionLoading: Bool = false
  
  var errorAlertMessage: String? = nil
}


enum AppAction {
  case searchButtonTapped
  case countryListResponse(Result<[Country], Error>)
  case countrySelected(Country)
  case zoneListResponse(Result<[Zone], Error>)
  case zoneSelected(Zone)
  case locationListResponse(Result<[Location], Error>)
  case locationSelected(Location)
  case locationMeasurementsResponse(Result<[Measurement], Error>)
  case errorAlertDismissed
}

import ComposableArchitecture

struct AppEnvironment {
  var scheduler: AnySchedulerOf<DispatchQueue>
}
