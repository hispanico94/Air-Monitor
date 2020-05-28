import ComposableArchitecture
import Foundation

// MARK: - Configuration

private struct Configuration {
  var defaultHeaders = [
    "Accept": "application/json",
    "Content-Type": "application/json"
  ]
  
  var defaultQueryItem = URLQueryItem(name: "limit", value: "10000")
  
  var rootURLString = "https://api.openaq.org/v1/"
  
  var validStatusCodes = (200 ..< 300)
  
  var defaultDecoder = updating(JSONDecoder()) {
    $0.dateDecodingStrategy = .formatted(.iso8601Full)
  }
}

private let configuration = Configuration()

// MARK: - Client

struct OpenAQI {
  var getCountries: () -> Effect<[Country], Failure>
  var getZones: (Country) -> Effect<[Zone], Failure>
  var getLocations: (Zone) -> Effect<[Location], Failure>
  var getMeasurements: (Location, Date, Date, Locale) -> Effect<[Measurement], Failure>
  
  enum Failure: Error {
    case badFormattedUrl
    case responseError(Error)
    
    var localizedDescription: String {
      switch self {
      case .badFormattedUrl:
        return "The request url was badly formatted"
      case .responseError(let error):
        return error.localizedDescription
      }
    }
  }
}

// MARK: - Live

extension OpenAQI {
  static let live: OpenAQI = .init(
    getCountries: defaultGetCountries,
    getZones: defaultGetZones(_:),
    getLocations: defaultGetLocations(_:),
    getMeasurements: defaultGetMeasurements(_:_:_:_:)
  )
}

// MARK: - Mock

extension OpenAQI {
  static let mock: OpenAQI = .init(
    getCountries: {
      Effect(value: [
        Country(code: "IT", name: "Italy"),
        Country(code: "ES", name: "Spain"),
        Country(code: "FR", name: "France"),
        Country(code: "DE", name: "Germany")
      ])
  },
    getZones: { _ in
      Effect(value: [
        Zone(id: "Frosinone", name: "Frosinone"),
        Zone(id: "Roma", name: "Roma"),
        Zone(id: "Perugia", name: "Perugia"),
        Zone(id: "Siena", name: "Siena")
      ])
  },
    getLocations: { _ in
      Effect(value: [
        Location(id: "IT1", name: "Cassino", formattedName: "Cassino", lastUpdated: Date()),
        Location(id: "IT2", name: "Frascati", formattedName: "Frascati", lastUpdated: Date()),
        Location(id: "IT3", name: "Foligno", formattedName: "Foligno", lastUpdated: Date()),
        Location(id: "IT4", name: "Pienza", formattedName: "Pienza", lastUpdated: Date())
      ])
  },
    getMeasurements: { _, _, _, _ in
      Effect(value: [
        Measurement(date: Date(), value: .init(parameter: .pm10, value: 41, unit: .microgramsPerCubicMeter)),
        Measurement(date: Date().addingTimeInterval(-60*60*24), value: .init(parameter: .pm10, value: 32, unit: .microgramsPerCubicMeter)),
        Measurement(date: Date().addingTimeInterval(-60*60*24*2), value: .init(parameter: .pm10, value: 12, unit: .microgramsPerCubicMeter)),
        Measurement(date: Date().addingTimeInterval(-60*60*24*3), value: .init(parameter: .pm10, value: 9, unit: .microgramsPerCubicMeter))
      ])
  }
  )
}

// MARK: - Live implementations

private func defaultGetCountries() -> Effect<[Country], OpenAQI.Failure> {
  let fullPath = configuration.rootURLString.appending("countries")
  var urlComponents = URLComponents(string: fullPath)
  urlComponents?.queryItems = [configuration.defaultQueryItem]
  
  guard let url = urlComponents?.url else { return .init(error: .badFormattedUrl) }
  
  return URLSession.shared
    .dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: OpenAQIReponse<Country.Raw>.self, decoder: configuration.defaultDecoder)
    .map(\.results)
    .map { $0.compactMap(\.toCountry) }
    .mapError(OpenAQI.Failure.responseError)
    .eraseToEffect()
}

private func defaultGetZones(_ country: Country) -> Effect<[Zone], OpenAQI.Failure> {
  let fullPath = configuration.rootURLString.appending("cities")
  var urlComponents = URLComponents(string: fullPath)
  urlComponents?.queryItems = [
    URLQueryItem(name: "country", value: "\(country.code)"),
    configuration.defaultQueryItem
  ]
  
  guard let url = urlComponents?.url else { return .init(error: .badFormattedUrl) }
  
  return URLSession.shared
    .dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: OpenAQIReponse<Zone.Raw>.self, decoder: configuration.defaultDecoder)
    .map(\.results)
    .map { $0.compactMap(\.toZone) }
    .mapError(OpenAQI.Failure.responseError)
    .eraseToEffect()
}

private func defaultGetLocations(_ zone: Zone) -> Effect<[Location], OpenAQI.Failure> {
  let fullPath = configuration.rootURLString.appending("locations")
  var urlComponents = URLComponents(string: fullPath)
  urlComponents?.queryItems = [
    URLQueryItem(name: "city", value: "\(zone.id)"),
    configuration.defaultQueryItem
  ]
  
  guard let url = urlComponents?.url else { return .init(error: .badFormattedUrl) }
  
  return URLSession.shared
    .dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: OpenAQIReponse<Location.Raw>.self, decoder: configuration.defaultDecoder)
    .map(\.results)
    .map { $0.compactMap(\.toLocation) }
    .mapError(OpenAQI.Failure.responseError)
    .eraseToEffect()
}

private func defaultGetMeasurements(_ location: Location, _ initialDate: Date, _ finalDate: Date, _ locale: Locale) -> Effect<[Measurement], OpenAQI.Failure> {
  
  let formatter = ISO8601DateFormatter()
  formatter.timeZone = locale.calendar.timeZone
  formatter.formatOptions = .withFullDate
  
  let fullPath = configuration.rootURLString.appending("measurements")
  var urlComponents = URLComponents(string: fullPath)
  urlComponents?.queryItems = [
    URLQueryItem(name: "location", value: "\(location.name)"),
    URLQueryItem(name: "date_from", value: formatter.string(from: initialDate)),
    URLQueryItem(name: "date_to", value: formatter.string(from: finalDate)),
    configuration.defaultQueryItem
  ]
  
  guard let url = urlComponents?.url else { return .init(error: .badFormattedUrl) }
  
  return URLSession.shared
    .dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: OpenAQIReponse<Measurement.Raw>.self, decoder: configuration.defaultDecoder)
    .map(\.results)
    .map { $0.compactMap(\.toMeasurement) }
    .mapError(OpenAQI.Failure.responseError)
    .eraseToEffect()
}


