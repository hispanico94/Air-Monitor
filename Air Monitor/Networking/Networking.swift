//
//  Networking.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 30/01/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Combine
import Foundation

enum NetworkError: Error, CustomStringConvertible {
  case statusCode(Int)
  
  var description: String {
    switch self {
    case .statusCode(let code):
      return "Response returned with code \(code)"
    }
  }
}

protocol Network {
  var decoder: JSONDecoder { get }
  func execute<T: Decodable>(_: RequestProvider) -> AnyPublisher<T, Error>
}

extension Network {
  var decoder: JSONDecoder {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    return decoder
  }
  
  func execute<T: Decodable>(_ requestProvider: RequestProvider) -> AnyPublisher<T, Error> {
    URLSession.shared.dataTaskPublisher(for: requestProvider.request)
      .tryMap({ tuple in
        let (data, response) = tuple
        if let response = response as? HTTPURLResponse {
          if response.statusCode < 200 || response.statusCode >= 300 {
            throw NetworkError.statusCode(response.statusCode)
          }
        }
        return data
      })
      .decode(type: T.self, decoder: decoder)
      .eraseToAnyPublisher()
  }
}
