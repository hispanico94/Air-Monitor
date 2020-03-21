//
//  MapView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 29/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct MapView: View {
  var body: some View {
    Text("MapView")
      .tabItem {
        VStack {
          Image(systemName: "map.fill")
          Text("Map")
        }
    }
  }
}

struct MapView_Previews: PreviewProvider {
  static var previews: some View {
    MapView()
  }
}
