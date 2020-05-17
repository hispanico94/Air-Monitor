import ComposableArchitecture
import Foundation

private struct Configuration {
  var defaultHeaders = [
    "Accept": "application/json",
    "Content-Type": "application/json"
  ]
  
  var defualtQueryItem = URLQueryItem(name: "limit", value: "10000")
  
  var rootURL = URL(string: "https://api.openaq.org/v1/")!
  
  var validStatusCodes = (200 ..< 300)
}

private let configuration = Configuration()


struct OpenAQI {
  var getCountries: () -> Effect<[Country], Failure>
  var getZones: (Country) -> Effect<[Zone], Failure>
  var getLocations: (Zone) -> Effect<[Location], Failure>
  var getMeasurements: (Location) -> Effect<[Measurement], Failure>
  
  enum Failure: Error {
    case badFormattedUrl
  }
}

extension OpenAQI {
  static let live: OpenAQI = .init(
    getCountries: <#T##() -> Effect<[Country], Failure>#>,
    getZones: <#T##(Country) -> Effect<[Zone], Failure>#>,
    getLocations: <#T##(Zone) -> Effect<[Location], Failure>#>,
    getMeasurements: <#T##(Location) -> Effect<[Measurement], Failure>#>
  )
}


private func defaultGetCountries() -> Effect<[Country], OpenAQI.Failure> {
  let fullPath = configuration.rootURL.appendingPathComponent("countries", isDirectory: false)
  var fullUrl = URLComponents(url: fullPath, resolvingAgainstBaseURL: false)
  fullUrl?.queryItems?.append(configuration.defualtQueryItem)
  
  guard let url = fullUrl?.url else { return .init(error: .badFormattedUrl) }
}
