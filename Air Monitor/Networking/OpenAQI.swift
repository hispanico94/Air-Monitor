import ComposableArchitecture
import Foundation

private struct Configuration {
  var defaultHeaders = [
    "Accept": "application/json",
    "Content-Type": "application/json"
  ]
  
  var defaultQueryItem = URLQueryItem(name: "limit", value: "10000")
  
  var rootURL = URL(string: "https://api.openaq.org/v1/")!
  
  var validStatusCodes = (200 ..< 300)
  
  var defaultDecoder = updating(JSONDecoder()) {
    $0.dateDecodingStrategy = .iso8601
  }
}

private let configuration = Configuration()


struct OpenAQI {
  var getCountries: () -> Effect<[Country], Failure>
  var getZones: (Country) -> Effect<[Zone], Failure>
  var getLocations: (Zone) -> Effect<[Location], Failure>
  var getMeasurements: (Location, Date, Date, Locale) -> Effect<[Measurement], Failure>
  
  enum Failure: Error {
    case badFormattedUrl
    case responseError(Error)
  }
}

extension OpenAQI {
  static let live: OpenAQI = .init(
    getCountries: defaultGetCountries,
    getZones: defaultGetZones(_:),
    getLocations: defaultGetLocations(_:),
    getMeasurements: defaultGetMeasurements(_:_:_:_:)
  )
}


private func defaultGetCountries() -> Effect<[Country], OpenAQI.Failure> {
  let fullPath = configuration.rootURL.appendingPathComponent("countries", isDirectory: false)
  var fullUrl = URLComponents(url: fullPath, resolvingAgainstBaseURL: false)
  fullUrl?.queryItems?.append(configuration.defaultQueryItem)
  
  guard let url = fullUrl?.url else { return .init(error: .badFormattedUrl) }
  
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
  let fullPath = configuration.rootURL.appendingPathComponent("cities", isDirectory: false)
  var fullUrl = URLComponents(url: fullPath, resolvingAgainstBaseURL: false)
  fullUrl?.queryItems?.append(contentsOf: [
    URLQueryItem(name: "country", value: "\(country.code)"),
    configuration.defaultQueryItem
  ])
  
  guard let url = fullUrl?.url else { return .init(error: .badFormattedUrl) }
  
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
  let fullPath = configuration.rootURL.appendingPathComponent("locations", isDirectory: false)
  var fullUrl = URLComponents(url: fullPath, resolvingAgainstBaseURL: false)
  fullUrl?.queryItems?.append(contentsOf: [
    URLQueryItem(name: "city", value: "\(zone.id)"),
    configuration.defaultQueryItem
  ])
  
  guard let url = fullUrl?.url else { return .init(error: .badFormattedUrl) }
  
  return URLSession.shared
    .dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: OpenAQIReponse<Location.Raw>.self, decoder: configuration.defaultDecoder)
    .map(\.results)
    .map { $0.compactMap(\.toLocation) }
    .mapError(OpenAQI.Failure.responseError)
    .eraseToEffect()
}

private func defaultGetMeasurements(_ location: Location, _ initialDate: Date, _ lastDate: Date, _ locale: Locale) -> Effect<[Measurement], OpenAQI.Failure> {
  
  let formatter = ISO8601DateFormatter()
  formatter.timeZone = locale.calendar.timeZone
  formatter.formatOptions = .withFullDate
  
  let fullPath = configuration.rootURL.appendingPathComponent("measurements", isDirectory: false)
  var fullUrl = URLComponents(url: fullPath, resolvingAgainstBaseURL: false)
  fullUrl?.queryItems?.append(contentsOf: [
    URLQueryItem(name: "location", value: "\(location.name)"),
    URLQueryItem(name: "date_from", value: formatter.string(from: initialDate)),
    URLQueryItem(name: "date_to", value: formatter.string(from: lastDate)),
    configuration.defaultQueryItem
  ])
  
  guard let url = fullUrl?.url else { return .init(error: .badFormattedUrl) }
  
  return URLSession.shared
    .dataTaskPublisher(for: url)
    .map(\.data)
    .decode(type: OpenAQIReponse<Measurement.Raw>.self, decoder: configuration.defaultDecoder)
    .map(\.results)
    .map { $0.compactMap(\.toMeasurement) }
    .mapError(OpenAQI.Failure.responseError)
    .eraseToEffect()
}


