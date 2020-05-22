//
//  MeasurementsView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 29/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

struct MeasurementsView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    UITableView.appearance().separatorStyle = .none
    
    return WithViewStore(self.store) { viewStore in
      NavigationView {
        Group {
          if viewStore.cells.isEmpty == false {
            List {
              ForEach(viewStore.cells, content: ValueCell.init(state:))
            }
          } else {
            Text(viewStore.emptyMessage)
              .fontWeight(.medium)
              .multilineTextAlignment(.center)
              .foregroundColor(.secondary)
          }
        }
        .alert(
          isPresented: viewStore.binding(
            get: { $0.errorAlertMessage != nil },
            send: { _ in AppAction.errorAlertDismissed }
          ),
          content: {
            Alert(title: Text("Error"), message: Text(viewStore.errorAlertMessage ?? ""), dismissButton: .default(Text("Ok")))
        })
          .navigationBarTitle(viewStore.selectedLocation?.formattedName ?? "No Location")
          .navigationBarItems(trailing: Button(
            action: { viewStore.send(.searchButtonTapped) },
            label: {
              HStack {
                Text("Search")
                Image(systemName: "magnifyingglass")
                  .imageScale(.large)
              }
          })
        )
      }
      .sheet(isPresented: .constant(viewStore.isLocationSelectionModalShown), content: { Text("LMAO") } )
    }
    .tabItem {
      Image(systemName: "wind")
      Text("Measurements")
    }
  }
}

struct MeasurementsView_Previews: PreviewProvider {
  static var previews: some View {
    MeasurementsView(store: .init(
      initialState: AppState(
        measurements: [
          Measurement(date: Date(), value: .init(parameter: .pm10, value: 41, unit: .microgramsPerCubicMeter)),
          Measurement(date: Date().addingTimeInterval(-60*60*24), value: .init(parameter: .pm10, value: 32, unit: .microgramsPerCubicMeter)),
          Measurement(date: Date().addingTimeInterval(-60*60*24*2), value: .init(parameter: .pm10, value: 12, unit: .microgramsPerCubicMeter)),
          Measurement(date: Date().addingTimeInterval(-60*60*24*3), value: .init(parameter: .pm10, value: 9, unit: .microgramsPerCubicMeter))
        ],
        selectedLocation: Location(id: "IT1", name: "Cassino", formattedName: "Cassino", lastUpdated: Date())
      ),
      reducer: appReducer.debug(),
      environment: .init(
        openAQIClient: .live,
        mainQueue: .init(DispatchQueue.main),
        currentDate: .init(),
        oldestDate: .init(timeIntervalSinceNow: -(60 * 60 * 24 * 30)),
        locale: .autoupdatingCurrent
      )
      ))
  }
}
