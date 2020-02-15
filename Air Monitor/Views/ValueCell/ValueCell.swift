//
//  ValueCell.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 15/02/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct ValueCell: View {
  var body: some View {
    VStack(alignment: .leading) {
      InformationsView()
      BarChartView(bars: previewBars)
    }
    .padding(16)
    .background(Color.white)
    .cornerRadius(16)
    .padding(.horizontal, 8)
    .shadow(radius: 5, y: 3)
    .frame(maxHeight: 300)
  }
}

struct ValueCell_Previews: PreviewProvider {
  static var previews: some View {
    ValueCell()
      .previewDevice("iPhone SE")
  }
}

private let previewBars = [
  Bar(id: UUID(), value: 1, color: .green),
  Bar(id: UUID(), value: 2, color: .green),
  Bar(id: UUID(), value: 3, color: .green),
  Bar(id: UUID(), value: 5, color: .yellow),
  Bar(id: UUID(), value: 6, color: .yellow),
  Bar(id: UUID(), value: 8, color: .yellow),
  Bar(id: UUID(), value: 5, color: .yellow),
  Bar(id: UUID(), value: 3, color: .green),
  Bar(id: UUID(), value: 1, color: .green),
  Bar(id: UUID(), value: 2, color: .green),
  Bar(id: UUID(), value: 3, color: .green),
  Bar(id: UUID(), value: 4, color: .green),
  Bar(id: UUID(), value: 6, color: .yellow),
  Bar(id: UUID(), value: 9, color: .red),
  Bar(id: UUID(), value: 12, color: .red),
  Bar(id: UUID(), value: 10, color: .red),
  Bar(id: UUID(), value: 8, color: .yellow),
  Bar(id: UUID(), value: 7, color: .yellow),
  Bar(id: UUID(), value: 6, color: .yellow),
  Bar(id: UUID(), value: 4, color: .green),
  Bar(id: UUID(), value: 2, color: .green),
  Bar(id: UUID(), value: 1, color: .green),
  Bar(id: UUID(), value: 1, color: .green),
  Bar(id: UUID(), value: 3, color: .green)
]
