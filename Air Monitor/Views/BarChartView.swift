//
//  BarChartView.swift
//  Air Monitor
//
//  Created by Paolo Rocca on 12/01/2020.
//  Copyright © 2020 Paolo Rocca. All rights reserved.
//

import SwiftUI

struct BarChartView: View {
  private let bars: [Bar]
  private let maxValue: Int
  
  init(bars: [Bar]) {
    self.bars = bars
    self.maxValue = bars.map(\.value).max() ?? 0
  }
  
  var body: some View {
    GeometryReader { geometry in
      HStack(alignment: .bottom, spacing: 0) {
        ForEach(self.bars) { bar in
          Capsule()
            .fill(bar.color)
            .frame(height: CGFloat(bar.value) / CGFloat(self.maxValue) * geometry.size.height)
            .overlay(Rectangle().stroke(Color.white))
        }
      }
    }
  }
}


struct BarChartView_Previews: PreviewProvider {
  private static let previewBars = [
    Bar(id: UUID(), value: 1, color: .green),
    Bar(id: UUID(), value: 2, color: .green),
    Bar(id: UUID(), value: 3, color: .green),
    Bar(id: UUID(), value: 5, color: .yellow),
    Bar(id: UUID(), value: 6, color: .yellow),
    Bar(id: UUID(), value: 8, color: .red),
    Bar(id: UUID(), value: 5, color: .yellow),
    Bar(id: UUID(), value: 3, color: .green),
    Bar(id: UUID(), value: 1, color: .green),
    Bar(id: UUID(), value: 1, color: .green),
    Bar(id: UUID(), value: 3, color: .green),
    Bar(id: UUID(), value: 4, color: .green),
  ]
  
  static var previews: some View {
    BarChartView(bars: previewBars)
      .frame(height: 300, alignment: .center)
  }
}
