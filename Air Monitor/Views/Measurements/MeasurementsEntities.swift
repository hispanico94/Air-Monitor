import ComposableArchitecture
import Foundation

struct MeasurementsState: Equatable {
  var measurements: [Measurement] = []
  var selectedLocation: Location? = nil
  var search: SearchState = .init()
  var isLocationSelectionModalShown: Bool = false
  
  var errorAlertMessage: String? = nil
  
  var searchMeasurements: SearchMeasurementsState {
    get {
      .init(
        measurements: measurements,
        selectedLocation: selectedLocation,
        search: search
      )
    }
    set {
      measurements = newValue.measurements
      selectedLocation = newValue.selectedLocation
      search = newValue.search
    }
  }
}

extension MeasurementsState {
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

enum MeasurementsAction {
  case searchButtonTapped
  case search(SearchAction)
  case errorAlertDismissed
}

struct MeasurementsEnvironment {
  var openAQIClient: OpenAQI
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var currentDate: Date
  var oldestDate: Date
  var locale: Locale
}

let measurementsReducer = Reducer<MeasurementsState, MeasurementsAction, MeasurementsEnvironment>.combine(
Reducer { state, action, environment in
  switch action {
  case .searchButtonTapped:
    state.isLocationSelectionModalShown = true
    return .none
    
  case .search(.searchCompleted):
    state.isLocationSelectionModalShown = false
    return .none
    
  case .search:
    return .none
    
  case .errorAlertDismissed:
    state.errorAlertMessage = nil
    return .none
  }
},
searchReducer.pullback(
  state: \.searchMeasurements,
  action: /MeasurementsAction.search,
  environment: { _ in SearchEnvironment() }
  )
)


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
