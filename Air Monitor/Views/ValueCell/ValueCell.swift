//
//  ValueCell.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 15/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct ValueCell: View {
  let state: ValueCellState
  
  var body: some View {
    VStack(alignment: .leading) {
      InformationsView(
        currentMeasure: state.currentMeasure,
        measureDateBounds: state.measureDateBounds
      )
      BarChartView(bars: state.bars)
    }
    .padding(16)
    .background(Color(.secondarySystemBackground))
    .cornerRadius(16)
    .padding(.horizontal, 8)
    .shadow(radius: 5, y: 3)
      .frame(minHeight: 300)
  }
}

//struct ValueCell_Previews: PreviewProvider {
//  static var previews: some View {
//    ValueCell(state: <#T##ValueCellState#>)
//      .previewDevice("iPhone SE")
//  }
//}

