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
  
  private var yAxisValues: [Double] {
    guard
      let max = bars.max(by: \.value)?.value,
      max > 0
      else { return [] }
    
    let step = Double(max) / 6
    
    return Array(stride(from: Double(0), to: Double(max), by: step)) + [Double(max)]
  }
  
  private let formatter = NumberFormatter.singleDecimal
  
  init(bars: [Bar]) {
    self.bars = bars
    self.maxValue = bars.map(\.value).max() ?? 0
  }
  
  var body: some View {
    GeometryReader { geometry in
      HStack(alignment: .bottom) {
        VerticalIndexView(values: self.yAxisValues, formatter: self.formatter)
          .font(.footnote)
          .frame(height: geometry.size.height)
        
        BarsView(bars: self.bars)
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
  
  static var previews: some View {
    BarChartView(bars: previewBars)
      .frame(height: 300, alignment: .center)
  }
}
