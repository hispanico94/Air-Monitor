//
//  MeasurementsView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 29/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct MeasurementsView: View {
  @ObservedObject private var viewModel = HomeViewModel()
  @State private var isSheetPresented = false
  
  var body: some View {
    UITableView.appearance().separatorStyle = .none
    
    return NavigationView {
      ZStack {
        EmptyListView(
          data: viewModel.cells,
          emptyContent: {
            Text(self.viewModel.loading ? "" : "No data available.\nPlease search another location")
              .fontWeight(.medium)
              .multilineTextAlignment(.center)
              .foregroundColor(.secondary)
        },
          rowContent: ValueCell.init(state:)
        )
          .alert(item: $viewModel.error) { error in
            Alert(title: Text("Error"), message: Text(error.localizedDescription), dismissButton: .default(Text("Ok")))
        }
        
        ActivityIndicator(isAnimating: viewModel.loading, style: .large)
      }
      .navigationBarTitle(viewModel.locationName.lowercased().capitalized)
      .navigationBarItems(trailing: Button(
        action: { self.isSheetPresented.toggle() },
        label: {
          HStack {
            Text("Search")
            Image(systemName: "magnifyingglass")
              .imageScale(.large)
          }
      })
      )
    }
    .tabItem {
      Image(systemName: "wind")
      Text("Measurements")
    }
    .sheet(isPresented: $isSheetPresented, content: { CountryView(viewModel: .init(), onLocationSelection: { location in
      self.viewModel.fetchMeasurements(for: location)
      self.isSheetPresented = false
    }) } )
  }
}

struct MeasurementsView_Previews: PreviewProvider {
  static var previews: some View {
    MeasurementsView()
  }
}
