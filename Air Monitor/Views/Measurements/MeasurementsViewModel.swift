//
//  MeasurementsViewModel.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 01/03/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import Foundation
import Combine

final class MeasurementsViewModel: ObservableObject {
  private var cancellables = Set<AnyCancellable>()
  private var locationSubject = PassthroughSubject<Location?, HTTP.Error>()
  private var location: Location? {
    didSet {
      loading = true
      locationSubject.send(location)
    }
  }
  
  
  @Published private(set) var cells = [ValueCellState]()
  @Published var error: HTTP.Error? = nil
  @Published private(set) var loading = false
  
  var summaryData: CurrentLocationSummaryData? {
    cells
      .compactMap(\.dateAscendingMeasurements.last)
      .sorted(by: \.date, comparator: >)
      .reduce(into: [Measurement](), { partialResult, measurement in
        if let mostRecentMeasurement = partialResult.first {
          if measurement.date.isInTheSameDay(of: mostRecentMeasurement.date) {
            partialResult.append(measurement)
          }
        } else {
          partialResult.append(measurement)
        }
      })
      .min(by: { $0.measurement.eaqi?.rawValue ?? Int.min < $1.measurement.eaqi?.rawValue ?? Int.max })
      .flatMap(CurrentLocationSummaryData.init(from:))
  }
  
  var locationName: String {
    location?.name ?? ""
  }
  
  init() {
    self.bindLocationUpdate()
  }
  
  func fetchMeasurements(for location: Location) {
    self.location = location
  }
  
  private func bindLocationUpdate() {
    locationSubject
      .compactMap { $0 }
      .map { Either.left($0) }
      .map(MeasurementsProvider.Request.init(location:))
      .flatMap(ExecuteRequest.getMeasurements.run(with:))
      .compactMap { $0 }
      .map(collectForAirParameter(measurements:))
      .map(cellViewStates(from:))
      .receive(on: DispatchQueue.main)
      .handleEvents(
        receiveOutput: { [weak self] _ in
          guard let self = self else { return }
          self.loading = false
          if self.error != nil {
            self.error = nil
          }
        },
        receiveCompletion: { [weak self] completion in
          self?.loading = false
          switch completion {
          case .finished:
            break
          case .failure(let error):
            self?.error = error
          }
      })
      .replaceError(with: [])
      .assign(to: \.cells, on: self)
      .store(in: &cancellables)
  }
  
  private func collectForAirParameter(measurements: [Measurement]) -> [[Measurement]] {
    let parameters = AirParameter.allCases
    
    var collectedMeasurements = [[Measurement]]()
    
    parameters
      .forEach({ parameter in
        collectedMeasurements
          .append(
            measurements
              .reduce([Measurement]()) { partialResult, measurement in
                if measurement.measurement.parameter == parameter {
                  return partialResult + [measurement]
                }
                return partialResult
            }
        )
      })
    
    
    return collectedMeasurements
  }
  
  private func cellViewStates(from collectedMeasurements: [[Measurement]]) -> [ValueCellState] {
    collectedMeasurements.compactMap(ValueCellState.init(measurements:))
  }
  
}