//
//  HomeView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 12/01/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct HomeView: View {
  var body: some View {
    TabView {
      MeasurementsView()
      MapView()
    }
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    HomeView()
  }
}
