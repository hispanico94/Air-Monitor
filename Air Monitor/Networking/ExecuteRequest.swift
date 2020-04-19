//
//  ExecuteRequest.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 08/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Combine
import Foundation



struct ExecuteRequest<RequestModel, ResponseModel> {
  var makeRequest: (RequestModel) -> HTTP.Request
  var handleResponse: (HTTP.Response) -> ResponseModel
  
  func run(with requestModel: RequestModel) -> AnyPublisher<ResponseModel, HTTP.Error> {
    
    Result.Publisher(.success(makeRequest(requestModel)))
      .flatMap { Current.client.rootRequestExecution($0) }
      .tryMap { try $0.validateStatusCode(validCodes: Current.client.configuration.validStatusCodes) }
      .mapError { $0 as! HTTP.Error }
      .map(handleResponse)
      .eraseToAnyPublisher()
  }
}


